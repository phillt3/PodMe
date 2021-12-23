//
//  Profiles.swift
//  PodMe
//
//  Created by Phillip  Tracy on 12/21/21.
//

import Foundation
import Firebase
class Profiles {
    var profileDict: [String: Profile] = [:]
    var db: Firestore!
    
    init() {
        db = Firestore.firestore()
    }
    func loadData(completed: @escaping () -> ()){
        db.collection("profiles").addSnapshotListener { (querySnapshot, error) in
            guard error == nil else {
                print("ERROR: adding the snapshot listener \(error!.localizedDescription)")
                return completed()
            }
            self.profileDict = [:]
            for document in querySnapshot!.documents {
                let profile = Profile(dictionary: document.data())
                profile.documentID = document.documentID
                let userID = profile.userID
                self.profileDict[userID] = profile
            }
            completed()
        }
    }
    
}
