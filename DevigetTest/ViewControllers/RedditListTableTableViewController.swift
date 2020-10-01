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

final class SectionFooterView: UITableViewHeaderFooterView {
    static let reuseIdentifier: String = String(describing: self)

    var button: UIButton!
    var extendedView: UIView!
    var buttonTapped: (() -> Void)!

    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        
        button = UIButton()
        
        button.setTitle("Dismiss All", for: .normal)
        
        button.setTitleColor(.white, for: .normal)

        button.translatesAutoresizingMaskIntoConstraints = false

        contentView.addSubview(button)
        
        button.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
        button.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        button.addTarget(self, action: #selector(self.dismissAllTapped), for: .touchUpInside)
        
        //this is to extend itbo on iPhones with notches
        
        if let bottomInset = UIApplication.shared.windows.first?.safeAreaInsets.bottom, bottomInset > 0 {
            extendedView = UIView()
            extendedView.backgroundColor = UIColor(red: 50 / 255, green: 50 / 255, blue: 50 / 255, alpha: 1)
            extendedView.translatesAutoresizingMaskIntoConstraints = false

            contentView.addSubview(extendedView)
            
            extendedView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
            extendedView.topAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
            extendedView.widthAnchor.constraint(equalTo: contentView.widthAnchor).isActive = true
            extendedView.heightAnchor.constraint(equalToConstant: bottomInset).isActive = true
        }
    }
    
    @objc func dismissAllTapped() {
        buttonTapped()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

class RedditListTableTableViewController: UITableViewController {
    
    private static let FooterHeight: CGFloat = 50
        
    @IBOutlet weak var refreshController: UIRefreshControl!
    
    var viewModel: RedditTableViewModel!
    
    var delegate: ItemSelectionDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(SectionFooterView.self, forHeaderFooterViewReuseIdentifier: SectionFooterView.reuseIdentifier)
        
        viewModel.reloadAction = { [weak self] in
            self?.tableView.reloadData()
            self?.refreshController.endRefreshing()
        }
        
        viewModel.itemRemoved = {[weak self] index in
            let path = IndexPath(row: index, section: 0)
            self?.tableView.deleteRows(at: [path], with: .left)
        }
        
        viewModel.reloadItem = {[weak self] index in
            let path = IndexPath(row: index, section: 0)
            
            guard let cell = self?.tableView.cellForRow(at: path) as? RedditCellTableViewCell, let item = self?.viewModel.items[index]
            else {
                return
            }
                
            let cellViewModel = RedditCellViewModel(item: item)
            cell.configure(viewModel: cellViewModel)
        }
        
        reloadData()

        self.overrideUserInterfaceStyle = .dark
    }
    
    @IBAction func refreshTriggered(_ sender: UIRefreshControl) {
        reloadData()
    }
    
    private func reloadData() {
        self.refreshController.beginRefreshing()
        viewModel.loadData()
    }
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.items.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "redditCell", for: indexPath) as! RedditCellTableViewCell

        let item = viewModel.items[indexPath.row]
        
        let cellViewModel = RedditCellViewModel(item: item)
        
        cell.configure(viewModel: cellViewModel)
        
        cell.removeAction = { [unowned self] in
            self.viewModel.removeItem(item: item)
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = viewModel.items[indexPath.row]
        
        viewModel.itemSelected(item: item)
            
        if let detailViewController = delegate as? DetailViewController {
          splitViewController?.showDetailViewController(detailViewController, sender: nil)
            
            delegate?.itemSelected(item)
        }
    }
    
    override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let redditCell = cell as? RedditCellTableViewCell {
            redditCell.stopLoading()
        }
    }
    
    override open func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == self.viewModel.items.count-5 {
            viewModel.loadMore()
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        
        return viewModel.items.count > 0 ? RedditListTableTableViewController.FooterHeight : 0
    }
    
    override func tableView(_ tableView: UITableView,
                       viewForFooterInSection section: Int) -> UIView? {
            guard let view = tableView.dequeueReusableHeaderFooterView(
                                withIdentifier: SectionFooterView.reuseIdentifier)
                                as? SectionFooterView
            else {
                return nil
            }
        view.buttonTapped = {[unowned self] in
            self.viewModel.dismissAll()
        }
        return view
    }
    
    
    func continueFrom(activity: NSUserActivity) {

        let item = activity.userInfo?["currentItem"] as! String

        let decoder = JSONDecoder()
        let jsonString = item.data(using: .utf8)
        let decodedItem = try! decoder.decode(RedditItem.self, from: jsonString!)

        if let detailViewController = delegate as? DetailViewController {
          splitViewController?.showDetailViewController(detailViewController, sender: nil)
            
            delegate?.itemSelected(decodedItem)
        }
    }
    
    
}

