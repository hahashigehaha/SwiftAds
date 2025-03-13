//
//  SwiftAds.swift
//  SwiftAds
//
//  Created by lbe on 2025/3/5.
//


protocol MiddlewareAds {
    var platform: String { get }
    var platformAdUnit: String {get}
    var uuid: String {get}

    func setInfo(key: String, info: Any)
    func getInfo(key: String) -> Any
    func allInfo() -> [String : Any]
    func getRawAd() -> Any
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
    associatedtype T: SwiftAds // 声明关联类型 T
    
    func initAdapter(config: [String : Any])
    func loadFullScreenAds(config: [String : Any]) async -> (adResult: T?,reson: String?)
    func loadViewAds(config: [String : Any]) async -> (adResult: T?,reson: String?)
}

protocol AdsLoader {
    associatedtype T : SwiftAds // 声明关联类型 T

    func preload()
    func startAutoFill()
    func stopAutoFill()
    func fetch()
}

protocol SwiftFullScreenAds: SwiftAds {
    func show()
}

protocol SwiftViewAds: SwiftAds {
    func view()
}
