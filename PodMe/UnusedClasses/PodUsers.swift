//
//  PodUsers.swift
//  PodMe
//
//  Created by Phillip  Tracy on 11/30/21.
//

import Foundation
import Firebase

class PodUsers {
    var userArray: [PodUser] = []
    var db: Firestore!
    
    init() {
        db = Firestore.firestore()
    }
    
    func loadData(completed: @escaping () -> ()){
        db.collection("users").addSnapshotListener { (querySnapshot, error) in
            guard error == nil else {
                print("ERROR: adding the snapshot listener \(error!.localizedDescription)")
                return completed()
            }
            self.userArray = []
            for document in querySnapshot!.documents {
                let podUser = PodUser(dictionary: document.data())
                podUser.documentID = document.documentID
                self.userArray.append(podUser)
            }
            completed()
        }
    }
}
