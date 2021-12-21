//
//  Profile.swift
//  PodMe
//
//  Created by Phillip  Tracy on 12/21/21.
//

import Foundation
import UIKit
import Firebase

class Profile {

    var email: String
    var displayName: String
    var userID: String
    var photoURL: String
    var profileImage: UIImage
    var pronouns: String
    var about: String
    var documentID: String
    
    var dictionary: [String: Any] {
        return ["email": email, "displayName": displayName, "userID": userID, "photoURL": photoURL, "pronouns": pronouns, "about": about]
    }
    
    init(email: String, displayName: String, userID: String, photoURL: String, profileImage: UIImage, pronouns: String, about: String, documentID: String) {
        self.email = email
        self.displayName = displayName
        self.userID = userID
        self.photoURL = photoURL
        self.profileImage = profileImage
        self.pronouns = pronouns
        self.about = about
        self.documentID = documentID
    }
    
    convenience init(){
        let userID = Auth.auth().currentUser?.uid ?? ""
        let email = Auth.auth().currentUser?.email ?? "unknown email"
        let displayName = Auth.auth().currentUser?.displayName ?? ""
        self.init(email: email, displayName: displayName, userID: userID, photoURL: "", profileImage: UIImage(), pronouns: "", about: "", documentID: "")
    }
    
}
