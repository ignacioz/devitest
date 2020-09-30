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

}
