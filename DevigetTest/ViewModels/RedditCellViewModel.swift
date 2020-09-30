//
//  RedditCellViewModel.swift
//  DevigetTest
//
//  Created by Ignacio Zunino on 30/09/2020.
//

import Foundation

struct RedditCellViewModel: Equatable {
    let author: String
    let title: String
    let time: String
    let thumbnail: URL?
    let comments: String
    let hideDot: Bool
    let id: String
    
    init(item: RedditItem) {
        self.author = item.author
        self.thumbnail = item.thumbnail
        self.comments = "\(item.numComments) comments"
        self.time = item.createdAt.timeAgoSinceDate()
        self.title = item.title
        self.hideDot = item.read
        self.id = item.name
    }
    
    func shouldRefreshDotOnly(previousModel: RedditCellViewModel) -> Bool {
        return previousModel.id == self.id
    }
    
}
