//
//  AdmobFullScreenAds.swift
//  SwiftAds
//
//  Created by lbe on 2025/3/12.
//

import GoogleMobileAds
import Foundation

class AdmobFullScreenAds:SwiftFullScreenAds {
        
    var interactionCallback: InteractionCallback?
    
    var rawAd: Any?
    
    init(platformAdUnit: String) {
        super.init()
        platform = "admob"
        self.platformAdUnit = platformAdUnit
        self.uuid = UUID().uuidString
    }
    
    deinit {
        print("admob fullscreen ads deinit")
    }
    
    func setRawAd(rawAd: Any) {
        self.rawAd = rawAd
    }
    
    override func show() {
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
    
    override func setInteractionCallback(callback: any InteractionCallback) {
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
