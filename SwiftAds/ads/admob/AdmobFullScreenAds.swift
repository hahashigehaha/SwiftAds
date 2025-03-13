//
//  AdmobFullScreenAds.swift
//  SwiftAds
//
//  Created by lbe on 2025/3/12.
//

import GoogleMobileAds
import Foundation

class AdmobFullScreenAds:NSObject, SwiftFullScreenAds {
    
    var platform: String
    
    var platformAdUnit: String
    
    var uuid: String
    
    var interactionCallback: InteractionCallback?
    
    var rawAd: Any?
    
    init(platformAdUnit: String) {
        self.platform = "admob"
        self.platformAdUnit = platformAdUnit
        self.uuid = UUID().uuidString
    }
    
    deinit {
        print("admob fullscreen ads deinit")
    }
    
    func setRawAd(rawAd: Any) {
        self.rawAd = rawAd
    }
    
    func show() {
        if rawAd is AppOpenAd {
            let appOpenAd = rawAd as! AppOpenAd
            appOpenAd.fullScreenContentDelegate = self
            appOpenAd.present(from: nil)
        } else if rawAd is InterstitialAd {
            let interstitialAd = rawAd as! InterstitialAd
            interstitialAd.fullScreenContentDelegate = self
            interstitialAd.present(from: nil)
        } else if rawAd is RewardedAd {
            let rewardAd = rawAd as! RewardedAd
            rewardAd.fullScreenContentDelegate = self
            rewardAd.present(from: nil) {
                print("admob full screen reward ad reward")
            }
        }
    }
    
    func isExpired() -> Bool {
        return false
    }
    
    func ttl() -> Int {
        return 0
    }
    
    func expireTimestamp() -> Int {
        return 0
    }
    
    func setInfo(key: String, info: Any) {
        
    }
    
    func getInfo(key: String) -> Any {
        return ""
    }
    
    func allInfo() -> [String : Any] {
        return [String: Any]()
    }
    
    func getRawAd() -> Any {
        return ""
    }
    
    func getUSDMicros() -> Double {
        return 0
    }
    
    func setInteractionCallback(callback: any InteractionCallback) {
        self.interactionCallback = callback
    }
}

extension AdmobFullScreenAds: FullScreenContentDelegate {
    
    
    func adWillPresentFullScreenContent(_ ad: any FullScreenPresentingAd) {
        print("admob fullscreen ads will impression")
    }
    
    func adDidRecordImpression(_ ad: any FullScreenPresentingAd) {
        print("admob fullscreen ads did impression")
        self.interactionCallback?.onAdImpression()
    }
    
    func adDidRecordClick(_ ad: any FullScreenPresentingAd) {
        print("admob fullscreen ads did click")
        self.interactionCallback?.onAdClicked()
    }
    
    func adDidDismissFullScreenContent(_ ad: any FullScreenPresentingAd) {
        print("admob fullscreen ads did dismiss")
        self.interactionCallback?.onAdClosed()
    }
}
