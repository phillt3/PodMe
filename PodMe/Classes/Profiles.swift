//
//  Profiles.swift
//  PodMe
//
//  Created by Phillip  Tracy on 12/21/21.
//

import Foundation
import Firebase
class Profiles {
    //MARK: Class wide Profiles variables used in connecting to Firestore and setting load data to array of Profile type
    var profileDict: [String: Profile] = [:]
    var db: Firestore!
    
    init() {
        //MARK: initializing instance of Firestore object to allow for data download
        db = Firestore.firestore()
    }
    
    func loadData(completed: @escaping () -> ()){
        //MARK: Essential function for loading Comment data from Firebase cloud database
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
