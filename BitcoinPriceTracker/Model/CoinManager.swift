//
//  CoinManager.swift
//  BitcoinPriceTracker
//
//  Created by Lenildo Melo on 02/10/24.
//

import Foundation

protocol CoinManagerDelegate {
    
    func didUpdateCoinPrice(currency: CoinManager, price: CoinData)
    func didFailWithError(error: Error)
}


struct CoinManager {
    
    var delegate: CoinManagerDelegate?
    
    let baseURL = "https://rest.coinapi.io/v1/exchangerate/BTC/"
    
    let currencyArray = [
        "AUD","BRL","CAD","CNY","EUR","GBP","HKD","IDR","ILS","INR","JPY","MXN","NOK","NZD","PLN","RON","RUB","SEK","SGD","USD","ZAR"
    ]
  
    func getApiKeyFromPlist() -> String? {
        let bundle = Bundle.main
        guard let path = bundle.path(forResource: "Secret", ofType: "plist"),
              let dict = NSDictionary(contentsOfFile: path) as? [String: Any],
              let apiKey = dict["API_KEY"] as? String else {
            return nil
        }
        return apiKey
    }
    
    
    func getCointPrice(for currency: String) {
    
        if let apiKey = getApiKeyFromPlist() {
            let urlString = "\(baseURL)\(currency)?apikey=\(apiKey)"
            performRequest(with: urlString)
        } else {
            print("Erro: Não foi possível obter a chave API.")
        }
        
    }

    
    func performRequest(with urlString: String) {
        
        if let url = URL(string: urlString) {
            
            let session = URLSession(configuration: .default)
            let task = session.dataTask(with: url) { data, response, error in
                if error != nil {
                    self.delegate?.didFailWithError(error: error!)
                    return
                }
                
                if let safeData = data {
                    if let coinPrice = self.parseJSON(safeData) {
                        delegate?.didUpdateCoinPrice(currency: self, price: coinPrice)
                    }
                }
                
            }
            task.resume()
        }
    }
    
    func parseJSON(_ data: Data) -> CoinData? {
        
        let decoder = JSONDecoder()
        do {
            let decodedData = try decoder.decode(CoinData.self, from: data)
            let lastPrice = decodedData.rate
            let time = decodedData.time
            let asset_id_base = decodedData.asset_id_base
            let asset_id_quote = decodedData.asset_id_quote
            
            
            let coinPrice = CoinData(time: time, asset_id_base: asset_id_base, asset_id_quote: asset_id_quote, rate: lastPrice)
            
            return coinPrice
            
        } catch {
            delegate?.didFailWithError(error: error)
            return nil
        }
        

    }
    
    

}
