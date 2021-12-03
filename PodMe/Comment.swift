//
//  Comment.swift
//  PodMe
//
//  Created by Phillip  Tracy on 12/2/21.
//

import Foundation
import Firebase

class Comment {
    
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
        let timeIntervalDate = date.timeIntervalSince1970
        return ["commentTitle": commentTitle, "commentingUserID" : commentingUserID, "displayName" : displayName, "audioFileName" : audioFileName, "audioURL" : audioURL, "seconds" : seconds, "timeString" : timeString, "date" : timeIntervalDate ]
    }
    
    init(commentTitle: String, commentingUserID: String, documentID: String, displayName: String, audioFileName: String, audioURL: String, seconds: Int, timeString: String, date: Date) {
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
        let commentingUserID = Auth.auth().currentUser?.uid ?? ""
        let displayName = Auth.auth().currentUser?.displayName ?? ""
        self.init(commentTitle: "", commentingUserID: commentingUserID, documentID: "", displayName: displayName, audioFileName: "", audioURL: "", seconds: 0, timeString: "", date: Date())
    }
    
}
