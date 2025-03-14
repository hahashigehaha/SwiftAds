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
    var adValue: AdValue?
    
    override init(platformAdUnit: String,ttl: Int) {
        super.init(platformAdUnit: platformAdUnit, ttl: ttl)
        platform = "admob"
    }
    
    func setRawAd(bannerAd: BannerView?) {
        self.rawAd = bannerAd
        self.rawAd?.paidEventHandler = { (adValue) in self.handleAdmobAdValue(adValue: adValue)}
        AdmobUtils.resolveResponseInfo(ads: self, responseInfo: self.rawAd?.responseInfo?.loadedAdNetworkResponseInfo)
    }
    
    override func view() -> UIView? {
        return rawAd
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
