//
//  AdmobViewAds.swift
//  SwiftAds
//
//  Created by lbe on 2025/3/13.
//
import GoogleMobileAds

class AdmobBannerAds: SwiftViewAds {
    
    private var rawAd: BannerView?
    
    init(platformAdUnit: String,ttl: Int) {
        super.init()
        platform = "admob"
        self.ttl = ttl
        self.platformAdUnit = platformAdUnit
        setInfo(key: "platform", info: self.platform)
        setInfo(key: "ad_unit_id", info: self.platformAdUnit)
    }
    
    func setRawAd(bannerAd: BannerView?) {
        self.rawAd = bannerAd
    }
    
    override func view() -> UIView? {
        return rawAd
    }
    
}
