//
//  RedditService.swift
//  DevigetTest
//
//  Created by Ignacio Zunino on 29/09/2020.
//

import Foundation

struct RedditItem: Codable, Equatable {
    let author: String
    let title: String
    let name: String
    let thumbnail: String?

    enum CodingKeys: String, CodingKey {
        case kind = "kind"
        case data = "data"
        case title = "title"
        case author = "author"
        case name = "name"
        case thumbnail = "thumbnail"

    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let data = try container.nestedContainer(keyedBy: CodingKeys.self, forKey: .data)
        
        author = try data.decode(String.self, forKey: .author)
        title = try data.decode(String.self, forKey: .title)
        name = try data.decode(String.self, forKey: .name)
        thumbnail = try? data.decode(String.self, forKey: .thumbnail)

    }
    
    func encode(to encoder: Encoder) throws {
        //not needed for the test
    }
    
}

struct RedditResponse: Codable {
    
    var items: [RedditItem]

    // MARK: - Codable
    // Coding Keys
    enum CodingKeys: String, CodingKey {
        case author = "author"
        case title = "title"
        case data = "data"
        case children = "children"
    }
    // Decoding
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let data = try container.nestedContainer(keyedBy: CodingKeys.self, forKey: .data)
        
        items = try data.decode([RedditItem].self, forKey: .children)
    }
    
    // Encoding
    func encode(to encoder: Encoder) throws {
    }
}

final class RedditService {
        
    private let limitToLoad = 40
    
    func fetchTop(after: RedditItem? = nil, done: @escaping (RedditResponse) -> Void) {
        
        if let prevData = UserDefaults.standard.object(forKey: "top") as? Data {
            let decoder = JSONDecoder()
            if let loadedData = try? decoder.decode(RedditResponse.self, from: prevData) {
                done(loadedData)
            }
        }
        
        let defaultSession = URLSession(configuration: .default)

        var dataTask: URLSessionDataTask!
                    
        if var urlComponents = URLComponents(string: "https://www.reddit.com/r/popular/top.json") {
            var query = "limit=\(limitToLoad)"
            if let afterItem = after {
                query = query + "&after=\(afterItem.name)"
            }
            urlComponents.query = query
          guard let url = urlComponents.url else {
            return
          }
                        
          dataTask = defaultSession.dataTask(with: url) { data, response, error in
              if let data = data,
              let response = response as? HTTPURLResponse,
              response.statusCode == 200 {
                let response = try! JSONDecoder().decode(RedditResponse.self, from: data)
                
                let encoder = JSONEncoder()
                if let encoded = try? encoder.encode(response) {
                    let defaults = UserDefaults.standard
                    defaults.set(encoded, forKey: "top")
                }
                
                DispatchQueue.main.async {
                    done(response)
                }
                
              }
          }
            
          dataTask?.resume()
                
        }
    
    }
}
