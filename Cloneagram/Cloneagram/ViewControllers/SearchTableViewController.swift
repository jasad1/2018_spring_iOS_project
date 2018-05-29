//
//  SearchTableViewController.swift
//  Cloneagram
//
//  Created by Student on 2018. 05. 22..
//  Copyright © 2018. Student. All rights reserved.
//

import UIKit

class SearchTableViewController: UITableViewController {

    private var resultUsers = [User]()
    
    func resetSearchResults() {
        resultUsers.removeAll()
        tableView.reloadData()
    }

    func addSearchResult(user: User) {
        resultUsers.append(user)
        tableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return resultUsers.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.ReuseIdentifiers.searchResultCell,
                                                 for: indexPath) as! SearchResultTableViewCell
        cell.fill(from: resultUsers[indexPath.row], viewController: self)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: Constants.SegueIdentifiers.SearchToViewProfile,
                     sender: resultUsers[indexPath.row])
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        if segue.identifier == Constants.SegueIdentifiers.SearchToViewProfile {
            let target = segue.destination as! ViewProfileViewController
            target.user = sender as! User
	    }
    }
}
