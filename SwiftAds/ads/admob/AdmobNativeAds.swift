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
    
    init(platformAdUnit: String,ttl: Int) {
        super.init()
        platform = "admob"
        self.ttl = ttl
        self.platformAdUnit = platformAdUnit
        setInfo(key: "platform", info: self.platform)
        setInfo(key: "ad_unit_id", info: self.platformAdUnit)
    }
    
    deinit {
        print("admob native ad deinit")
    }
    
    func setRawAd(nativeAd: NativeAd?) {
        self.rawAd = nativeAd
    }
    
    func getView() -> UIView? {
        return Bundle.main.loadNibNamed(
                "NativeAdView",
                owner: nil,
                options: nil)?.first as! NativeAdView
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
