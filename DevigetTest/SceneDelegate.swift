//
//  SceneDelegate.swift
//  DevigetTest
//
//  Created by Ignacio Zunino on 29/09/2020.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    var redditTableController: RedditListTableTableViewController?
    var rootViewController: RootViewController?
    
    private func getCurrentlySelectedItemForRestoration(activity: NSUserActivity) -> RedditItem? {
        
        let item = activity.userInfo?["currentItem"] as! String

        let decoder = JSONDecoder()
        let jsonString = item.data(using: .utf8)
        let decodedItem = try! decoder.decode(RedditItem.self, from: jsonString!)

        return decodedItem
    }

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {

        guard let _ = (scene as? UIWindowScene) else { return }
        
        guard
          let splitViewController = window?.rootViewController as? RootViewController,
          let leftNavController = splitViewController.viewControllers.first
            as? UINavigationController,
            let rightNavController = splitViewController.viewControllers.last
              as? UINavigationController,
            let masterTableController = leftNavController.viewControllers.first
            as? RedditListTableTableViewController,
          let detailViewController = rightNavController.viewControllers.first
            as? DetailViewController
          else {
            fatalError()
            
        }
        
        redditTableController = masterTableController
        rootViewController = splitViewController
        
        redditTableController?.delegate = detailViewController
        
        var restoredTableModel: RedditTableViewModel?
        
        if let activity = connectionOptions.userActivities.first ?? session.stateRestorationActivity, let userInfo = activity.userInfo {
            
            let encodedTableModel = userInfo["tableModel"]
            
            restoredTableModel = RedditTableViewModel(restorationData: encodedTableModel as? [String : Any])
            
            if let selection = restoredTableModel?.currentlySelectedItem {
                detailViewController.itemSelected(selection)
            }
            
            let showingList = userInfo["showingList"] as? Bool ?? true
            rootViewController?.shouldStartWithFirstScreen = showingList

        }
        
        let listViewModel = restoredTableModel ?? RedditTableViewModel()
        listViewModel.redditModel = RedditModel()
            
        redditTableController?.viewModel = listViewModel
    
    }
    
    func stateRestorationActivity(for scene: UIScene) -> NSUserActivity? {
        
        if let encodedTableModel = redditTableController?.viewModel.encodeForRestoration() {
            let activity = NSUserActivity(activityType: "restoration")
            activity.persistentIdentifier = UUID().uuidString
                    
            let showingList = redditTableController?.viewIfLoaded?.window != nil
            
            activity.addUserInfoEntries(from: [ "showingList": showingList, "tableModel": encodedTableModel])
            
            return activity
        }
        
        return nil
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }


}

