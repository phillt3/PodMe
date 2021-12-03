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
    
    //TODO: implement separate class/struct or elements of audio post itself
    //this includes the length of the post and the audio file
    
    var dictionary: [String: Any] {
        return ["title": title, "postingUserID": postingUserID, "description" : description, "numberOfComments": numberOfComments, "displayName" : displayName, "audioFileName" : audioFileName, "audioURL" : audioURL, "seconds" : seconds, "timeString" : timeString]
    }
    
    init(title: String, postingUserID: String, description: String, numberOfComments: Int, documentID: String, displayName: String, audioFileName: String, audioURL : String, seconds : Int, timeString : String){
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
        self.init(title: "", postingUserID: "", description: "", numberOfComments: 0, documentID: "", displayName: "", audioFileName: "", audioURL : "", seconds : 0, timeString : "")
    }
    
    convenience init(dictionary: [String: Any]){
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
    
    func getDirectory() -> URL
    {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentDirectory = paths[0]
        return documentDirectory
    }
    
    func saveData(completion: @escaping (Bool) -> ()) {
        let db = Firestore.firestore()
        //getDirectory().appendingPathComponent("\(pod.documentID).m4a")
        //Grab the userID
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
        } else { //esle save to the existing documentiD w/.setDaata
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

//    func loadAudio() {
//        let storage = Storage.storage()
//        let storageRef = storage.reference()
//
//        storageRef.downloadURL { url, error in
//            if let error = error {
//                print("ERROR: \(error.localizedDescription)")
//            } else {
//                self.audioURL = "\(url)"
//            }
//        }
//        let localAudioFile = getDocumentsDirectory().appendingPathComponent(audioFileName)
//        //let downloadTask = storageRef.write(toFile: localAudioFile)
//        let downloadTask = storageRef.write(toFile: localAudioFile) { url, error in
//            if let error = error {
//                print("ERROR: \(error.localizedDescription)")
//            } else {
//                self.audioURL = "\(url)"
//            }
//        }
//    }
  


    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
}
  
