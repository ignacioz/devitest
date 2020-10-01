//
//  RedditModel.swift
//  DevigetTest
//
//  Created by Ignacio Zunino on 01/10/2020.
//

import Foundation

class RedditModel {
    
    private var readItems: [String: Bool]
    private let redditService = RedditService()

    init() {
        readItems = UserDefaults.standard.dictionary(forKey: "readItems") as? [String: Bool] ?? [:]
    }
    
    func fetchTop(after: RedditItem? = nil, done: @escaping ([RedditItem]) -> Void) {
        redditService.fetchTop(after: after) {[weak self] (response) in
            
            guard let sself = self else {
                return
            }
            
            let itemsWithReadStatus = response.items.map({ (item) -> RedditItem in
                if (sself.readItems[item.name] ?? false) {
                    var readItem = item
                    readItem.read = true
                    return readItem
                } else {
                    return item
                }
            })
            
            done(itemsWithReadStatus)
        }
    }
    
    func setItemAsRead(item: RedditItem) {
        readItems[item.name] = true
        UserDefaults.standard.set(readItems, forKey: "readItems")
    }
    
}
