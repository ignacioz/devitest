//
//  RedditItem.swift
//  DevigetTest
//
//  Created by Ignacio Zunino on 01/10/2020.
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
        case read = "read"

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
        
        read = (try? data.decode(Bool.self, forKey: .read)) ?? false

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
        try data.encode(numComments, forKey: .numComments)
        try data.encode(thumbnail?.absoluteURL, forKey: .thumbnail)
        try data.encode(read, forKey: .read)

        try data.encode(createdAt.timeIntervalSince1970, forKey: .createdUTC)

        if let image = fullSizeImage {
            try data.encode(image.absoluteString, forKey: .fullSizeImage)
        }

    }
    
}
