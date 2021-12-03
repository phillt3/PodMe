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
    
    
    //var pods = ["Get Rich or Die Crying", "How to Lose Money", "Jeff Bezos, We Love You", "First Tik Toker in Space", "Twitch Got Hacked", "Can Drinking 4 Redbulls a Day Lead to Better Thumbnails?"]
    
    var pods: Pods!

    override func viewDidLoad() {
        super.viewDidLoad()
        pods = Pods()
        tableView.delegate = self
        tableView.dataSource = self

    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        pods.loadData {
            self.sortBasedOnSegmentPressed()
            self.tableView.reloadData()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowDetail"{
            let destination = segue.destination as! PodDetailViewController
            let selectedIndexPath = tableView.indexPathForSelectedRow
            destination.pod = pods.podArray[selectedIndexPath!.row]
        }
    }
    
    @IBAction func usersButtonPressed(_ sender: UIBarButtonItem) {
    }
    
    func sortBasedOnSegmentPressed(){
        print(sortSegmentedControl.selectedSegmentIndex)
        switch sortSegmentedControl.selectedSegmentIndex{
        case 0 : //longest
            pods.podArray.sort(by: {$0.seconds > $1.seconds})
            tableView.reloadData()
        case 1: //number of Comments
            pods.podArray.sort(by: {$0.title < $1.title} )
            tableView.reloadData()
        default:
            print("HEY! Check segemented control!")
        }
        tableView.reloadData()
    }
    
    @IBAction func sortSegmentPressed(_ sender: UISegmentedControl) {
        sortBasedOnSegmentPressed()
        tableView.reloadData()
    }
    
}

extension PodListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return pods.podArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! PodTableViewCell
        //cell.titleLabel?.text = pods.podArray[indexPath.row].title
        cell.pod = pods.podArray[indexPath.row]
        return cell
    }
    
    func tableView(_tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        //this is the height of the cell, if you change it in inspect, must change it here too!!
        return 60
    }
    
}
