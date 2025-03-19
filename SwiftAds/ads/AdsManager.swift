//
//  AdManager.swift
//  SwiftAds
//
//  Created by lbe on 2025/3/5.
//
import Foundation

class AdsManager {
    
    static let shared = AdsManager()
    
    private let defaultAdsConfig: AdsConfig = DEFAULT_ADS_CONFIG
    private var serverAdsConfig: AdsConfig?
    private var adsConfig: AdsConfig {
        if let serverAdsConfig = serverAdsConfig {
            return serverAdsConfig
        }
        return defaultAdsConfig
    }
    
    // 线程安全的队列来保护资源
    private let adapterMapQueue = DispatchQueue(label: "com.adsmanager.adapterMapQueue")

    private var loaderMap: ThreadSafeDictionary = ThreadSafeDictionary<String, AdsLoader>()
    private var adapterMap: [String : AdsAdapter] = [String : AdsAdapter]()
    
    private var eventDelegates = [WeakEventDelegate]()
    
    func getOrCreatePlatformAdapter(platform: String) -> AdsAdapter? {
        return adapterMapQueue.sync {
            var adapter = adapterMap[platform]
            if adapter == nil {
                adapter = createNewAdapter(platform: platform)
                adapterMap[platform] = adapter
            }
            return adapter
        }
    }
    
    private func createNewAdapter(platform: String) -> AdsAdapter {
        let platformConfig = if (platform == "admob") {
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
            notifyEvent(event: AdsConstant.ST_AD_FETCH_RESULT, eventParams: ["reson":"page name is null","page_name":pageName])
            return ErrorLoader()
        }

        guard let page = adsConfig.adsPages.first(where: {$0.pageName == pageName} ) else {
            notifyEvent(event: AdsConstant.ST_AD_FETCH_RESULT, eventParams: ["reson":"page not found","page_name":pageName])
            return ErrorLoader()
        }
        
        if global {
            let adsLoader = loaderMap.getValue(forKey: pageName) ?? SwiftAdsLoader(adsPage: page)
            loaderMap.setValue(adsLoader, forKey: pageName)
            return adsLoader
        }
        return SwiftAdsLoader(adsPage: page)
    }
    
    func startAutoFill() {
        adsConfig.adsPages.forEach { adsPage in
            if adsPage.preloadFillCount > 0 {
                let loader = globalAdsLoader(pageName: adsPage.pageName)
                loader.startAutoFill()
            }
        }
    }

    func stopAutoFill() {
        loaderMap.values.forEach { loader in
            loader.stopAutoFill()
        }
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
    
    func addEventDelegate(_ delegate: SwiftEventDelegate) {
        eventDelegates.append(WeakEventDelegate(delegate: delegate))
    }
    
    func notifyEvent(event: String, eventParams: [String: Any]?) {
        var params = eventParams ?? [:]
        params["config_version"] = getConfigVersion()
        
        let eventDelegatesTemp = [WeakEventDelegate](eventDelegates)
        DispatchQueue.main.async {
            // 通知所有 delegate
            eventDelegatesTemp.forEach { weakDelegate in
                weakDelegate.delegate?.onEvent(eventName: event, params: params)
            }
        }
    }
    
    private func decodeJSON<T: Decodable>(_ jsonString: String, as type: T.Type) -> T? {
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
    func fetch<T>() async -> T? where T : SwiftAds {
        return nil
    }
    
    func startAutoFill() {
        
    }
    
    func stopAutoFill() {
        
    }
    
}

