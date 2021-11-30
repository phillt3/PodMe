//
//  Pod.swift
//  PodMe
//
//  Created by Phillip  Tracy on 11/10/21.
//

import Foundation
import Firebase

class Pod {
    var title: String
    var postingUserID: String
    var description: String
    var numberOfComments: Int
    var documentID: String
    //TODO: implement separate class/struct or elements of audio post itself
    //this includes the length of the post and the audio file
    
    var dictionary: [String: Any] {
        return ["title": title, "postingUserID": postingUserID, "description" : description, "numberOfComments": numberOfComments]
    }
    
    init(title: String, postingUserID: String, description: String, numberOfComments: Int, documentID: String){
        self.title = title
        self.postingUserID = postingUserID
        self.description = description
        self.numberOfComments = numberOfComments
        self.documentID = documentID
    }
    
    convenience init() {
        self.init(title: "", postingUserID: "", description: "", numberOfComments: 0, documentID: "")
    }
    
    convenience init(dictionary: [String: Any]){
        let title = dictionary["title"] as! String? ?? ""
        let postingUserID = dictionary["postingUserID"] as! String? ?? ""
        let description  = dictionary["description"] as! String? ?? ""
        let numberOfComments = dictionary["numberOfComments"] as! Int? ?? 0
        self.init(title: title, postingUserID: postingUserID, description: description, numberOfComments: numberOfComments, documentID: "")
    }
    
    func saveData(completion: @escaping (Bool) -> ()) {
        let db = Firestore.firestore()
        //Grab the userID
        guard let postingUserID = Auth.auth().currentUser?.uid else {
            print("ERROR: Could not save data because we don't have a valid postingUserID.")
            return completion(false)
        }
        self.postingUserID = postingUserID
        //create dicitonary representing data we want to save
        let dataToSave: [String: Any] = self.dictionary
        //if we have a saved record, we'll have an ID, otherwise .addDocument will create one
        if self.documentID == "" { //Create a new document via .addDocument
            var ref: DocumentReference? = nil //Firestore will create a new ID for us
            ref = db.collection("pods").addDocument(data: dataToSave) { (error) in
                guard error == nil else {
                    print("ERROR: Adding document \(error!.localizedDescription)")
                    return completion(false)
                }
                self.documentID = ref!.documentID
                print("Added document: \(self.documentID)") //it worked
                completion(true)
            }
        } else { //esle save to the existing documentiD w/.setDaata
            let ref = db.collection("pods").document(self.documentID)
            ref.setData(dataToSave) { (error) in
                guard error == nil else {
                    print("ERROR: Updating document \(error!.localizedDescription)")
                    return completion(false)
                }
                print("Updated document: \(self.documentID)") //it worked
                completion(true)
            }
        }
    }
    
}
