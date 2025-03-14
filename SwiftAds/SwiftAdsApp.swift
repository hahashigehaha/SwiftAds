//
//  SwiftAdsApp.swift
//  SwiftAds
//
//  Created by lbe on 2025/3/5.
//

import UIKit
import SwiftUI

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        initAds()
        AdsManager.shared.addEventDelegate(self)
        test()
        return true
    }
}

extension AppDelegate: SwiftEventDelegate {
    func onEvent(eventName: String, params: [String : Any]) {
        print("event: \(eventName)  params: \(params)")
    }
}

@main
struct MyApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

func initAds() {
    let adsConfigJson = readJSONStringFromResources(filename: "page_ads_test") ?? ""
    AdsManager.shared.updateAdsConfig(configJson: adsConfigJson)
    print("current ads config version : \(AdsManager.shared.getConfigVersion())")
}

private func test() {
    // 开启异步检查任务，一分钟检查一次，如果广告过期及时补充新广告
    Task {
//        while(true) {
            try await Task.sleep(nanoseconds: 70 * 1_000_000_000)
            loadAds()
//        }
    }
    
    AdsManager.shared.startAutoFill()
}

var testAd: SwiftFullScreenAds?
var fullscreenDelegate: FullScreenInteractionDelegate?

func loadAds() {
    Task {
        let loader = AdsManager.shared.globalAdsLoader(pageName: "interstitial_standalone")
        testAd = await loader.fetch()
        await MainActor.run {
            testAd?.setInteractionCallback(callback: fullscreenDelegate)
            testAd?.setInfo(key: "scene", info: "scene_name")
            testAd?.show()
        }
    }
}

func readJSONStringFromResources(filename: String) -> String? {
    // 获取文件路径
    if let path = Bundle.main.path(forResource: filename, ofType: "json") {
        do {
            // 读取文件内容为字符串
            let jsonString = try String(contentsOfFile: path, encoding: .utf8)
            return jsonString
        } catch {
            // 处理错误
            print("Error reading JSON file: \(error)")
        }
    } else {
        print("File not found in Resources folder")
    }
    return nil
}

class FullScreenInteractionDelegate: InteractionCallback {
    func onAdClicked() {
        print("full screen ad click")
    }
    
    func onAdClosed() {
        print("full screen ad close")
    }
    
    func onAdImpression() {
        print("full screen ad impression")
    }
    
    func onAdsPaid() {
        print("full screen ad paid")
    }
    
    
}
