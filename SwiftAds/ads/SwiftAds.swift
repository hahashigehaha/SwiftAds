//
//  SwiftAds.swift
//  SwiftAds
//
//  Created by lbe on 2025/3/5.
//

import UIKit

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
}

protocol InteractionCallback {
    func onAdClicked()
    func onAdClosed()
    func onAdImpression()
    func onAdsPaid()
}

protocol AdsAdapter {
    func initAdapter(config: [String : Any])
    func loadFullScreenAds(config: [String : Any]) async -> (adResult: SwiftFullScreenAds?,reason: String)
    func loadViewAds(config: [String : Any]) async -> (adResult: SwiftViewAds?,reason: String)
}

protocol AdsLoader {
    func startAutoFill()
    func stopAutoFill()
    func fetch<T: SwiftAds>() async -> T?
}

class SwiftFullScreenAds: SwiftBaseAdsImpl {
    func show() {}
}

class SwiftViewAds: SwiftBaseAdsImpl {
    func view() -> UIView? {
        return nil
    }
}

protocol SwiftAdContentDelegate {
    associatedtype T: SwiftAds
    
    func adLoaded(result: T)
    func adFailed()
}
