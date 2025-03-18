//
//  AdmobAdapter.swift
//  SwiftAds
//
//  Created by lbe on 2025/3/6.
//

import GoogleMobileAds

class AdmobAdapter: NSObject, AdsAdapter {
            
    func initAdapter(config: [String : Any]) {
        MobileAds.shared.start { InitializationStatus in
            print("admob init over")
        }
    }
    
    func loadFullScreenAds(config: [String : Any]) async -> (adResult: SwiftFullScreenAds?, reason: String) {
        print("adamob adapter load fullscreen ads: \(config)")
        guard let adUnitId = config["adUnitId"] as? String else {
            return (nil,"ad unit is empty")
        }
        let adType = config["adType"] as? String
        let ttl = config["ttl"] as? Int ?? 1800000
        
        if adType == "interstitial" {
            return await requestInterstitialAd(adUnitID: adUnitId,ttl: ttl)
        } else if adType == "appopen" {
            return await requestAppOpenAd(adUnitID: adUnitId,ttl: ttl)
        } else if adType == "reward" {
            return await requestRewardAd(adUnitID: adUnitId,ttl: ttl)
        }
        return (nil,"")
    }
    
    func loadViewAds(config: [String : Any]) async -> (adResult: SwiftViewAds?, reason: String) {
        print("adamob adapter load view ads: \(config)")
        guard let adUnitId = config["adUnitId"] as? String else {
            return (nil,"ad unit is empty")
        }
        let adType = config["adType"] as? String
        let ttl = config["ttl"] as? Int ?? 1800000
        
        if adType == "native" {
            return await requestNativeAd(adUnitId: adUnitId, ttl: ttl)
        } else if adType == "banner" {
            return await requestBannerAd(adUnitId: adUnitId, ttl: ttl)
        }
        return (nil,"")
    }
    
    private func requestAppOpenAd(adUnitID: String,ttl: Int) async -> (adResult: SwiftFullScreenAds?,reason: String){
        do {
            let appOpenAd = try await AppOpenAd.load(with: adUnitID, request: Request())
            
            let swiftFullScreenAds = AdmobFullScreenAds(platformAdUnit: adUnitID,ttl: ttl)
            swiftFullScreenAds.setRawAd(rawAd: appOpenAd)
            return (swiftFullScreenAds,"")
        } catch {
            print("request app open ad catch \(error.localizedDescription)")
            return (nil,error.localizedDescription)
        }
    }
    
    private func requestInterstitialAd(adUnitID: String,ttl: Int) async -> (adResult: SwiftFullScreenAds?,reason: String){
        do {
            let interstitialAd = try await InterstitialAd.load(with: adUnitID, request: Request())

            let swiftFullScreenAds = AdmobFullScreenAds(platformAdUnit: adUnitID,ttl: ttl)
            swiftFullScreenAds.setRawAd(rawAd: interstitialAd)
            return (swiftFullScreenAds,"")
        } catch {
            print("request admob interstitial ad catch \(error.localizedDescription)")
            return (nil,error.localizedDescription)
        }
    }
        
    private func requestRewardAd(adUnitID: String,ttl: Int) async -> (adResult: SwiftFullScreenAds?,reason: String){
        do {
            let rewardAd = try await RewardedAd.load(with: adUnitID, request: Request())
            
            let swiftFullScreenAds = AdmobFullScreenAds(platformAdUnit: adUnitID,ttl: ttl)
            swiftFullScreenAds.setRawAd(rawAd: rewardAd)
            return (swiftFullScreenAds,"")
        } catch {
            print("request admob interstitial ad catch \(error.localizedDescription)")
            return (nil,error.localizedDescription)
        }
    }

    private func requestNativeAd(adUnitId: String,ttl: Int) async -> (adResult: SwiftViewAds?, reason: String) {
        var adLoader: AdLoader?
        let swiftViewAds = AdmobNativeAds(platformAdUnit: adUnitId, ttl: ttl)
        return await withCheckedContinuation { continuation in
            adLoader = AdLoader( adUnitID: adUnitId,rootViewController: nil,adTypes: [.native], options: nil)
            swiftViewAds.nativeLoadDelegate = NativeLoadDelegate { adResult,reason in
                if adResult != nil {
                    swiftViewAds.setRawAd(nativeAd: adResult)
                    continuation.resume(returning: (swiftViewAds,reason))
                } else {
                    continuation.resume(returning: (nil,reason))
                }
                print("admob adapter request native ad callback")
            }
            adLoader?.delegate = swiftViewAds.nativeLoadDelegate
            adLoader?.load(Request())
        }
    }
    
    private func requestBannerAd(adUnitId: String,ttl: Int) async -> (adResult: SwiftViewAds?, reason: String) {
        var bannerView: BannerView?
        let swiftViewAds: AdmobBannerAds = AdmobBannerAds(platformAdUnit: adUnitId, ttl: ttl)
        return await withCheckedContinuation { continuation in
            DispatchQueue.main.async {
                bannerView = BannerView(adSize: AdSize())
                swiftViewAds.bannerLoadDelegate =  BannerLoadDelegate {adResult, reason in
                    if adResult != nil {
                        swiftViewAds.setRawAd(bannerAd: adResult)
                        continuation.resume(with: .success((swiftViewAds,"")))
                    } else {
                        continuation.resume(with: .success((nil,reason)))
                    }
                }
                bannerView?.delegate = swiftViewAds.bannerLoadDelegate
                bannerView?.load(Request())
            }
        }
    }
}
