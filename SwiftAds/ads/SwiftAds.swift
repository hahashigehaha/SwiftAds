//
//  SwiftAds.swift
//  SwiftAds
//
//  Created by lbe on 2025/3/5.
//

import ObjectiveC


protocol MiddlewareAds {
    var platform: String { get }
    var platformAdUnit: String {get}
    var uuid: String {get}

    func setInfo(key: String, info: Any)
    func getInfo(key: String) -> Any?
    func allInfo() -> [String : Any]
    func getRawAd() -> Any?
    func getUSDMicros() -> Double
    func setInteractionCallback(callback: InteractionCallback)
}

protocol SwiftAds : MiddlewareAds {
    func isExpired() -> Bool
    func ttl() -> Int
    func expireTimestamp() -> Int
}

protocol InteractionCallback {
    func onAdClicked()
    func onAdClosed()
    func onAdImpression()
    func onAdsPaid()
}

protocol AdsAdapter {
    func initAdapter(config: [String : Any])
    func loadFullScreenAds(config: [String : Any]) async -> (adResult: SwiftFullScreenAds?,reson: String?)
    func loadViewAds(config: [String : Any]) async -> (adResult: SwiftViewAds?,reson: String?)
}

protocol AdsLoader {
    func startAutoFill()
    func stopAutoFill()
    func fetch<T: SwiftAds>() async -> T?
}

class SwiftAdImpl:NSObject, SwiftAds {
    func isExpired() -> Bool {
        return false
    }
    
    func ttl() -> Int {
        return 0
    }
    
    func expireTimestamp() -> Int {
        return 0
    }
    
    var platform: String = ""
    
    var platformAdUnit: String = ""
    
    var uuid: String = ""
    
    func setInfo(key: String, info: Any) {
        
    }
    
    func getInfo(key: String) -> Any? {
        return nil
    }
    
    func allInfo() -> [String : Any] {
        return [String : Any]()
    }
    
    func getRawAd() -> Any? {
        return nil
    }
    
    func getUSDMicros() -> Double {
        return 0
    }
    
    func setInteractionCallback(callback: any InteractionCallback) {
    }
    
}

class SwiftFullScreenAds: SwiftAdImpl {
    func show() {}
}

class SwiftViewAds: SwiftAdImpl {
    func view() {}
}

protocol SwiftAdContentDelegate {
    associatedtype T: SwiftAds
    
    func adLoaded(result: T)
    func adFailed()
}
