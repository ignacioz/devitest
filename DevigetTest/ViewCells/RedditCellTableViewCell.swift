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
        
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
