//
//  Api.swift
//  News
//
//  Created by Александр Осипов on 08.05.2020.
//  Copyright © 2020 Александр Осипов. All rights reserved.
//

import Foundation
import UIKit

struct APIConstants {
    // News  API key url: https://newsapi.org
    static let apiKey: String = "dad56f872c6e425f8992c93c87060824"//"API_KEY"
    
    static let jsonDecoder: JSONDecoder = {
     let jsonDecoder = JSONDecoder()
     jsonDecoder.keyDecodingStrategy = .convertFromSnakeCase
     let dateFormatter = DateFormatter()
     dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
     jsonDecoder.dateDecodingStrategy = .formatted(dateFormatter)
        return jsonDecoder
    }()
    
     static let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }()
}

enum Endpoint {
    case topHeadLines
    case articlesFromCategory(_ category: String)
    case articlesFromSource(_ source: String)
    case search (searchFilter: String)
    case sources (country: String)
    
    var baseURL: URL {URL(string: "https://newsapi.org/v2/")!}
    
    func path() -> String {
        switch self {
        case .topHeadLines, .articlesFromCategory:
            return "top-headlines"
        case .search,.articlesFromSource:
            return "everything"
        case .sources:
            return "sources"
        }
    }
    
    var absoluteURL: URL? {
        let queryURL = baseURL.appendingPathComponent(self.path())
        let components = URLComponents(url: queryURL, resolvingAgainstBaseURL: true)
        guard var urlComponents = components else {
            return nil
        }
        switch self {
        case .topHeadLines:
            urlComponents.queryItems = [URLQueryItem(name: "country", value: region),
                                        URLQueryItem(name: "apikey", value: APIConstants.apiKey)
                                       ]
        case .articlesFromCategory(let category):
            urlComponents.queryItems = [URLQueryItem(name: "country", value: region),
                                        URLQueryItem(name: "category", value: category),
                                        URLQueryItem(name: "apikey", value: APIConstants.apiKey)
                                        ]
        case .sources (let country):
            urlComponents.queryItems = [URLQueryItem(name: "country", value: country),
                                        URLQueryItem(name: "language", value: countryLang[country]),
                                        URLQueryItem(name: "apikey", value: APIConstants.apiKey)
                                       ]
        case .articlesFromSource (let source):
            urlComponents.queryItems = [URLQueryItem(name: "sources", value: source),
                                      /*  URLQueryItem(name: "language", value: locale),*/
                                        URLQueryItem(name: "apikey", value: APIConstants.apiKey)
                                       ]
        case .search (let searchFilter):
            urlComponents.queryItems = [URLQueryItem(name: "q", value: searchFilter.lowercased()),
                                       /*URLQueryItem(name: "language", value: locale),*/
                                       /* URLQueryItem(name: "country", value: region),*/
                                        URLQueryItem(name: "apikey", value: APIConstants.apiKey)
                                      ]
        }
        return urlComponents.url
    }
    
    var locale: String {
        return  Locale.current.languageCode ?? "en"
    }
    
    var region: String {
        return  Locale.current.regionCode?.lowercased() ?? "us"
    }
    
    init? (index: Int, text: String = "sports") {
        switch index {
        case 0: self = .topHeadLines
        case 1: self = .search(searchFilter: text)
        case 2: self = .articlesFromCategory(text)
        case 3: self = .articlesFromSource(text)
        case 4: self = .sources (country: text)
        default: return nil
        }
    }
    
    var countryLang : [String: String]  {return [
      "ar": "es",  // argentina
      "au": "en",  // australia
      "br": "es",  // brazil
      "ca": "en",  // canada
      "cn": "cn",  // china
      "de": "de",  // germany
      "es": "es",  // spain
      "fr": "fr",  // france
      "gb": "en",  // unitedKingdom
      "hk": "cn",  // hongKong
      "ie": "en",  // ireland
      "in": "en",  // india
      "is": "en",  // iceland
      "il": "he",  // israil for sources - language
      "it": "it",  // italy
      "nl": "nl",  // netherlands
      "no": "no",  // norway
      "ru": "ru",  // russia
      "sa": "ar",  // saudiArabia
      "us": "en",  // unitedStates
      "za": "en"   // southAfrica
      ]
    }
}

class NewsAPI {
    static let shared = NewsAPI()
    var urlString = ""
    
    func request(urlString: String, completion: @escaping (Result<Data, Error>) -> Void) {
        guard let url = URL(string: urlString) else { return }
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let data = data else { return }
            completion(.success(data))
        }.resume()
    }
    
    func fetchTracksSource(for country: String, response: @escaping (SourcesResponse?) -> Void) {
        
        urlString = Endpoint.sources(country: country).absoluteURL?.absoluteString ?? ""
        
        request(urlString: urlString) { (result) in
            switch result {
            case .success(let data):
                do {
                    let tracks = try JSONDecoder().decode(SourcesResponse.self, from: data)
                    response(tracks)
                } catch let jsonError {
                    print("Failed to decode JSON", jsonError)
                    response(nil)
                }
            case .failure(let error):
                print("Error received requesting data: \(error.localizedDescription)")
                response(nil)
            }
        }
    }
    
    func fetchTracksArticles(for sources: String, response: @escaping (NewsResponse?) -> Void) {
        
        urlString = Endpoint.articlesFromSource(sources).absoluteURL?.absoluteString ?? ""
        
        request(urlString: urlString) { (result) in
            switch result {
            case .success(let data):
                do {
                    let tracks = try JSONDecoder().decode(NewsResponse.self, from: data)
                    response(tracks)
                } catch let jsonError {
                    print("Failed to decode JSON", jsonError)
                    response(nil)
                }
            case .failure(let error):
                print("Error received requesting data: \(error.localizedDescription)")
                response(nil)
            }
        }
    }
    
    func fetchSearchTracksArticles(for search: String, response: @escaping (NewsResponse?) -> Void) {
        
        urlString = Endpoint.search(searchFilter: search).absoluteURL?.absoluteString ?? ""
        
        request(urlString: urlString) { (result) in
            switch result {
            case .success(let data):
                do {
                    let tracks = try JSONDecoder().decode(NewsResponse.self, from: data)
                    response(tracks)
                } catch let jsonError {
                    print("Failed to decode JSON", jsonError)
                    response(nil)
                }
            case .failure(let error):
                print("Error received requesting data: \(error.localizedDescription)")
                response(nil)
            }
        }
    }
    
    func loadImage(urlImage: String) -> UIImage {
        let dataImage = try? Data(contentsOf: URL(string: urlImage)!)
        return UIImage(data: dataImage ?? Data()) ?? UIImage()
    }
    
    func setData(from url: URL) -> Data {
        var dataS: Data?
        getData(from: url) { data, response, error in
            guard let data = data, error == nil else { return }
            DispatchQueue.main.async() {
                 dataS = data
            }
        }
        if let data = dataS {
            return data
        } else {
            return Data()
        }
        
    }
    private func getData(from url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        URLSession.shared.dataTask(with: url, completionHandler: completion).resume()
    }
}
