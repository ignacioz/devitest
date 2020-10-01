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
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
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
        
        let tableViewModel = RedditTableViewModel()
        redditTableController?.viewModel = tableViewModel
        
        redditTableController?.delegate = detailViewController
        
        if let activity = connectionOptions.userActivities.first ?? session.stateRestorationActivity {
            
            if let previouslySelectedItem = getCurrentlySelectedItemForRestoration(activity: activity) {
                detailViewController.itemSelected(previouslySelectedItem)
                            }
            
            let showingList = activity.userInfo?["showingList"] as? Bool ?? true
            rootViewController?.shouldStartWithFirstScreen = showingList

        }
    
    }
    
    func stateRestorationActivity(for scene: UIScene) -> NSUserActivity? {
        
        if let currentlySelectedItem = redditTableController?.viewModel.currentlySelectedItem {
            let activity = NSUserActivity(activityType: "restoration")
            activity.persistentIdentifier = UUID().uuidString
            
            let encoder = JSONEncoder()
            let encoded = try! encoder.encode(currentlySelectedItem)
            let str = String(decoding: encoded, as: UTF8.self)
                    
            let showingList = redditTableController?.viewIfLoaded?.window != nil
            
            activity.addUserInfoEntries(from: ["currentItem": str, "showingList": showingList])
            
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

