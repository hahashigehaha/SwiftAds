//
//  SwiftBaseAdsImpl.swift
//  SwiftAds
//
//  Created by lbe on 2025/3/13.
//
import Foundation

class SwiftBaseAdsImpl:NSObject, SwiftAds{
    
    var platform: String = ""
    
    var platformAdUnit: String = ""
    
    var uuid: String = ""
    
    var loadEndTime: Int = 0
    
    var ttl: Int = 1_800_000
    
    var infoList: [String : Any] = [String : Any]()
    
    var interactionCallback: InteractionCallback?
    
    var adsManager: AdManager?
    
    init(platformAdUnit: String,ttl: Int) {
        super.init()
        self.ttl = ttl
        self.platformAdUnit = platformAdUnit
        
        self.uuid = UUID().uuidString
        self.loadEndTime = currentTimeMillis()
        adsManager = AdManager.shared
        
        setInfo(key: "uuid", info: self.uuid)
        setInfo(key: "platform", info: self.platform)
        setInfo(key: "ad_unit_id", info: self.platformAdUnit)
    }
    
    func isExpired() -> Bool {
        return (loadEndTime + ttl) < currentTimeMillis()
    }
    
    func setInfo(key: String, info: Any) {
        infoList[key] = info
    }
    
    func getInfo(key: String) -> Any? {
        return infoList[key]
    }
    
    func allInfo() -> [String : Any] {
        return infoList
    }
    
    func getUSDMicros() -> Double {
        return 0
    }
    
    func setInteractionCallback(callback: InteractionCallback?) {
        self.interactionCallback = InteractionCallbackWrapper(originalAd: self,originalCallback: callback)
    }
    
    private func currentTimeMillis() -> Int {
        return Int(Date().timeIntervalSince1970 * 1000)
    }
}

class InteractionCallbackWrapper: InteractionCallback {
    private var originalCallback: InteractionCallback?
    private var originalAd: SwiftAds?
    
    init(originalAd: SwiftAds, originalCallback: InteractionCallback?) {
        self.originalAd = originalAd
        self.originalCallback = originalCallback
    }
    
    func onAdClicked() {
        notifyClick()
        originalCallback?.onAdClicked()
    }
    
    func onAdClosed() {
        notifyClose()
        // 继续调用原始的回调
        originalCallback?.onAdClosed()
    }
    
    func onAdImpression() {
        notifyImpression()
        // 继续调用原始的回调
        originalCallback?.onAdImpression()
    }
    
    func onAdsPaid() {
        notifyPaid()
        // 继续调用原始的回调
        originalCallback?.onAdsPaid()
    }
    
    private func notifyClick() {
        AdManager.shared.notifyEvent(event: AdsConstant.ST_AD_CLICK, eventParams: buildEventParams(extraParams: nil))
    }
    
    private func notifyImpression() {
        AdManager.shared.notifyEvent(event: AdsConstant.ST_AD_IMPRESSION, eventParams: buildEventParams(extraParams: nil))
    }
    
    private func notifyPaid() {
        AdManager.shared.notifyEvent(event: AdsConstant.ST_AD_PAID, eventParams: buildEventParams(extraParams: nil))
    }
    
    private func notifyClose() {
        AdManager.shared.notifyEvent(event: AdsConstant.ST_AD_CLOSE, eventParams: buildEventParams(extraParams: nil) )
    }
    
    private func buildEventParams(extraParams: [String: Any]?) -> [String: Any] {
        var params = extraParams ?? [:]
        // 合并 ad.allInfo() 字典
        if let adInfo = originalAd?.allInfo() {
            params.merge(adInfo) { (current, _) in current }
        }
        return params
    }
}
