//
//  Pods.swift
//  PodMe
//
//  Created by Phillip  Tracy on 11/29/21.
//

import Foundation
import Firebase

class Pods {
    //MARK: Class wide Pod variables used in connecting to Firestore and setting load data to array of Pod type
    var podArray: [Pod] = []
    var db: Firestore!
    
    init() {
        //MARK: initializing instance of Firestore object to allow for data download
        db = Firestore.firestore()
    }
    
    func loadData(completed: @escaping () -> ()){
        //MARK: Essential function for loading Pod data from Firebase cloud database
        db.collection("pods").addSnapshotListener { (querySnapshot, error) in
            guard error == nil else {
                print("ERROR: adding the snapshot listener \(error!.localizedDescription)")
                return completed()
            }
            self.podArray = []
            for document in querySnapshot!.documents {
                let pod = Pod(dictionary: document.data())
                pod.documentID = document.documentID
                self.podArray.append(pod)
            }
            completed()
        }
    }
}
