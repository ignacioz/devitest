//
//  RedditCellTableViewCell.swift
//  DevigetTest
//
//  Created by Ignacio Zunino on 29/09/2020.
//

import UIKit

class RedditCellTableViewCell: UITableViewCell {
    
    @IBOutlet weak var myDescription: UILabel!
    
    @IBOutlet weak var title: UILabel!
    
    @IBOutlet weak var thumbnail: UIImageView!
    
    @IBOutlet weak var dotViewed: Dot!
    
    var removeAction: (() -> Void)!
        
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    @IBAction func removeTapped(_ sender: Any) {
        removeAction()
    }

    func configure(viewModel: RedditCellViewModel) {
        self.title.text = viewModel.author
        self.myDescription.text = viewModel.title
        
        if let thumbnail = viewModel.thumbnail {
            self.thumbnail.loadImageFrom(link: thumbnail, contentMode: .scaleToFill)
        }
    }
    
    func stopLoading() {
        self.thumbnail?.cancelLoadingImage()
    }
}
