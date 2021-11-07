//
//  PodListViewController.swift
//  PodMe
//
//  Created by Phillip  Tracy on 11/4/21.
//

import UIKit

class PodListViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var sortSegmentedControl: UISegmentedControl!
    
    
    var pods = ["Get Rich or Die Crying", "How to Lose Money", "Jeff Bezos, We Love You", "First Tik Toker in Space", "Twitch Got Hacked", "Can Drinking 4 Redbulls a Day Lead to Better Thumbnails?"]

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self

    }
    
    
    
}

extension PodListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return pods.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! PodTableViewCell
        cell.titleLabel?.text = pods[indexPath.row]
        return cell
    }
    
    func tableView(_tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        //this is the height of the cell, if you change it in inspect, must change it here too!!
        return 60
    }
    
}
