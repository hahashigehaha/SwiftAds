//
//  MaxAdapter.swift
//  SwiftAds
//
//  Created by lbe on 2025/3/11.
//
class MaxAdapter: AdsAdapter {
    func loadFullScreenAds(config: [String : Any]) async -> (adResult: SwiftFullScreenAds?, reason: String) {
        return (nil,"")
    }
    
    func loadViewAds(config: [String : Any]) async -> (adResult: SwiftViewAds?, reason: String) {
        return (nil,"")
    }
    
    

    
    func initAdapter(config: [String : Any]) {
        
    }
    
    
}


