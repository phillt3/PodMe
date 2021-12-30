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
    
    convenience init(user: User){
        let userID = user.uid
        let email = user.email ?? "unknown email"
        let displayName = user.displayName ?? ""
        self.init(email: email, displayName: displayName, userID: userID, photoURL: "", profileImage: UIImage(), pronouns: "", about: "", documentID: user.uid)
    }
    
    convenience init(dictionary: [String: Any]){
        let email = dictionary["email"] as! String? ?? ""
        let displayName = dictionary["displayName"] as! String? ?? ""
        let userID = dictionary["userID"] as! String? ?? ""
        let photoURL = dictionary["photoURL"] as! String? ?? ""
        let pronouns = dictionary["pronouns"] as! String? ?? ""
        let about = dictionary["about"] as! String? ?? ""
        self.init(email: email, displayName: displayName, userID: userID, photoURL: photoURL, profileImage: UIImage(), pronouns: pronouns, about: about, documentID: "")
    }
    
    func saveIfNewUser(completion: @escaping (Bool) -> ()) {
        let db = Firestore.firestore()
        let profileRef = db.collection("profiles").document(documentID)
        profileRef.getDocument { (document, error) in
            guard error == nil else {
                print("ERROR could not access document for user \(self.documentID)")
                return completion(false)
            }
            guard document?.exists == false else {
                print("The document for user \(self.documentID) already exists. No reason to recreate it.")
                return completion(true)
            }
            
            let dataToSave: [String: Any] = self.dictionary
            db.collection("profiles").document(self.documentID).setData(dataToSave) { (error) in
                guard error == nil else {
                    print("ERROR: \(error?.localizedDescription), could not save data for \(self.documentID)")
                    return completion(false)
                }
                return completion(true)
            }
        }
    }
    
    func saveData(completion: @escaping (Bool) -> ()){
        let db = Firestore.firestore()
        let storage = Storage.storage()
        //convert photo.image
        guard let photoData = self.profileImage.jpegData(compressionQuality: 0.5) else {
            print("ERROR: Coudl not convert image to data")
            return
        }
        
        let uploadMetaData = StorageMetadata()
        uploadMetaData.contentType = "image/jpeg"
        
        let storageRef = storage.reference().child(documentID)
        
        let uploadTask = storageRef.putData(photoData, metadata: uploadMetaData) { (metadata, error) in
            if let error = error {
                print("ERROR: Upload for ref \(uploadMetaData) failed. \(error.localizedDescription)")
            }
        }
        uploadTask.observe(.success) { (snapshot) in
            print("Upload to FirebaseStorage was successful!")
            storageRef.downloadURL { (url, error) in
                guard error == nil else {
                    print("ERROR: Couldn't create a download url \(error!.localizedDescription)")
                    return completion(false)
                }
                guard let url = url else {
                    print("ERROR: Couldn't create a download url and this should not have happened because we've already show there was no error.")
                    return completion(false)
                }
                self.photoURL = "\(url)"
                
                let dataToSave: [String : Any] = self.dictionary
                let ref = db.collection("profiles").document(self.documentID)
                ref.setData(dataToSave) { (error) in
                    guard error == nil else {
                        print("ERROR: updating document \(error!.localizedDescription)")
                        return completion(false)
                    }
                    print("Updated Document: \(self.documentID)")
                    completion(true)
                }
            }
        }
        
        uploadTask.observe(.failure) { (snapshot) in
            if let error = snapshot.error {
                print("ERROR: upload task file \(self.documentID) failed with error \(error.localizedDescription)")
            }
            completion(false)
        }
    }
    
    func loadImage(completion: @escaping(Bool) -> ()){
        let storage = Storage.storage()
        let storageRef = storage.reference().child(documentID)
        storageRef.getData(maxSize: 25 * 1024 * 1024) { (data, error) in
            if let error = error {
                print("ERROR: an error occurred while reading data from file ref: \(storageRef) error = \(error.localizedDescription)")
                return completion(false)
            } else {
                self.profileImage = UIImage(data: data!) ?? UIImage()
                return completion(true)
            }
        }
    }
}
