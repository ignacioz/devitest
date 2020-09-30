//
//  RedditTableViewModel.swift
//  DevigetTest
//
//  Created by Ignacio Zunino on 30/09/2020.
//

import Foundation

final class RedditTableViewModel {
    
    private let redditService = RedditService()
    
    var items: [RedditItem] = []
    
    var reloadAction: (() -> Void)!
    var itemRemoved: ((Int) -> Void)!
    var reloadItem: ((Int) -> Void)!

    func loadData(done: (() -> Void)? = nil) {
        redditService.fetchTop { [weak self] (response) in
            self?.items = response.items
            self?.reloadAction()
            done?()
        }
    }
    
    func loadMore(done: (() -> Void)? = nil) {
        guard let lastItem = items.last else {
            return
        }
        redditService.fetchTop(after: lastItem) {[weak self] (response) in
            self?.items.append(contentsOf: response.items)
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
        if (item.read) {
            return
        }
        if let index = self.items.firstIndex(of: item) {
            var newItem = item
            newItem.read = true
            self.items[index] = newItem
            reloadItem(index)
            redditService.setItemAsRead(item: item)
        }
        
    }
    
}
