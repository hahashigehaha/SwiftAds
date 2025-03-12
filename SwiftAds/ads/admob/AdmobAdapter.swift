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
    
    func loadFullScreenAds(config: [String : Any]) async -> (any SwiftFullScreenAds)? {
        print("adamob adapter load fullscreen ads: \(config)")
        guard let adUnitId = config["adUnitId"] as? String else {
            return nil
        }
        let adType = config["adType"] as? String
        
        if adType == "interstitial" {
            return await requestInterstitialAd()
        } else if adType == "appopen" {
            return await requestAppOpenAd(adUnitID: adUnitId)
        } else if adType == "reward" {
            return nil
        }
        return nil
    }
    
    func loadViewAds(config: [String : Any]) async -> SwiftViewAds? {
        
        return nil
    }
    
    private func requestAppOpenAd(adUnitID: String) async -> SwiftFullScreenAds?{
        do {
            let swiftFullScreenAds = AdmobFullScreenAds(platformAdUnit: adUnitID)
            let appOpenAd = try await AppOpenAd.load(with: adUnitID, request: Request())
            appOpenAd.fullScreenContentDelegate = swiftFullScreenAds
            swiftFullScreenAds.setAppOpenAd(rawAd: appOpenAd)
            print("admob adapter request app open ad result : \(appOpenAd)")
            return swiftFullScreenAds
        } catch {
        }
        return nil
    }
    
    private func requestInterstitialAd() async -> SwiftFullScreenAds?{
        
        return nil
    }
    
}
