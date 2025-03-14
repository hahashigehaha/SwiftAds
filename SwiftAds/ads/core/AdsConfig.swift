//
//  AdsConfig.swift
//  SwiftAds
//
//  Created by lbe on 2025/3/5.
//

protocol Platform: Codable {
    var name: String {
        get
    }
    var appId: String {
        get
    }
}

protocol AdUnit: Codable {
    var adUnitId: String { get }
    var adType: String { get }
    var platform: String { get }
}

struct AdmobPlatform: Platform {
    var name: String = "admob"
    var appId: String = ""
}

struct MaxPlatform: Platform {
    var name: String = "max"
    var appId: String = ""
}

struct AdmobUnit: AdUnit {
    var adUnitId: String = ""
    var adType: String = ""
    var platform: String
    var nativeAdChoicesLocation: Int
    
    // 自定义解码逻辑
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // 解码 adUnitId，如果 JSON 中没有该字段，则使用默认值 ""
        adUnitId = try container.decodeIfPresent(String.self, forKey: .adUnitId) ?? ""
        
        // 解码 adType，如果 JSON 中没有该字段，则使用默认值 ""
        adType = try container.decodeIfPresent(String.self, forKey: .adType) ?? ""
        
        // 解码 platform，如果 JSON 中没有该字段，则使用默认值 "admob"
        platform = try container.decodeIfPresent(String.self, forKey: .platform) ?? "admob"
        
        // 解码 nativeAdChoicesLocation，如果 JSON 中没有该字段，则使用默认值 0
        nativeAdChoicesLocation = try container.decodeIfPresent(Int.self, forKey: .nativeAdChoicesLocation) ?? 0
    }
}

struct MaxUnit: AdUnit {
    var adUnitId: String = ""
    var adType: String = ""
    var platform: String = "max"
    
    // 自定义解码逻辑
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        // 解码 platform，如果 JSON 中没有该字段，则使用默认值 "admob"
        platform = try container.decodeIfPresent(String.self, forKey: .platform) ?? "max"
    }
}

struct AdsPage: Codable {
    var pageName: String
    var style: String
    var timeOutMs: Int
    var ttl: Int
    
    var preloadFillCount: Int
    var preloadConcurrency: Int
    var admobUnits: [AdmobUnit]
    var maxUnits: [MaxUnit]
    
}

struct AdsConfig: Codable {
    var version : Int = 0
    
    var admobPlatform: AdmobPlatform
    var maxPlatform: MaxPlatform
    var adsPages: [AdsPage]
    
}

extension AdUnit {
    
    func toDictionary() -> [String: Any] {
        let mirror = Mirror(reflecting: self)
        var dictionary = [String: Any]()
            
        for child in mirror.children {
            if let key = child.label {
                dictionary[key] = child.value
            }
        }
          
        return dictionary
    }
}

extension Platform {
    
    func toDictionary() -> [String: Any] {
        let mirror = Mirror(reflecting: self)
        var dictionary = [String: Any]()
            
        for child in mirror.children {
            if let key = child.label {
                dictionary[key] = child.value
            }
        }
          
        return dictionary
    }
}

let DEFAULT_ADS_CONFIG = AdsConfig(admobPlatform: AdmobPlatform(), maxPlatform: MaxPlatform(), adsPages: [AdsPage]())
