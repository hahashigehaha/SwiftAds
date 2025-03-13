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
        AdManager.shared.addEventDelegate(self)
        loadAds()
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
    AdManager.shared.updateAdsConfig(configJson: adsConfigJson)
    print("current ads config version : \(AdManager.shared.getConfigVersion())")
}

func loadAds() {
    Task {
        let loader = AdManager.shared.globalAdsLoader(pageName: "native3")
        let ad: SwiftViewAds? = await loader.fetch()
        await MainActor.run {
            let adView = ad?.view()
            print("adview : \(adView == nil)")
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
