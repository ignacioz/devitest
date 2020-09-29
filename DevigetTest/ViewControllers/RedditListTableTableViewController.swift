//
//  RedditListTableTableViewController.swift
//  DevigetTest
//
//  Created by Ignacio Zunino on 29/09/2020.
//

import UIKit

protocol ItemSelectionDelegate: class {
  func itemSelected(_ item: RedditItem)
}

class RedditListTableTableViewController: UITableViewController {
    
    private var items: [RedditItem] = []
    private let redditService = RedditService()
    
    @IBOutlet weak var refreshController: UIRefreshControl!
    
    var delegate: ItemSelectionDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        loadData()
    }
    
    private func loadData(done: (() -> Void)? = nil) {
        redditService.fetchTop { (response) in
            self.items = response.items
            self.tableView.reloadData()
            done?()
        }
    }
    
    @IBAction func refreshTriggered(_ sender: UIRefreshControl) {
        loadData {
            sender.endRefreshing()
        }
    }
    
    private func removeItem(item: RedditItem) {
        if let index = self.items.firstIndex(of: item) {
            let path = IndexPath(row: index, section: 0)
            self.items.remove(at: index)
            self.tableView.deleteRows(at: [path], with: .left)
        }
    }
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "redditCell", for: indexPath) as! RedditCellTableViewCell

        let item = items[indexPath.row]
        
        cell.title.text = item.author
        cell.myDescription.text = item.title
        
        if let thumbnail = item.thumbnail, let url = NSURL(string: thumbnail) {
            cell.thumbnail?.loadImageFrom(link: url, contentMode: .scaleToFill)
        }
        
        cell.removeAction = { [unowned self] in
            self.removeItem(item: item)
        }

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = items[indexPath.row]
            
        if let detailViewController = delegate as? DetailViewController {
          splitViewController?.showDetailViewController(detailViewController, sender: nil)
            
            delegate?.itemSelected(item)
        }
    }
    
    
}
