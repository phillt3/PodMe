//
//  Pods.swift
//  PodMe
//
//  Created by Phillip  Tracy on 11/29/21.
//

import Foundation
import Firebase

class Pods {
    var podArray: [Pod] = []
    var db: Firestore!
    
    init() {
        db = Firestore.firestore()
    }
    
    func loadData(completed: @escaping () -> ()){
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
