//
//  MaxAdapter.swift
//  SwiftAds
//
//  Created by lbe on 2025/3/11.
//
class MaxAdapter: AdsAdapter {
    func loadFullScreenAds(config: [String : Any]) async -> (adResult: (any SwiftFullScreenAds)?, reson: String?) {
        return (nil,"")
    }
    
    func loadViewAds(config: [String : Any]) async -> (adResult: (any SwiftViewAds)?, reson: String?) {
        return (nil,"")
    }

    
    func initAdapter(config: [String : Any]) {
        
    }
    
    
}


