//
//  AdmobUtils.swift
//  SwiftAds
//
//  Created by lbe on 2025/3/14.
//
import GoogleMobileAds

struct AdmobUtils {
    
    static func resolveAdmobPaidInfo(ads: SwiftAds?,adValue: AdValue) {
        let currencyCode = adValue.currencyCode
        let precision = adValue.precision
        let price = adValue.value
        
        ads?.setInfo(key: "price", info: price)
        ads?.setInfo(key: "precision", info: precision.rawValue)
        ads?.setInfo(key: "currency_code", info: currencyCode)
    }
        
    static func resolveResponseInfo(ads: SwiftAds?,responseInfo: AdNetworkResponseInfo?) {
        let networkClassName = responseInfo?.adNetworkClassName
        let sourceId = responseInfo?.adSourceID
        let sourceName = responseInfo?.adSourceName
        
        ads?.setInfo(key: "admob_network_name", info: networkClassName ?? "")
        ads?.setInfo(key: "admob_source_id", info: sourceId ?? "")
        ads?.setInfo(key: "admob_source_name", info: sourceName ?? "")
        
        ads?.setInfo(key: "media_source_name", info: translateAdSourceId(sourceId: sourceId))
    }
    
    private static func translateAdSourceId(sourceId: String?) -> String {
        switch sourceId {
            case "5450213213286189855", "7068401028668408324", "6060308706800320801":
                return "admob"

            case "1063618907739174004", "1328079684332308356":
                return "applovin"

            case "1953547073528090325", "4692500501762622185":
                return "vungle"

            case "3525379893916449117":
                return "pangle"

            case "4970775877303683148":
                return "unity"

            case "10568273599589928883", "11198165126854996598":
                return "facebook"

            case "7681903010231960328", "6325663098072678541":
                return "inmboi"

            case "6925240245545091930":
                return "ironsource"

            case "7295217276740746030", "4692500501762622178":
                return "tapjoy"

            case "15586990674969969776", "4600416542059544716", "6895345910719072481":
                return "adcolony"

            case "6250601289653372374":
                return "mintegral"

            default:
                return "unknown"
            }
    }
}

