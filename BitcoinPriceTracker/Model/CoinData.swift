//
//  CoinData.swift
//  BitcoinPriceTracker
//
//  Created by Lenildo Melo on 02/10/24.
//

import Foundation

struct CoinData: Codable {
    let time: String
    let asset_id_base: String
    let asset_id_quote: String
    let rate: Double
}
