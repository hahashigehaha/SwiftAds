//
//  AdmobNativeAds.swift
//  SwiftAds
//
//  Created by lbe on 2025/3/13.
//
import GoogleMobileAds
import SwiftUI

class AdmobNativeAds: SwiftViewAds {
    
    private var rawAd: NativeAd? = nil
    var nativeLoadDelegate: NativeLoadDelegate?
    var adValue: AdValue?
    
    override init(platformAdUnit: String,ttl: Int) {
        super.init(platformAdUnit: platformAdUnit, ttl: ttl)
        platform = "admob"
        setInfo(key: "platform", info: platform)
    }
    
    deinit {
        print("admob native ad deinit")
    }
    
    func setRawAd(nativeAd: NativeAd?) {
        self.rawAd = nativeAd
        self.rawAd?.paidEventHandler = { (adValue) in self.handleAdmobAdValue(adValue: adValue)}
        AdmobUtils.resolveResponseInfo(ads: self, responseInfo: self.rawAd?.responseInfo.loadedAdNetworkResponseInfo)
    }
    
    func getView() -> UIView? {
        return Bundle.main.loadNibNamed(
                "NativeAdView",
                owner: nil,
                options: nil)?.first as! NativeAdView
    }
    
    private func handleAdmobAdValue(adValue: AdValue) {
        self.adValue = adValue
        AdmobUtils.resolveAdmobPaidInfo(ads: self, adValue: adValue)
        self.interactionCallback?.onAdsPaid()
    }
    
    override func getUSDMicros() -> Double {
        return adValue?.value.doubleValue ?? 0
    }
}

class NativeLoadDelegate:NSObject, NativeAdLoaderDelegate {
    var completion: (NativeAd?,String) -> Void
    
    init(completion: @escaping (NativeAd?,String) -> Void) {
        self.completion = completion
    }
    
    func adLoader(_ adLoader: AdLoader, didReceive nativeAd: NativeAd) {
        print("native load delegate success")
        completion(nativeAd,"")
    }
    
    func adLoader(_ adLoader: AdLoader, didFailToReceiveAdWithError error: any Error) {
        print("native load delegate error: \(error.localizedDescription)")
        completion(nil,error.localizedDescription)
    }
    
    deinit {
        print("native load delegate deinit")
    }
}
