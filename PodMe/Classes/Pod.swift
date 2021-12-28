//
//  Pod.swift
//  PodMe
//
//  Created by Phillip  Tracy on 11/10/21.
//

import Foundation
import Firebase
import AVFoundation

class Pod {
    //MARK: Pod Class variables which represent data to be utilized and or displayed in app
    var title: String
    var postingUserID: String
    var description: String
    var numberOfComments: Int
    var documentID: String
    var displayName: String
    var audioFileName : String
    var audioURL : String
    var seconds: Int
    var timeString: String
    
    var dictionary: [String: Any] {
        //MARK: Firebase requires that data be saved within a dictionary
        return ["title": title, "postingUserID": postingUserID, "description" : description, "numberOfComments": numberOfComments, "displayName" : displayName, "audioFileName" : audioFileName, "audioURL" : audioURL, "seconds" : seconds, "timeString" : timeString]
    }
    
    init(title: String, postingUserID: String, description: String, numberOfComments: Int, documentID: String, displayName: String, audioFileName: String, audioURL : String, seconds : Int, timeString : String){
        //MARK: Although never used, this initalizer allows for convenience initializers
        self.title = title
        self.postingUserID = postingUserID
        self.description = description
        self.numberOfComments = numberOfComments
        self.documentID = documentID
        self.displayName = displayName
        self.audioFileName = audioFileName
        self.audioURL = audioURL
        self.seconds = seconds
        self.timeString = timeString
    }
    
    convenience init() {
        //MARK: Conv. intializer solely for an empty Pod
        self.init(title: "", postingUserID: "", description: "", numberOfComments: 0, documentID: "", displayName: "", audioFileName: "", audioURL : "", seconds : 0, timeString : "")
    }
    
    convenience init(dictionary: [String: Any]){
        //MARK: Conv. initializer to assist in loading data from Firebase
        let title = dictionary["title"] as! String? ?? ""
        let postingUserID = dictionary["postingUserID"] as! String? ?? ""
        let description  = dictionary["description"] as! String? ?? ""
        let numberOfComments = dictionary["numberOfComments"] as! Int? ?? 0
        let displayName = dictionary["displayName"] as! String? ?? ""
        let audioFileName = dictionary["audioFileName"] as! String? ?? ""
        let audioURL = dictionary["audioURL"] as! String? ?? ""
        let seconds = dictionary["seconds"] as! Int? ?? 0
        let timeString = dictionary["timeString"] as! String? ?? ""
        self.init(title: title, postingUserID: postingUserID, description: description, numberOfComments: numberOfComments, documentID: "", displayName: displayName, audioFileName : audioFileName, audioURL : audioURL, seconds : seconds, timeString : timeString)
    }

    func getDocumentsDirectory() -> URL {
        //MARK: Function to assist in local audio file procurement
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    func saveData(completion: @escaping (Bool) -> ()) {
        //MARK: Function that is essential for proper data organization and upload to Firebase cloud database
        let db = Firestore.firestore()
        guard let postingUserID = Auth.auth().currentUser?.uid else {
            print("ERROR: Could not save data because we don't have a valid postingUserID.")
            return completion(false)
        }
        self.displayName = Auth.auth().currentUser?.displayName ?? ""
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
                self.saveAudio()
                completion(true)
            }
        } else { //else save to the existing documentiD w/.setDaata
            let ref = db.collection("pods").document(self.documentID)
            ref.setData(dataToSave) { (error) in
                guard error == nil else {
                    print("ERROR: Updating document \(error!.localizedDescription)")
                    return completion(false)
                }
                print("Updated document: \(self.documentID)") //it worked
                self.saveAudio()
                completion(true)
            }
        }
    }
    
    func saveAudio() {
        //MARK: Specialized function for saving audio files to Firestore storage
        let storage = Storage.storage()
        let storageRef = storage.reference()
        let audioFile = getDocumentsDirectory().appendingPathComponent(audioFileName)
        print(audioFileName)
        print(audioFile)
        let audioRef = storageRef.child(documentID)
        print(audioRef)
        
        let uploadTask = audioRef.putFile(from: audioFile)
        audioRef.downloadURL { (url, error) in
            guard let downloadURL = url else {
                print("ERROR occurred while saving downloadURL")
                print("\(error?.localizedDescription)")
                print(url)
                return
            }
            print("Download URL successful")
            print(downloadURL)
            self.audioURL = "\(downloadURL)"
        }
        
        
    }
    
    func loadAudio(completion: @escaping (Bool) -> ()){
        //MARK: Specialized function for loading audio files from Firestore and storing them to document directory
        let storage = Storage.storage()
        let storageRef = storage.reference().child(documentID)
        let localURL = getDocumentsDirectory().appendingPathComponent(audioFileName)
        
        let downloadTask = storageRef.write(toFile: localURL) { url, error in
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
  
