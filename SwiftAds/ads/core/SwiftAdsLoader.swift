//
//  SwiftAdsLoader.swift
//  SwiftAds
//
//  Created by lbe on 2025/3/5.
//

import Foundation

class SwiftAdsLoader: AdsLoader {
    
    var adsPage: AdsPage
    var autoFill: Bool = false
    var cacheAdList: [SwiftAds] = [SwiftAds]()
    var runningTaskList: [Task<SwiftAds?,Never>] = []
    
    var maxLoadCount: Int = 0
    var maxLoadConcurrency: Int = 0
    
    let adsManager = AdManager.shared
                
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
                cacheAdList.removeAll { $0.isExpired() }
                print("swift ads loader start fill recyle check fill")
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
        
        // 优先检查缓存集合中是否有可用的广告，有则返回
        if !cacheAdList.isEmpty {
            cacheAdList.removeAll { $0.isExpired() }
            
            if !cacheAdList.isEmpty {
                let ad = cacheAdList.removeFirst() as? T
                checkAutoFill()
                adsManager.notifyEvent(event: AdsConstant.ST_AD_FETCH_RESULT, eventParams: buildEventParams(ad: ad, extraParams: ["from":"cache","result":true,"page_name":adsPage.pageName]))
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
                adsManager.notifyEvent(event: AdsConstant.ST_AD_FETCH_RESULT, eventParams: buildEventParams(ad: ad, extraParams: ["from":"running","result":true]))
                return ad
            }
        }
        
        let ad = await loadInternal() as? T
        checkAutoFill()
        adsManager.notifyEvent(event: AdsConstant.ST_AD_FETCH_RESULT, eventParams: buildEventParams(ad: ad, extraParams: ["from":"load","result": ad != nil]))
        return ad
    }
    
    private func loadInternal() async -> SwiftAds? {
        let adStartTime = Date().timeIntervalSince1970
        guard let adUnit = adsPage.admobUnits.first else {
            print("swift ads loader load internal ad unit is null")
            adsManager.notifyEvent(event: AdsConstant.ST_AD_LOAD_RESULT, eventParams: buildEventParams(ad: nil, extraParams: ["reason":"adUnit not found","result":false]))
            return nil
        }
        
        guard let adapter = AdManager.shared.getOrCreatePlatformAdapter(platform: adUnit.platform) else {
            print("swift ads loader load internal adapter is null")
            adsManager.notifyEvent(event: AdsConstant.ST_AD_LOAD_RESULT, eventParams: buildEventParams(ad: nil, extraParams: ["reason":"unsupported platform","result":false]))
            return nil
        }
        
        var timeOutMs = adsPage.timeOutMs
        var adConfig: [String : Any] = [String: Any]()
        adConfig.merge(adUnit.toDictionary(), uniquingKeysWith: { (current, _) in current })
        adConfig["ttl"] = adsPage.ttl
        
        print("swift ads loader load internal will load ad  config: \(adConfig)")
        
        var realAdObj: SwiftAds?
        var reason: String = ""
        let requestTask = Task {
            var adResult: SwiftAds?
            var reason: String = ""
            if adsPage.style == "fullscreen" {
                let result = await adapter.loadFullScreenAds(config: adConfig)
                adResult = result.adResult
                reason = result.reason
            } else if adsPage.style == "view" {
                let result = await adapter.loadViewAds(config: adConfig)
                adResult = result.adResult
                reason = result.reason
            } else {
                adsManager.notifyEvent(event: AdsConstant.ST_AD_LOAD_RESULT, eventParams: buildEventParams(ad: nil, extraParams: ["reason":"unsupported style","result":false]))
                adResult = nil
            }
            return (adResult,reason)
        }
        
        let timeOutTask = Task {
            try await Task.sleep(nanoseconds: UInt64(timeOutMs) * NSEC_PER_SEC)
            requestTask.cancel()
        }
        
        do {
            let taskResult = await requestTask.value
            realAdObj = taskResult.0
            reason = taskResult.1
            timeOutTask.cancel()
        } catch {
            print("swift ads loader load internal time out : \(error.localizedDescription)")
        }
        
        let loadTime = Int((Date().timeIntervalSince1970 - adStartTime) * 1000)
        adsManager.notifyEvent(event: AdsConstant.ST_AD_LOAD_RESULT, eventParams: buildEventParams(ad: realAdObj, extraParams: ["reason":reason,"result":realAdObj != nil,"load_time":loadTime]))
        return realAdObj
    }
    
    private func checkAutoFill() {
        print("swift ads loader check auto fill : \(autoFill) cache count: \(cacheAdList.count)  running count : \(runningTaskList.count)")
        if autoFill {
            fillPool()
        }
    }
    
    private func fillPool() {
        Task {
            while( maxLoadCount > (cacheAdList.count + runningTaskList.count) && maxLoadConcurrency > runningTaskList.count) {
                let task = Task { return await loadInternal() }
                runningTaskList.append(task)
                let result = await task.value

                runningTaskList.removeAll { $0 == task }
                
                if result != nil {
                    cacheAdList.append(result!)
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
    
    private func checkCacheAdList() {
        cacheAdList.removeAll { $0.isExpired() }
    }
    
}
