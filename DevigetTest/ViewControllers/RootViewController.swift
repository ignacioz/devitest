//
//  MainViewController.swift
//  DevigetTest
//
//  Created by Ignacio Zunino on 29/09/2020.
//

import UIKit

class RootViewController: UISplitViewController, UISplitViewControllerDelegate {
    
    var shouldStartWithFirstScreen = true

    override func viewDidLoad() {
        super.viewDidLoad()

        self.delegate = self
    }

    func splitViewController(_ svc: UISplitViewController, topColumnForCollapsingToProposedTopColumn proposedTopColumn: UISplitViewController.Column) -> UISplitViewController.Column {
        return shouldStartWithFirstScreen ? .primary : .secondary
    }

}
