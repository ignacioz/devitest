//
//  RedditTableViewModel.swift
//  DevigetTest
//
//  Created by Ignacio Zunino on 30/09/2020.
//

import Foundation

final class RedditTableViewModel {
    
    enum RestorationKeys: String {
        case selection
        case items
    }
    
    private static let MaxItemsRestoration = 30
    
    var items: [RedditItem] = []
    
    var reloadAction: (() -> Void)!
    var itemRemoved: ((Int) -> Void)!
    var reloadItem: ((Int) -> Void)!
    
    var currentlySelectedItem: RedditItem?
    
    var redditModel: RedditModel!
    
    var firstTimeLoad = true
    
    init(restorationData: [String: Any]? = nil) {
        if let restorationData = restorationData {
            
            if let encodedSelection = restorationData[RestorationKeys.selection.rawValue] as? String {
                currentlySelectedItem = decodeRedditItem(item: encodedSelection)
            }
            
            let encodedItems = restorationData[RestorationKeys.items.rawValue] as? [String] ?? []
            
            encodedItems.forEach { (item) in
                items.append(decodeRedditItem(item: item))
            }
        }
    }
    
    private func decodeRedditItem(item: String) -> RedditItem {
        let decoder = JSONDecoder()
        let jsonString = item.data(using: .utf8)
        let decodedItem = try! decoder.decode(RedditItem.self, from: jsonString!)

        return decodedItem
    }
    
    func loadData(done: (() -> Void)? = nil) {
        
        if (firstTimeLoad && items.count > 0) {
            //use restored items on first launch
            reloadAction()
            done?()
            firstTimeLoad = false
            return
        }
        
        redditModel.fetchTop { [weak self] (items) in
            self?.items = items
            self?.reloadAction()
            done?()
        }
    }
    
    func loadMore(done: (() -> Void)? = nil) {
        guard let lastItem = items.last else {
            return
        }
        redditModel.fetchTop(after: lastItem) {[weak self] (items) in
            self?.items.append(contentsOf: items)
            self?.reloadAction()
            done?()
        }
    }
    
    func removeItem(item: RedditItem) {
        if let index = self.items.firstIndex(of: item) {
            self.items.remove(at: index)
            itemRemoved(index)
        }
    }
    
    func itemSelected(item: RedditItem) {
        currentlySelectedItem = item
        if (item.read) {
            return
        }
        if let index = self.items.firstIndex(of: item) {
            var newItem = item
            newItem.read = true
            self.items[index] = newItem
            reloadItem(index)
            redditModel.setItemAsRead(item: item)
        }
        
    }
    
    func encodeForRestoration() -> [String: Any] {
        //will encode currently selected item and first 20 items
        
        var restorationData: [String: Any] = [:]
        
        let encoder = JSONEncoder()
        
        if let currentlySelectedItem = currentlySelectedItem {
            let encoded = try! encoder.encode(currentlySelectedItem)
            let strSelection = String(decoding: encoded, as: UTF8.self)
            restorationData[RestorationKeys.selection.rawValue] = strSelection
        }
        
        let firstItems = items.prefix(RedditTableViewModel.MaxItemsRestoration)
        let itemsEncoded = firstItems.map { (item) -> String in
            let encoded = try! encoder.encode(item)
            let str = String(decoding: encoded, as: UTF8.self)
            return str
        }
        restorationData[RestorationKeys.items.rawValue] = itemsEncoded
        
        return restorationData
    }
    
    func dismissAll() {
        items.removeAll()
        reloadAction()
    }
    
}
