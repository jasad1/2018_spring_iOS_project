//
//  SearchViewController.swift
//  Cloneagram
//
//  Created by Student on 2018. 05. 22..
//  Copyright © 2018. Student. All rights reserved.
//

import UIKit

class SearchViewController: UIViewController {

    @IBOutlet weak var nameSearchQueryTextView: UITextField!
    
    var embeddedTVC: SearchTableViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func searchButtonClicked(_ sender: UIButton) {
        guard let query = nameSearchQueryTextView.text, !query.isEmpty else {
            return
        }
        
        embeddedTVC.resetSearchResults()
        
        FirebaseManager.shared.searchUsers(query: query) { (user) in
            if let user = user {
                self.embeddedTVC.addSearchResult(user: user)
            }
        }
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        if segue.identifier == Constants.SegueIdentifiers.SearchEmbed {
            embeddedTVC = segue.destination as! SearchTableViewController
        }
    }
}
