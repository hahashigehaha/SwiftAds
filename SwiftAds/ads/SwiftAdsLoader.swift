//
//  SwiftAdsLoader.swift
//  SwiftAds
//
//  Created by lbe on 2025/3/5.
//

class SwiftAdsLoader<T: SwiftAds>: AdsLoader {
    
    
    var adsPage: AdsPage
    var test:Any?
    
    init(adsPage: AdsPage) {
        self.adsPage = adsPage
    }
    
    func preload() {
        
    }
    
    func startAutoFill() {
        
    }
    
    func stopAutoFill() {
        
    }
    
    func fetch() {
        Task {
            let result = await loadInternal()
            print("swift ads loader fetch result : \(String(describing: result))")
            await MainActor.run {
                test = result
                if result is SwiftFullScreenAds {
                    (result as? SwiftFullScreenAds)?.show()
                }
            }
        }
        
    }
    
    private func loadInternal() async -> T? {
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
        let result: (adResult: T?, reason: String?) = await {
            switch adsPage.style {
            case "fullscreen":
                return await adapter.loadFullScreenAds(config: adConfig)
            case "view":
                return await adapter.loadViewAds(config: adConfig)
            default:
                // TODO 错误的style打点
                return (nil, "Invalid style")
            }
        }()
        
        return result.adResult
    }
    
    
}
