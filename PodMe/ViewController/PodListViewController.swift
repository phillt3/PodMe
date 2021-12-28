//
//  PodListViewController.swift
//  PodMe
//
//  Created by Phillip  Tracy on 11/4/21.
//

import UIKit
import FirebaseAuth

class PodListViewController: UIViewController {
    //MARK: IBOUTLETS for PodListViewController
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var sortSegmentedControl: UISegmentedControl!
        
    //MARK: Class wide variables that includes catcher variables for both Pods and Profiles types
    var pods: Pods!
    var profiles: Profiles!

    override func viewDidLoad() {
        super.viewDidLoad()
        //MARK: Instantiating Pods and Profiles objects in order to later load in relevant data from Firebase
        pods = Pods()
        profiles = Profiles()
        //MARK: Setting necessary delegate and datasource for tableView in PodListView Controller
        tableView.delegate = self
        tableView.dataSource = self

    }
    
    override func viewDidAppear(_ animated: Bool) {
        //MARK: Once the view has appeared, load in Firebase data for both pods and profiles
        super.viewDidAppear(animated)
        pods.loadData {
            print("Loading Pods")
            self.sortBasedOnSegmentPressed()
            self.tableView.reloadData()
        }
        profiles.loadData {
            print("Loading Profiles")
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //MARK: prepare for segue used in passing appropriate data to the target view controller
        if segue.identifier == "ShowDetail"{
            let destination = segue.destination as! PodDetailViewController
            let selectedIndexPath = tableView.indexPathForSelectedRow
            destination.pod = pods.podArray[selectedIndexPath!.row]
            destination.profile = profiles.profileDict[pods.podArray[selectedIndexPath!.row].postingUserID]
        } else if segue.identifier == "EditProfile" {
            guard let userID = Auth.auth().currentUser?.uid else {
                print("ERROR: Could not view profile because we don't have a valid postingUserID.")
                return
            }
            if let nav = segue.destination as? UINavigationController,
                let vc = nav.topViewController as? ProfileViewController {
                vc.profile = profiles.profileDict[userID]
                vc.editFlag = true
            }
        }
    }
    
    func sortBasedOnSegmentPressed(){
        //MARK: function used by segment control to sort the tableview cells
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
        //MARK: IBACTION for when segment control is changed
        sortBasedOnSegmentPressed()
        tableView.reloadData()
    }
    
}

extension PodListViewController: UITableViewDelegate, UITableViewDataSource {
    //MARK: Essential extension to allow for functioning Table View
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return pods.podArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! PodTableViewCell
        cell.pod = pods.podArray[indexPath.row]
        return cell
    }
    
    func tableView(_tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        //this is the height of the cell, if you change it in inspect, must change it here too
        return 60
    }
    
}
