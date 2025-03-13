//
//  AdManager.swift
//  SwiftAds
//
//  Created by lbe on 2025/3/5.
//
import Foundation

class AdManager {
    
    static let shared = AdManager()
    
    private let defaultAdsConfig: AdsConfig = DEFAULT_ADS_CONFIG
    private var serverAdsConfig: AdsConfig?
    private var adsConfig: AdsConfig {
        if let serverAdsConfig = serverAdsConfig {
            return serverAdsConfig
        }
        return defaultAdsConfig
    }
    
    private var loaderMap: [String : AdsLoader] = [String : AdsLoader]()
    private var adapterMap: [String : AdsAdapter] = [String : AdsAdapter]()
    
    func getOrCreatePlatformAdapter(platform: String) -> AdsAdapter? {
        guard let adapter = adapterMap[platform] else {
            return createNewAdapter(platform: platform)
        }
        adapterMap[platform] = adapter
        return adapter
    }
    
    private func createNewAdapter(platform: String) -> AdsAdapter {
        var platformConfig = if (platform == "admob") {
            adsConfig.admobPlatform.toDictionary()
        } else {
            adsConfig.maxPlatform.toDictionary()
        }
        
        let adapter: AdsAdapter = if platform == "admob" {
            AdmobAdapter()
        } else {
            MaxAdapter()
        }
        
        adapter.initAdapter(config: platformConfig)
        return adapter
    }

    func newAdsLoader(pageName: String) -> AdsLoader {
        return createAdsLoader(pageName: pageName, global: false)
    }
    
    func globalAdsLoader(pageName: String) -> AdsLoader {
        return createAdsLoader(pageName: pageName, global: true)
    }
    
    private func createAdsLoader(pageName: String,global: Bool) -> AdsLoader {
        guard !pageName.isEmpty else {
            // TODO: 空 pageName 打点
            return ErrorLoader()
        }

        guard let page = adsConfig.adsPages.first(where: {$0.pageName == pageName} ) else {
            // TODO 空page 打点
            return ErrorLoader()
        }
        
        if global {
            let adsLoader = loaderMap[pageName] ?? SwiftAdsLoader(adsPage: page)
            loaderMap[pageName] = adsLoader
            return adsLoader
        }
        return SwiftAdsLoader(adsPage: page)
    }
    
    func getConfigVersion() -> Int {
        return adsConfig.version
    }
    
    func updateAdsConfig(configJson: String) {
        guard !configJson.isEmpty else {
            print("ad manager update config is empty")
            return
        }
        let adsConfig = decodeJSON(configJson, as: AdsConfig.self)
        if adsConfig == nil || (adsConfig?.version ?? 0) <= (serverAdsConfig?.version ?? 0) {
            return
        }
        print("admanager update ads config \(String(describing: adsConfig))")
        self.serverAdsConfig = adsConfig
    }
    
    func decodeJSON<T: Decodable>(_ jsonString: String, as type: T.Type) -> T? {
        guard let jsonData = jsonString.data(using: .utf8) else {
            print("Failed to convert JSON string to Data")
            return nil
        }
        
        do {
            let decoder = JSONDecoder()
            let object = try decoder.decode(type, from: jsonData)
            return object
        } catch {
            print("Failed to decode JSON: \(error)")
            return nil
        }
    }
}

class ErrorLoader: AdsLoader {
    func fetch() {
        return
    }
    
    func preload() {
        
    }
    
    func startAutoFill() {
        
    }
    
    func stopAutoFill() {
        
    }
    
}

