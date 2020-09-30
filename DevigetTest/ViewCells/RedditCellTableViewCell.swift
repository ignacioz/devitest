//
//  RedditCellTableViewCell.swift
//  DevigetTest
//
//  Created by Ignacio Zunino on 29/09/2020.
//

import UIKit

class RedditCellTableViewCell: UITableViewCell {
    
    @IBOutlet weak var author: UILabel!
    
    @IBOutlet weak var title: UILabel!
    
    @IBOutlet weak var thumbnail: UIImageView!
    
    @IBOutlet weak var dotViewed: Dot!
    
    @IBOutlet weak var commentsLabel: UILabel!
    
    @IBOutlet weak var removeView: UIView!
    
    @IBOutlet weak var timeLabel: UILabel!
    
    var removeAction: (() -> Void)!
        
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        accessoryType = .disclosureIndicator

    }
    
    @IBAction func removeTapped(_ sender: Any) {
        removeAction()
    }

    func configure(viewModel: RedditCellViewModel) {
        self.title.text = viewModel.title
        self.author.text = viewModel.author
        self.commentsLabel.text = viewModel.comments
        self.timeLabel.text = viewModel.time
        
        if let thumbnail = viewModel.thumbnail {
            self.thumbnail.loadImageFrom(link: thumbnail, contentMode: .scaleToFill)
        }
    }
    
    func stopLoading() {
        self.thumbnail?.cancelLoadingImage()
    }
}
