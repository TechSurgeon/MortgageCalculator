//
//  MainViewController.swift
//  MortgageBoss
//
//  Created by Carl von Havighorst on 1/19/20.
//  Copyright © 2020 WestWood Tech LLC. All rights reserved.
//

import Foundation
import UIKit


class MainViewController : UITableViewController {
    
    

    @IBAction func addMortgageTapped(_ sender: UIBarButtonItem) {
        let Storyboard  = UIStoryboard(name: "main", bundle: nil)
           let vc = Storyboard.instantiateViewController(withIdentifier: "DetailViewController")
           present(vc , animated: true , completion: nil)
    }
}
