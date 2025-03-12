//
//  DelegateTest.swift
//  SwiftAds
//
//  Created by lbe on 2025/3/12.
//

import GoogleMobileAds
class DelegateTest:NSObject, FullScreenContentDelegate {
    
    static let shared = DelegateTest()
    
    func ad(_ ad: any FullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: any Error) {
        print("App Open Ad failed to present with error: \(error.localizedDescription)")
    }
    
    func adWillPresentFullScreenContent(_ ad: any FullScreenPresentingAd) {
        print("admob fullscreen ads will impression")
    }
    
    func adDidRecordImpression(_ ad: any FullScreenPresentingAd) {
        print("admob fullscreen ads did impression")
    }
    
    func adDidRecordClick(_ ad: any FullScreenPresentingAd) {
        print("admob fullscreen ads did click")
    }
    
    func adDidDismissFullScreenContent(_ ad: any FullScreenPresentingAd) {
        print("admob fullscreen ads did dismiss")
    }
    
}
