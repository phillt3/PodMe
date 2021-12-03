//
//  PodUser.swift
//  PodMe
//
//  Created by Phillip  Tracy on 11/29/21.
//

import Foundation
import Firebase

class PodUser {
    
    var email : String
    var displayName: String
    var photoURL: String
    var userSince: Date
    var documentID: String
    
    var dictionary: [String: Any] {
        let timeIntervalDate = userSince.timeIntervalSince1970
        return ["email": email, "displayName": displayName, "photoURL": photoURL, "userSince": timeIntervalDate]
    }
    
    init(email: String, displayName: String, photoURL: String, userSince: Date, documentID: String) {
        self.email = email
        self.displayName = displayName
        self.photoURL = photoURL
        self.userSince = userSince
        self.documentID = documentID
    }
    
    convenience init(user: User) {
        let email = user.email ?? ""
        let displayName = user.displayName ?? ""
        let photoURL = (user.photoURL != nil ? "\(user.photoURL!)" : "")
        self.init(email: email, displayName: displayName, photoURL: photoURL, userSince: Date(), documentID: user.uid)
    }
    
    convenience init(dictionary: [String : Any]) {
        let email = dictionary["email"] as! String? ?? ""
        let displayName = dictionary["displayName"] as! String? ?? ""
        let photoURL = dictionary["photoURL"] as! String? ?? ""
        let timeIntervalDate = dictionary["userSince"] as! TimeInterval? ?? TimeInterval()
        let userSince = Date(timeIntervalSince1970: timeIntervalDate)
        self.init(email: email, displayName: displayName, photoURL: photoURL, userSince: userSince, documentID: "")
    }
    
    func saveIfNewUser(completion: @escaping (Bool) -> ()) {
        let db = Firestore.firestore()
        let userRef = db.collection("users").document(documentID)
        userRef.getDocument { (document, error) in
            guard error == nil else {
                print("ERROR: Could not access document for user \(self.documentID)")
                return completion(false)
                guard document?.exists == false else {
                    print("The document for user \(self.documentID) already exists. No need to recreate it.")
                    return completion(true)
                }
                let dataToSave: [String: Any] = self.dictionary
                db.collection("users").document(self.documentID).setData(dataToSave) { (error) in
                    guard error == nil else {
                        print("ERROR: \(error!.localizedDescription), could not save data for \(self.documentID)")
                        return completion(false)
                    }
                    return completion(true)
                }
            }
        }
    }
    
}
