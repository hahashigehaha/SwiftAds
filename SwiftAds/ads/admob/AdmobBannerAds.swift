//
//  AdmobViewAds.swift
//  SwiftAds
//
//  Created by lbe on 2025/3/13.
//
import GoogleMobileAds

class AdmobBannerAds: SwiftViewAds {
    
    private var rawAd: BannerView?
    var bannerLoadDelegate: BannerLoadDelegate?
    
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


class BannerLoadDelegate:NSObject,BannerViewDelegate {
    
    var completion: (BannerView?,String) -> Void
    
    init(completion: @escaping (BannerView?,String) -> Void) {
        self.completion = completion
    }
    
    func bannerViewDidReceiveAd(_ bannerView: BannerView) {
        print("admob adapter banner load delegate success")
        completion(bannerView,"")
    }
    
    func bannerView(_ bannerView: BannerView, didFailToReceiveAdWithError error: any Error) {
        print("admob adapter banner load delegate : \(error.localizedDescription)")
        completion(nil,error.localizedDescription)
    }
}
