//
//  DetailViewController.swift
//  DevigetTest
//
//  Created by Ignacio Zunino on 29/09/2020.
//

import UIKit

class DetailViewController: UIViewController {

    var currentItem: RedditItem?
    @IBOutlet weak var titleLabel: UILabel?
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if let currentItem = currentItem {
            loadViews(item: currentItem)
        }
    }
    
    private func loadViews(item: RedditItem) {
        
        //this is needed because it may happen that you switch fast to a separate view that reuses this controller and may cause it to show a different image
        
        imageView?.cancelLoadingImage()
        
        titleLabel?.text = item.title
        authorLabel?.text = item.author
        if let image = item.fullSizeImage {
            imageView?.loadImageFrom(link: image, contentMode: .scaleAspectFit)
        } else {
            imageView.image = nil
        }
    }

}

extension DetailViewController: ItemSelectionDelegate {
    func itemSelected(_ item: RedditItem) {
        self.currentItem = item
        loadViews(item: item)
    }
}
