//
//  SwiftAdsLoader.swift
//  SwiftAds
//
//  Created by lbe on 2025/3/5.
//

import Foundation

class SwiftAdsLoader: AdsLoader {
    private let cacheQueue = DispatchQueue(label: "com.swiftads.cacheQueue", attributes: .concurrent)

    var adsPage: AdsPage
    var autoFill: Bool = false
    var cacheAdList: [SwiftAds] = [SwiftAds]()
    var runningTaskList: [Task<SwiftAds?,Never>] = []
    
    var maxLoadCount: Int = 0
    var maxLoadConcurrency: Int = 0
    
    let adsManager = AdsManager.shared
                
    init(adsPage: AdsPage) {
        self.adsPage = adsPage
        self.maxLoadCount = adsPage.preloadFillCount
        self.maxLoadConcurrency = adsPage.preloadConcurrency
    }
    
    func startAutoFill() {
        guard !autoFill else { return }
        autoFill = true
        
        // 开启异步检查任务，一分钟检查一次，如果广告过期及时补充新广告
        Task {
            while(true) {
                removeExpiredCacheAds()
                print("swift ads loader start fill recyle check fill : \(adsPage.pageName)")
                checkAutoFill()
                try await Task.sleep(nanoseconds: 60 * 1_000_000_000)
                if !autoFill {
                    break
                }
            }
        }
    }
    
    func stopAutoFill() {
        autoFill = false
    }
    
    func fetch<T: SwiftAds>() async -> T? where T: SwiftAds {
        let adStartTime = Date().timeIntervalSince1970
        // 优先检查缓存集合中是否有可用的广告，有则返回
        if !cacheAdList.isEmpty {
            removeExpiredCacheAds()
            
            if !cacheAdList.isEmpty {
                let ad = getCachedAds() as? T
                checkAutoFill()
                let loadTime = Int((Date().timeIntervalSince1970 - adStartTime) * 1000)
                adsManager.notifyEvent(event: AdsConstant.ST_AD_FETCH_RESULT, eventParams: buildEventParams(ad: ad, extraParams: ["from":"cache","result":true,"page_name":adsPage.pageName,"load_time":loadTime]))
                return ad
            }
        }
        
        // 检查是否有正在加载的page name对应的Task 有则等待此任务结束返回结果
        if !runningTaskList.isEmpty {
            let task = runningTaskList.removeFirst()
            let result = await task.value
            if result != nil {
                let ad = result as? T
                checkAutoFill()
                let loadTime = Int((Date().timeIntervalSince1970 - adStartTime) * 1000)
                adsManager.notifyEvent(event: AdsConstant.ST_AD_FETCH_RESULT, eventParams: buildEventParams(ad: ad, extraParams: ["from":"running","result":true,"load_time":loadTime]))
                return ad
            }
        }
        
        let ad = await loadInternal() as? T
        checkAutoFill()
        let loadTime = Int((Date().timeIntervalSince1970 - adStartTime) * 1000)
        adsManager.notifyEvent(event: AdsConstant.ST_AD_FETCH_RESULT, eventParams: buildEventParams(ad: ad, extraParams: ["from":"load","result": ad != nil,"load_time":loadTime]))
        return ad
    }
    
    private func loadInternal() async -> SwiftAds? {
        let adStartTime = Date().timeIntervalSince1970
        guard let adUnit = adsPage.admobUnits.first else {
            print("swift ads loader load internal ad unit is null")
            adsManager.notifyEvent(event: AdsConstant.ST_AD_LOAD_RESULT, eventParams: buildEventParams(ad: nil, extraParams: ["reason":"adUnit not found","result":false]))
            return nil
        }
        
        guard let adapter = AdsManager.shared.getOrCreatePlatformAdapter(platform: adUnit.platform) else {
            print("swift ads loader load internal adapter is null")
            adsManager.notifyEvent(event: AdsConstant.ST_AD_LOAD_RESULT, eventParams: buildEventParams(ad: nil, extraParams: ["reason":"unsupported platform","result":false]))
            return nil
        }
        
        let timeOutMs = adsPage.timeOutMs
        var adConfig: [String : Any] = [String: Any]()
        adConfig.merge(adUnit.toDictionary(), uniquingKeysWith: { (current, _) in current })
        adConfig["ttl"] = adsPage.ttl
                
        var realAdObj: SwiftAds?
        var reason: String = ""
        
        do {
            let taskResult = try await withTimeout(millisecond: timeOutMs) {
                try await self.performAdLoad(with: adapter, config: adConfig)
            }
            realAdObj = taskResult?.0
            reason = taskResult?.1 ?? ""
        }  catch is TimeoutError {
            reason = "timeout"
        } catch {
            reason = "unknow error: \(error.localizedDescription)"
        }
        
        let loadTime = Int((Date().timeIntervalSince1970 - adStartTime) * 1000)
        adsManager.notifyEvent(event: AdsConstant.ST_AD_LOAD_RESULT, eventParams: buildEventParams(ad: realAdObj, extraParams: ["reason":reason,"result":realAdObj != nil,"load_time":loadTime]))
        return realAdObj
    }
    
    private func performAdLoad(with adapter: AdsAdapter, config: [String: Any]) async throws -> (SwiftAds?, String) {
        var adResult: SwiftAds?
        var reason: String = ""
        if self.adsPage.style == "fullscreen" {
            let result = await adapter.loadFullScreenAds(config: config)
            adResult = result.adResult
            reason = result.reason
        } else if self.adsPage.style == "view" {
            let result = await adapter.loadViewAds(config: config)
            adResult = result.adResult
            reason = result.reason
        } else {
            self.adsManager.notifyEvent(event: AdsConstant.ST_AD_LOAD_RESULT, eventParams: self.buildEventParams(ad: nil, extraParams: ["reason":"unsupported style","result":false]))
            adResult = nil
        }
        return (adResult,reason)
    }
    
    private func checkAutoFill() {
        print("swift ads loader check auto fill : \(autoFill) cache count: \(cacheAdList.count)  running count : \(runningTaskList.count)")
        if autoFill {
            fillPool()
        }
    }
    
    private func fillPool() {
        while( maxLoadCount > (cacheAdList.count + runningTaskList.count) && maxLoadConcurrency > runningTaskList.count) {
            let task = Task { return await loadInternal() }
            runningTaskList.append(task)
            Task {
                let result = await task.value

                if let index = runningTaskList.firstIndex(where: { $0 == task }) {
                    runningTaskList.remove(at: index)
                    enqueueCache(ads: result)
                }
            }
        }
    }
    
    private func buildEventParams(ad: SwiftAds?, extraParams: [String: Any]?) -> [String: Any] {
        var params = extraParams ?? [:]

        // 合并 ad.allInfo() 字典
        if let adInfo = ad?.allInfo() {
            params.merge(adInfo) { (current, _) in current }
        }
        
        params["page_name"] = adsPage.pageName
        params["style"] = adsPage.style

        return params
    }
    
    // 移除过期的缓存广告
    private func removeExpiredCacheAds() {
        cacheQueue.async(flags: .barrier) {
            self.cacheAdList.removeAll { $0.isExpired() }
        }
    }
    
    // 将广告加入缓存队列
    private func enqueueCache(ads: SwiftAds?) {
        guard let cache = ads else {
            print("SwiftAdsLoader: Attempted to enqueue nil ads")
            return
        }
        
        cacheQueue.async(flags: .barrier) {
            self.removeExpiredCacheAds()
            self.cacheAdList.append(cache)
            print("SwiftAdsLoader: Enqueued cache with UUID: \(cache.uuid), Cache size: \(self.cacheAdList.count)")
        }
    }
    
    // 获取缓存中的广告（线程安全）
    private func getCachedAds() -> SwiftAds? {
        return cacheQueue.sync {
            if cacheAdList.count > 0 {
                return cacheAdList.removeFirst()
            }
            return nil
        }
    }
    
    private func currentTime() -> Int {
        return Int( Date().timeIntervalSince1970 )
    }
    
    private func withTimeout<T>(
        millisecond: Int,
        operation: @escaping () async throws -> T
    ) async throws -> T? {
        return try await withThrowingTaskGroup(of: T.self) { group in
            // 启动任务
            group.addTask {
                return try await operation()
            }
            // 启动超时任务
            group.addTask {
                try await Task.sleep(nanoseconds: UInt64(millisecond * 1_000_000))
                throw TimeoutError()
            }
            // 等待第一个完成的任务
            let result = try await group.next()!
            group.cancelAll() // 取消其他任务
            return result
        }
    }

    struct TimeoutError: Error {}
    
}
