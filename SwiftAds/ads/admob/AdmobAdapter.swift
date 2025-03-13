//
//  AdmobAdapter.swift
//  SwiftAds
//
//  Created by lbe on 2025/3/6.
//

import GoogleMobileAds


class AdmobAdapter<T: SwiftAds>: NSObject, AdsAdapter {
            
    func initAdapter(config: [String : Any]) {
        MobileAds.shared.start { InitializationStatus in
            print("admob init over")
        }
    }
    
    func loadFullScreenAds(config: [String : Any]) async -> (adResult: T?, reson: String?) {
        print("adamob adapter load fullscreen ads: \(config)")
        guard let adUnitId = config["adUnitId"] as? String else {
            return (nil,"ad unit is empty")
        }
        let adType = config["adType"] as? String
        
        if adType == "interstitial" {
            return await requestInterstitialAd(adUnitID: adUnitId)
        } else if adType == "appopen" {
            return await requestAppOpenAd(adUnitID: adUnitId)
        } else if adType == "reward" {
            return await requestRewardAd(adUnitID: adUnitId)
        }
        return (nil,"")
    }
    
    func loadViewAds(config: [String : Any]) async -> (adResult: T?,reson: String?) {
        
        return (nil,"")
    }
    
    private func requestAppOpenAd(adUnitID: String) async -> (adResult: T?,reson: String){
        do {
            let appOpenAd = try await AppOpenAd.load(with: adUnitID, request: Request())
            
            let swiftFullScreenAds = AdmobFullScreenAds(platformAdUnit: adUnitID)
            swiftFullScreenAds.setRawAd(rawAd: appOpenAd)
            return (swiftFullScreenAds as? T,"")
        } catch {
            print("request app open ad catch \(error.localizedDescription)")
            return (nil,error.localizedDescription)
        }
    }
    
    private func requestInterstitialAd(adUnitID: String) async -> (adResult: T?,reson: String){
        do {
            let interstitialAd = try await InterstitialAd.load(with: adUnitID, request: Request())
            
            let swiftFullScreenAds = AdmobFullScreenAds(platformAdUnit: adUnitID)
            swiftFullScreenAds.setRawAd(rawAd: interstitialAd)
            return (swiftFullScreenAds as? T,"")
        } catch {
            print("request admob interstitial ad catch \(error.localizedDescription)")
            return (nil,error.localizedDescription)
        }
    }
        
    private func requestRewardAd(adUnitID: String) async -> (adResult: T?,reson: String){
        do {
            let rewardAd = try await RewardedAd.load(with: adUnitID, request: Request())
            
            let swiftFullScreenAds = AdmobFullScreenAds(platformAdUnit: adUnitID)
            swiftFullScreenAds.setRawAd(rawAd: rewardAd)
            return (swiftFullScreenAds as? T,"")
        } catch {
            print("request admob interstitial ad catch \(error.localizedDescription)")
            return (nil,error.localizedDescription)
        }
    }
    
}
