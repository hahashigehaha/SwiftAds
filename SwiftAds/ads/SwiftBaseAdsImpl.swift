//
//  SwiftBaseAdsImpl.swift
//  SwiftAds
//
//  Created by lbe on 2025/3/13.
//
import Foundation

class SwiftBaseAdsImpl:NSObject , SwiftAds {
    
    var platform: String = ""
    
    var platformAdUnit: String = ""
    
    var uuid: String = ""
    
    var loadEndTime: Int = 0
    
    var ttl: Int = 1_800_000
    
    var infoList: [String : Any] = [String : Any]()
    
    override init() {
        super.init()
        loadEndTime = currentTimeMillis()
        self.uuid = UUID().uuidString
        setInfo(key: "uuid", info: self.uuid)
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
    
    func getRawAd() -> Any? {
        return nil
    }
    
    func getUSDMicros() -> Double {
        return 0
    }
    
    func setInteractionCallback(callback: any InteractionCallback) {
    }
    
    private func currentTimeMillis() -> Int {
        let dispatchTime = DispatchTime.now()
        let nanoseconds = dispatchTime.uptimeNanoseconds
        return Int(nanoseconds / 1_000_000)
        
    }
}
