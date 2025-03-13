//
//  SwiftAdsLoader.swift
//  SwiftAds
//
//  Created by lbe on 2025/3/5.
//

class SwiftAdsLoader: AdsLoader {
    
    var adsPage: AdsPage
    var autoFill: Bool = false
    var cacheAdList: [SwiftAds] = [SwiftAds]()
    var runningTaskList: [Task<SwiftAds?,Never>] = []
    
    var maxLoadCount: Int = 0
    var maxLoadConcurrency: Int = 0
        
    init(adsPage: AdsPage) {
        self.adsPage = adsPage
        self.maxLoadCount = adsPage.preloadFillCount
        self.maxLoadConcurrency = adsPage.preloadConcurrency
    }
    
    func startAutoFill() {
        if autoFill {
            return
        }
        autoFill = true
        
    }
    
    func stopAutoFill() {
        autoFill = false
    }
    
    func fetch<T: SwiftAds>() async -> T? where T: SwiftAds {
        
        // 优先检查缓存集合中是否有可用的广告，有则返回
        if !cacheAdList.isEmpty {
            cacheAdList.removeAll { $0.isExpired() }
            
            if !cacheAdList.isEmpty {
                checkAutoFill()
                return cacheAdList.removeFirst() as? T
            }
        }
        
        // 检查是否有正在加载的page name对应的Task 有则等待此任务结束返回结果
        if !runningTaskList.isEmpty {
            let task = runningTaskList.removeFirst()
            let result = await task.value
            if result != nil {
                checkAutoFill()
                return result as? T
            }
        }
        
        return await loadInternal() as? T
    }
    
    private func loadInternal() async -> SwiftAds? {
        guard let adUnit = adsPage.admobUnits.first else {
            print("swift ads loader load internal ad unit is null")
            // TODO adunit空的打点
            return nil
        }
        
        guard let adapter = AdManager.shared.getOrCreatePlatformAdapter(platform: adUnit.platform) else {
            print("swift ads loader load internal adapter is null")
            //TODO adapter不存在时打点
            return nil
        }
        
        var adConfig: [String : Any] = [String: Any]()
        adConfig.merge(adUnit.toDictionary(), uniquingKeysWith: { (current, _) in current })
        
        print("swift ads loader load internal will load ad  config: \(adConfig)")
        
        var realAdObj: SwiftAds?
        if adsPage.style == "fullscreen" {
            let result = await adapter.loadFullScreenAds(config: adConfig)
            realAdObj = result.adResult
        } else if adsPage.style == "view" {
            let result = await adapter.loadViewAds(config: adConfig)
            realAdObj = result.adResult
        } else {
            // TODO 错误的style打点
            return nil
        }
        
        return realAdObj
    }
    
    private func checkAutoFill() {
        if autoFill {
            fillPool()
        }
    }
    
    private func fillPool() {
        Task {
            while( maxLoadCount > cacheAdList.count) {
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
    
}
