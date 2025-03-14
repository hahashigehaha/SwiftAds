//
//  AdmobFullScreenAds.swift
//  SwiftAds
//
//  Created by lbe on 2025/3/12.
//

import GoogleMobileAds
import Foundation

class AdmobFullScreenAds: SwiftFullScreenAds {
    
    var rawAd: Any?
    var adValue: AdValue?
    
    override init(platformAdUnit: String,ttl: Int) {
        super.init(platformAdUnit: platformAdUnit, ttl: ttl)
        platform = "admob"
    }
    
    deinit {
        print("admob fullscreen ads deinit")
    }
    
    func setRawAd(rawAd: Any) {
        self.rawAd = rawAd
        
        if rawAd is AppOpenAd {
            let appOpenAd = rawAd as! AppOpenAd
            appOpenAd.paidEventHandler = { (adValue) in self.handleAdmobAdValue(adValue: adValue)}
            AdmobUtils.resolveResponseInfo(ads: self,responseInfo: appOpenAd.responseInfo.loadedAdNetworkResponseInfo)
        } else if rawAd is InterstitialAd {
            let interstitialAd = rawAd as! InterstitialAd
            interstitialAd.paidEventHandler = { (adValue) in self.handleAdmobAdValue(adValue: adValue)}
            AdmobUtils.resolveResponseInfo(ads: self,responseInfo: interstitialAd.responseInfo.loadedAdNetworkResponseInfo)
        } else if rawAd is RewardedAd {
            let rewardAd = rawAd as! RewardedAd
            rewardAd.paidEventHandler = { (adValue) in self.handleAdmobAdValue(adValue: adValue)}
            AdmobUtils.resolveResponseInfo(ads: self,responseInfo: rewardAd.responseInfo.loadedAdNetworkResponseInfo)
        }
    }
    
    private func handleAdmobAdValue(adValue: AdValue) {
        self.adValue = adValue
        AdmobUtils.resolveAdmobPaidInfo(ads: self, adValue: adValue)
        self.interactionCallback?.onAdsPaid()
    }
    
    override func getUSDMicros() -> Double {
        return adValue?.value.doubleValue ?? 0
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
}

extension AdmobFullScreenAds: FullScreenContentDelegate {
    
    func adWillPresentFullScreenContent(_ ad: any FullScreenPresentingAd) {
    }
    
    func adDidRecordImpression(_ ad: any FullScreenPresentingAd) {
        self.interactionCallback?.onAdImpression()
    }
    
    func adDidRecordClick(_ ad: any FullScreenPresentingAd) {
        self.interactionCallback?.onAdClicked()
    }
    
    func adDidDismissFullScreenContent(_ ad: any FullScreenPresentingAd) {
        self.interactionCallback?.onAdClosed()
    }
}
