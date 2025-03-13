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
    
    init(platformAdUnit: String,ttl: Int) {
        super.init()
        platform = "admob"
        self.ttl = ttl
        self.platformAdUnit = platformAdUnit
        setInfo(key: "platform", info: self.platform)
        setInfo(key: "ad_unit_id", info: self.platformAdUnit)
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
