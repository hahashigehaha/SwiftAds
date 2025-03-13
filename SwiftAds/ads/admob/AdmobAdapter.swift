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
        return await withCheckedContinuation { continuation in
                let adLoader = AdLoader( adUnitID: adUnitId,rootViewController: nil,adTypes: [.native], options: nil)
                adLoader.delegate = NativeLoadDelegate { adResult,reason in
                    var swiftViewAds: AdmobNativeAds? = nil
                    if adResult != nil {
                        swiftViewAds = AdmobNativeAds(platformAdUnit: adUnitId, ttl: ttl)
                        swiftViewAds?.setRawAd(nativeAd: adResult)
                    }
                    continuation.resume(returning: (swiftViewAds,reason))
                }
                adLoader.load(Request())
            }
    }
    
    private func requestBannerAd(adUnitId: String,ttl: Int) async -> (adResult: SwiftViewAds?, reason: String) {
        let semaphore = DispatchSemaphore(value: 0)
        await MainActor.run {
            let bannerView = BannerView(adSize: AdSize())
            bannerView.delegate = BannerLoadDelegate {adResult, reason in
                var swiftViewAds: AdmobBannerAds? = nil
                if adResult != nil {
                    swiftViewAds = AdmobBannerAds(platformAdUnit: adUnitId, ttl: ttl)
                    swiftViewAds?.setRawAd(bannerAd: adResult)
                }
                semaphore.signal() // 通知信号量
            }
            bannerView.load(Request())
        }
        semaphore.wait() // 等待信号量
        return (nil , "")
    }
    
    class NativeLoadDelegate:NSObject, NativeAdLoaderDelegate {
        var completion: (NativeAd?,String) -> Void
        
        init(completion: @escaping (NativeAd?,String) -> Void) {
            self.completion = completion
        }
        
        func adLoader(_ adLoader: AdLoader, didReceive nativeAd: NativeAd) {
            completion(nativeAd,"")
        }
        
        func adLoader(_ adLoader: AdLoader, didFailToReceiveAdWithError error: any Error) {
            completion(nil,error.localizedDescription)
        }
    }
    
    class BannerLoadDelegate:NSObject,BannerViewDelegate {
        
        var completion: (BannerView?,String) -> Void
        
        init(completion: @escaping (BannerView?,String) -> Void) {
            self.completion = completion
        }
        
        func bannerViewDidReceiveAd(_ bannerView: BannerView) {
            completion(bannerView,"")
        }
        
        func bannerView(_ bannerView: BannerView, didFailToReceiveAdWithError error: any Error) {
            completion(nil,error.localizedDescription)
        }
    }
    
}
