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
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.

    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    override func viewWillAppear(_ animated: Bool) {
        if let currentItem = currentItem {
            titleLabel?.text = currentItem.author
        }
    }

}

extension DetailViewController: ItemSelectionDelegate {
    func itemSelected(_ item: RedditItem) {
        self.currentItem = item
        titleLabel?.text = item.author
    }
}
