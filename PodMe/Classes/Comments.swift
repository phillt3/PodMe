//
//  Comments.swift
//  PodMe
//
//  Created by Phillip  Tracy on 12/2/21.
//

import Foundation
import Firebase

class Comments {
    //MARK: Class wide Comments variables used in connecting to Firestore and setting load data to array of Comment type
    var commentArray: [Comment] = []
    var db: Firestore!
    
    init() {
        //MARK: initializing instance of Firestore object to allow for data download
        db = Firestore.firestore()
    }
    
    func loadData(pod: Pod, completed: @escaping () -> ()){
        //MARK: Essential function for loading Comment data from Firebase cloud database
        guard pod.documentID != "" else {
            return
        }
        db.collection("pods").document(pod.documentID).collection("comments").addSnapshotListener { (querySnapshot, error) in
            guard error == nil else {
                print("ERROR: adding the snapshot listener \(error!.localizedDescription)")
                return completed()
            }
            self.commentArray = []
            for document in querySnapshot!.documents {
                let comment = Comment(dictionary: document.data())
                comment.documentID = document.documentID
                self.commentArray.append(comment)
            }
            completed()
        }
    }
}
