//
//  CoronaClient.swift
//  CoronaTracker
//
//  Created by Aaryan Kothari on 17/05/20.
//  Copyright © 2020 Aaryan Kothari. All rights reserved.
//

import Foundation

class CoronaClient {
    
    //MARK:- ENDPOINT URLS
    enum Endpoints {
        
        static let base = "https://api.covid19api.com"
        
        case countries
        case summary
        case dayone(country:String)
        case dayonelive(country:String)
        case dayonetotal(country:String)
        
        var stringValue : String{
            switch self {
            case .countries:
                return Endpoints.base + "/countries"
            case .summary:
                return Endpoints.base + "/summary"
            case .dayone(let country):
                 return Endpoints.base + "/dayone/country/\(country)"
            case .dayonelive(let country):
                return Endpoints.base + "/dayone/country/\(country)/status/confirmed/live"
            case .dayonetotal(let country):
                return Endpoints.base + "/dayone/country/\(country)/status/confirmed"
            }
        }
        
        var url : URL {
            return URL(string: self.stringValue)!
        }
    }
    
    
    //MARK:- GET REQUEST
    class func taskForGETRequest<ResponseType: Decodable>(url: URL, responseType: ResponseType.Type, completion: @escaping (ResponseType?, Error?) -> Void){
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data else {
                DispatchQueue.main.async {
                    completion(nil, error)
                }
                return
            }
            let decoder = JSONDecoder()
            do {
                let responseObject = try decoder.decode(ResponseType.self, from: data)
                DispatchQueue.main.async {
                    completion(responseObject, nil)
                }
            } catch {
                    completion(nil, error)
            }
        }
        task.resume()
    }
    
    class func FetchAllCountries(completion: @escaping ([CountryStruct], Error?) -> Void) {
        taskForGETRequest(url: Endpoints.countries.url, responseType: CountryData.self) { (response, error) in
            if let response = response{
                completion(response.countries,nil)
                return
            }
            completion([],error)
        }
    }
    
    class func getSummary(completion: @escaping (Summary?, Error?) -> Void) {
        taskForGETRequest(url: Endpoints.summary.url, responseType: Summary.self) { (response, error) in
            if let response = response{
                completion(response,nil)
                return
            }
            completion(nil,error)
        }
    }
    
}
