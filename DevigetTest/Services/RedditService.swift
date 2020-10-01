//
//  RedditService.swift
//  DevigetTest
//
//  Created by Ignacio Zunino on 29/09/2020.
//

import Foundation

struct RedditItem: Codable, Equatable {
    static func == (lhs: RedditItem, rhs: RedditItem) -> Bool {
        return lhs.name == rhs.name
    }

    let author: String
    let title: String
    let name: String
    let thumbnail: URL?
    let fullSizeImage: URL?
    
    let createdAt: Date
    
    let numComments: Int
    
    var read = false
    
    struct ImageSource: Codable {
        let url: String
    }
    
    struct Image: Codable {
        let source: ImageSource
    }
    
    struct Preview: Codable {
        let images: [Image]
    }

    enum CodingKeys: String, CodingKey {
        case data = "data"
        case title = "title"
        case author = "author"
        case name = "name"
        case thumbnail = "thumbnail"
        case preview = "preview"
        case images = "images"
        case createdUTC = "created_utc"
        case numComments = "num_comments"
        case fullSizeImage = "fullSizeImage"

    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let data = try container.nestedContainer(keyedBy: CodingKeys.self, forKey: .data)
        
        author = try data.decode(String.self, forKey: .author)
        title = try data.decode(String.self, forKey: .title)
        name = try data.decode(String.self, forKey: .name)
        
        if let thumbnailString = try? data.decode(String.self, forKey: .thumbnail) {
            
            let validURL = thumbnailString.validateUrl()
            
            thumbnail = validURL ? URL(string: thumbnailString) : nil
        } else {
            thumbnail = nil
        }
        
        let preview = try? data.decode(Preview.self, forKey: .preview)
                
        let createdAtUTC = try data.decode(Double.self, forKey: .createdUTC)
        
        createdAt = Date(timeIntervalSince1970: createdAtUTC)
        
        numComments = (try? data.decode(Int.self, forKey: .numComments)) ?? 0
        
        //to simplify our own encoding the full size image is set at the same level as the rest of the properties
        if let fullSizeImageString = try? data.decode(String.self, forKey: .fullSizeImage) {
            fullSizeImage = URL(string: fullSizeImageString)
        } else {
            
            if var imageString = preview?.images.first?.source.url {
                imageString = imageString.unescapingURLCharacters()
                
                //some urls had a 'default' string in it so it needs to be validated:
                let validURL = imageString.validateUrl()
                fullSizeImage = validURL ? URL(string: imageString) : nil
            } else {
                fullSizeImage = nil
            }
        }

    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        var data = container.nestedContainer(keyedBy: CodingKeys.self, forKey: .data)
        
        try data.encode(name, forKey: .name)
        try data.encode(author, forKey: .author)
        try data.encode(title, forKey: .title)
        try data.encode(createdAt.timeIntervalSince1970, forKey: .createdUTC)

        if let image = fullSizeImage {
            try data.encode(image.absoluteString, forKey: .fullSizeImage)
        }

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
    private var readItems: [String: Bool]
    
    init() {
        readItems = UserDefaults.standard.dictionary(forKey: "readItems") as? [String: Bool] ?? [:]
    }
    
    func fetchTop(after: RedditItem? = nil, done: @escaping (RedditResponse) -> Void) {

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
                                    
          dataTask = defaultSession.dataTask(with: url) {[weak self] data, response, error in
            
            guard let sself = self else {
                return
            }
              if let data = data,
              let response = response as? HTTPURLResponse,
              response.statusCode == 200 {
                var response = try! JSONDecoder().decode(RedditResponse.self, from: data)
                
                response.items = response.items.map({ (item) -> RedditItem in
                    if (sself.readItems[item.name] ?? false) {
                        var readItem = item
                        readItem.read = true
                        return readItem
                    } else {
                        return item
                    }
                })
                
                DispatchQueue.main.async {
                    done(response)
                }
                
              }
          }
            
          dataTask?.resume()
                
        }
    
    }
    
    //ideally this  should be in a separate model layer
    func setItemAsRead(item: RedditItem) {
        readItems[item.name] = true
        UserDefaults.standard.set(readItems, forKey: "readItems")
    }
}
