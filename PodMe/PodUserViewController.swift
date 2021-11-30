//
//  PodUserViewController.swift
//  PodMe
//
//  Created by Phillip  Tracy on 11/30/21.
//

import UIKit

class PodUserViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    
    var podUsers: PodUsers!

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        // Do any additional setup after loading the view.
        podUsers = PodUsers()
        podUsers.loadData {
            self.tableView.reloadData()
        }
    }
    
    
}

extension PodUserViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return podUsers.userArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! PodUserTableViewCell
        cell.podUser = podUsers.userArray[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    
}
