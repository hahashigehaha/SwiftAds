//
//  SwiftAdsLoader.swift
//  SwiftAds
//
//  Created by lbe on 2025/3/5.
//

class SwiftAdsLoader: AdsLoader {
    
    var adsPage: AdsPage
    
    init(adsPage: AdsPage) {
        self.adsPage = adsPage
    }
    
    func preload() {
        
    }
    
    func startAutoFill() {
        
    }
    
    func stopAutoFill() {
        
    }
    
    func fetch() -> SwiftAds? {
        Task {
            let result = await loadInternal()
            await MainActor.run {
                if result is SwiftFullScreenAds {
                    (result as? SwiftFullScreenAds)?.show()
                }
            }
        }
        
        return nil
    }
    
    private func loadInternal() async ->SwiftAds? {
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
        guard let result: SwiftAds? = await {
            switch adsPage.style {
                case "fullscreen":
                    return await adapter.loadFullScreenAds(config: adConfig)
                case "view":
                    return await adapter.loadViewAds(config: adConfig)
                default:
                    return nil
            }
        }() else {
            //TODO 错误的 style，打点
            return nil
        }
        
        guard let result = result else {
            return nil
        }
        
        return result
    }
    
    
}
