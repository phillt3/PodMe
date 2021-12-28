//
//  Comment.swift
//  PodMe
//
//  Created by Phillip  Tracy on 12/2/21.
//

import Foundation
import Firebase

class Comment {
    //MARK: Comment class wide variables that make up all data to be displayed/utilized in UI
    var commentTitle: String
    var commentingUserID: String
    var displayName: String
    var audioFileName : String
    var audioURL : String
    var seconds: Int
    var timeString: String
    var date : Date
    var documentID: String
    
    var dictionary: [String: Any] {
        //MARK: Firebase requires that data be saved within a dictionary
        let timeIntervalDate = date.timeIntervalSince1970
        return ["commentTitle": commentTitle, "commentingUserID" : commentingUserID, "displayName" : displayName, "audioFileName" : audioFileName, "audioURL" : audioURL, "seconds" : seconds, "timeString" : timeString, "date" : timeIntervalDate ]
    }
    
    init(commentTitle: String, commentingUserID: String, documentID: String, displayName: String, audioFileName: String, audioURL: String, seconds: Int, timeString: String, date: Date) {
        //MARK: Although never used, this initalizer allows for convenience initializers
        self.commentTitle = commentTitle
        self.commentingUserID = commentingUserID
        self.documentID = documentID
        self.displayName = displayName
        self.audioFileName = audioFileName
        self.audioURL = audioURL
        self.seconds = seconds
        self.timeString = timeString
        self.date = date
    }
    
    convenience init() {
        //MARK: Conv. intializer solely for an empty Comment
        let commentingUserID = Auth.auth().currentUser?.uid ?? ""
        let displayName = Auth.auth().currentUser?.displayName ?? ""
        self.init(commentTitle: "", commentingUserID: commentingUserID, documentID: "", displayName: displayName, audioFileName: "", audioURL: "", seconds: 0, timeString: "", date: Date())
    }
    
    convenience init(dictionary: [String: Any]){
        //MARK: Conv. initializer to assist in loading data from Firebase
        let commentTitle = dictionary["commentTitle"] as! String? ?? ""
        let commentingUserID = dictionary["commentingUserID"] as! String? ?? ""
        let displayName = dictionary["displayName"] as! String? ?? ""
        let audioFileName = dictionary["audioFileName"] as! String? ?? ""
        let audioURL = dictionary["audioURL"] as! String? ?? ""
        let seconds = dictionary["seconds"] as! Int? ?? 0
        let timeString = dictionary["timeString"] as! String? ?? ""
        let timeIntervalDate = dictionary["date"] as! TimeInterval? ?? TimeInterval()
        let date = Date(timeIntervalSince1970: timeIntervalDate)
        let documentID = dictionary["documentID"] as! String? ?? ""
        self.init(commentTitle: commentTitle, commentingUserID: commentingUserID, documentID: documentID, displayName: displayName, audioFileName: audioFileName, audioURL: audioURL, seconds: seconds, timeString: timeString, date: date)
    }
    
    func getDocumentsDirectory() -> URL {
        //MARK: Function to assist in local audio file procurement
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    func saveData(pod: Pod, completion: @escaping (Bool) -> ()) {
        //MARK: Function that is essential for proper data organization and upload to Firebase cloud database
        let db = Firestore.firestore()
        
        let dataToSave: [String : Any] = self.dictionary
        if self.documentID == "" {
            var ref: DocumentReference? = nil
            ref = db.collection("pods").document(pod.documentID).collection("comments").addDocument(data: dataToSave) { (error) in
                guard error == nil else {
                    print("ERROR: adding document \(error!.localizedDescription)")
                    return completion(false)
                }
                self.documentID = ref!.documentID
                print("Added document: \(self.documentID) to pod: \(pod.documentID)")
                self.saveAudio(pod: pod)
                completion(true)
            }
        } else {
            let ref = db.collection("pods").document(pod.documentID).collection("comments").document(self.documentID)
            ref.setData(dataToSave) { (error) in
                guard error == nil else {
                    print("ERROR: updating document \(error!.localizedDescription)")
                    return completion(false)
                }
                print("Updated document: \(self.documentID) in pod: \(pod.documentID)")
                self.saveAudio(pod: pod)
                completion(true)
            }
        }
    }
    
    func saveAudio(pod: Pod) {
        //MARK: Specialized function for saving audio files to Firestore storage
        let storage = Storage.storage()
        let audioFile = getDocumentsDirectory().appendingPathComponent(audioFileName)
        print(audioFileName)
        print(audioFile)
        let audioRef = storage.reference().child(pod.documentID).child(documentID)
        print(audioRef)
        
        let uploadTask = audioRef.putFile(from: audioFile)
        audioRef.downloadURL { (url, error) in
            guard let downloadURL = url else {
                print("ERROR occurred while saving downloadURL")
                print("\(error!.localizedDescription)")
                return
            }
            print("Download URL successful")
            print(downloadURL)
            self.audioURL = "\(downloadURL)"
        }
    }
    
    func loadAudio(pod : Pod, completion: @escaping (Bool) -> ()){
        //MARK: Specialized function for loading audio files from Firestore and storing them to document directory
        let storage = Storage.storage()
        let storageRef = storage.reference().child(pod.documentID).child(documentID)
        let localURL = getDocumentsDirectory().appendingPathComponent(audioFileName)
        let _ = storageRef.write(toFile: localURL) { url, error in
            if let error = error {
                print("An error occurred while loading audio. \(error.localizedDescription)")
                return completion(false)
            } else {
                if url != nil {
                    self.audioURL = "\(url!)"
                    print(self.audioURL)
                    return completion(true)
                } else {
                    print("The local url was nil")
                    return completion(true)
                }
            }
        }
    }
}
