//
//  CommentViewController.swift
//  PodMe
//
//  Created by Phillip  Tracy on 12/2/21.
//

import UIKit
import Firebase
import AVFoundation
class CommentViewController: UIViewController, AVAudioRecorderDelegate, AVAudioPlayerDelegate {
    //MARK: Note this view controller is very similar in functionality to PodDetail just with less UI to update from and no comment tableview to manage
    
    //MARK: IBOUTLETS
    @IBOutlet weak var commentTitleField: UITextField!
    @IBOutlet weak var commentAuthorLabel: UILabel!
    @IBOutlet weak var commentPlayButton: UIButton!
    @IBOutlet weak var commentSlider: UISlider!
    @IBOutlet weak var commentLengthLabel: UILabel!
    @IBOutlet weak var saveBarButton: UIBarButtonItem!
    @IBOutlet weak var cancelBarButton: UIBarButtonItem!
    @IBOutlet weak var testButton: UIButton!
    @IBOutlet weak var commentGuideLabel: UILabel!
    @IBOutlet weak var profileButton: UIButton!
    
    //MARK: Class wide variables
    var comment: Comment!
    var pod: Pod!
    var profile: Profile!
    var uploading = false
    var isPlaying = false
    
    var timer: Timer = Timer()
    var playBackTimer: Timer = Timer()
    var count: Int = 0
    var tempCount : Int = 0
    var timerCounting: Bool = false
    
    var recordingSession: AVAudioSession!
    var audioRecorder: AVAudioRecorder!
    var AudioPlayer: AVAudioPlayer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //MARK: Hiding save button and allowing user to tap away from keyboard
        //TODO: There is still minor issue with back bar button item appearing instead of cancel
        saveBarButton.isEnabled = false
        let tap = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:)))
        tap.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tap)
        
        guard pod != nil else {
            print("ERROR: No pod passed to CommentViewController")
            return
        }
        //MARK: Based on if comment catch is empty, user is either uploading or is listening to a posted comment
        if comment == nil {
            comment = Comment()
            testButton.alpha = 0.5
            testButton.isEnabled = false
            commentSlider.isHidden = true
            commentSlider.isEnabled = false
            uploading = true
            profileButton.isHidden = true
            profileButton.isEnabled = false
        } else  {
            //in view mode, disable updates
            commentGuideLabel.isHidden = true
            commentGuideLabel.isEnabled = false
            saveBarButton.hide()
            commentTitleField.isEnabled = false
            testButton.isHidden = true
            testButton.isEnabled = false
            commentSlider.setValue(0.0, animated: false)
            commentSlider.minimumValue = 0.0
            commentSlider.maximumValue = Float(comment.seconds)
            commentSlider.setThumbImage(UIImage(), for: .normal)
            uploading = false
        }
        updateUserInterface()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //MARK: prepare fro segue mainly used for passing commenter's profile data
        updateFromUserInterface()
        switch segue.identifier ?? "" {
        case "ShowProfileFromComments":
            let destination = segue.destination as! ProfileViewController
            destination.profile = profile
            destination.editFlag = false
        default:
            print("Couldn't find a case for segue identifier \(segue.identifier)")
        }
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        //MARK: function that can detect is audio player has finished playing so that it can then update UI and stop counter
        commentPlayButton.setImage(UIImage(systemName: "play.circle.fill"), for: .normal)
        playBackCounter(start: false)
    }
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        //MARK: function that can detect if audio recording has stopped so that it can call subsequent functions
        if !flag {
            finishRecording(success: false)
        }
    }
    
    @objc func playBackTimerCounter() -> Void {
        //MARK: function used in playBackCounter to check couunter and update timer UI
        tempCount = tempCount + 1
        if tempCount == comment.seconds{
            playBackTimer.invalidate()
        }
        commentSlider.setValue((Float(tempCount)), animated: false)
        let time = secondsToHoursMinutesSeconds(seconds: tempCount)
        let timeString = makeTimeString(hours: time.0, minutes: time.1, seconds: time.2)
        commentLengthLabel.text = timeString
    }
    
    func playBackCounter(start : Bool){
        //MARK: function used for resetting and starting timer
        if start == true {
            commentLengthLabel.text = makeTimeString(hours: 0, minutes: 0, seconds: 0)
            playBackTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(playBackTimerCounter), userInfo: nil, repeats: true)
        } else {
            playBackTimer.invalidate()
        }
    }
    
    func secondsToHoursMinutesSeconds(seconds: Int) -> (Int, Int, Int) {
        //MARK: function for making conversions from seconds to hours_mins_seconds value
        return (seconds / 3600, seconds % 3600 / 60, ((seconds % 3600) % 60))
    }
    
    @objc func timerCounter() -> Void {
        //MARK: with each timer tick this function updates counter and UI
        count = count + 1
        let time = secondsToHoursMinutesSeconds(seconds: count)
        let timeString = makeTimeString(hours: time.0, minutes: time.1, seconds: time.2)
        commentLengthLabel.text = timeString
    }
    
    func makeTimeString(hours: Int, minutes: Int, seconds : Int) -> String {
        //MARK: function for formatting time string to be displayed
        var timeString = ""
        timeString += String(format : "%02d", hours)
        timeString += " : "
        timeString += String(format : "%02d", minutes)
        timeString += " : "
        timeString += String(format : "%02d", seconds)
        return timeString
    }
    
    func getDocumentsDirectory() -> URL {
        //MARK: helper function for returning URL of available location in document directory
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    func updateUserInterface() {
        //MARK: updates user interface with appropriate comment data
        commentTitleField.text = comment.commentTitle
        commentAuthorLabel.text = comment.displayName
        commentLengthLabel.text = comment.timeString
        
        //TODO: This is where changes to cancel/back button may be
        if comment.commentingUserID == Auth.auth().currentUser?.uid {
            self.navigationItem.leftItemsSupplementBackButton = false
        } else {
            cancelBarButton.hide()
        }
    }
    
    func updateFromUserInterface() {
        //MARK: extracting appropriate data from UI to be saved in comment document
        comment.commentTitle = commentTitleField.text!
        comment.timeString = commentLengthLabel.text!
    }
    
    func leaveViewController() {
        //MARK: function that performs closing actions and checks if user leaves view controller
        let isPresentingInAddMode = presentingViewController is UINavigationController
        if isPresentingInAddMode {
            dismiss(animated: true, completion: nil)
        } else {
            if AudioPlayer != nil && AudioPlayer!.isPlaying{
                AudioPlayer!.stop()
            }
            navigationController?.popViewController(animated: true)
        }
    }
    
    func startRecording() {
        //MARK: function that sets up audio file and begins recording of audio to be stored at audio file location
        testButton.alpha = 0.5
        testButton.isEnabled = false
        let identifier = UUID()
        comment.audioFileName = "\(identifier.uuidString).m4a"
        let audioFileURL = getDocumentsDirectory().appendingPathComponent(comment.audioFileName)

        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 44100,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]

        do {
            audioRecorder = try AVAudioRecorder(url: audioFileURL, settings: settings)
            audioRecorder.delegate = self
            audioRecorder.record()
            commentPlayButton.tintColor = .red
            commentPlayButton.setImage(UIImage(systemName: "pause.circle.fill"), for: .normal)
            isPlaying = true
            commentLengthLabel.text = makeTimeString(hours: 0, minutes: 0, seconds: 0)
            timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(timerCounter), userInfo: nil, repeats: true)
        } catch {
            finishRecording(success: false)
        }
    }
    
    func finishRecording(success: Bool) {
        //MARK: performs closing audiorecorder, timer, comment, and UI updates after audiorecorder finished
        audioRecorder.stop()
        audioRecorder = nil
        timer.invalidate()
        comment.seconds = count
        count = 0
        if success {
            commentPlayButton.tintColor = UIColor(named: "PrimaryColor")
            commentPlayButton.setImage(UIImage(systemName: "play.circle.fill"), for: .normal)
            isPlaying = false
            testButton.alpha = 1.0
            testButton.isEnabled = true
        } else {
            commentPlayButton.tintColor = UIColor(named: "PrimaryColor")
            commentPlayButton.setImage(UIImage(systemName: "play.circle.fill"), for: .normal)
            isPlaying = false
            oneButtonAlert(title: "Recording Failed", message: "Please Try Again!")
            // recording failed :(
        }
    }
    
    @IBAction func testButtonPressed(_ sender: UIButton) {
        //MARK: function that allows playback of comment after audio is recorded
        let path = getDocumentsDirectory().appendingPathComponent(comment.audioFileName)
        do {
            AudioPlayer = try AVAudioPlayer(contentsOf: path)
            AudioPlayer?.play()
            AudioPlayer?.setVolume(100.0, fadeDuration: 0.0)
        } catch {
            print("Could not load file.")
        }
    }
    
    @IBAction func commentCancelButtonPressed(_ sender: UIBarButtonItem) {
        //MARK: function that allows user to leave current view controller
        leaveViewController()
    }
    
    @IBAction func commentSaveButtonPressed(_ sender: UIBarButtonItem) {
        //MARK: perform all necessary updates and save implementations to store comment data to firebase
        updateFromUserInterface()
        comment.saveData(pod: pod) { success in
            if success {
                self.leaveViewController()
            } else {
                print("ERROR: Can't unwind segue from Comment because of comment saving error")
            }
        }
        
    }
    
    
    @IBAction func commentTitleChanged(_ sender: UITextField) {
        //MARK: function used in checking if comment title was edited
        //TODO: May be smart to implement this in main pod upload as well
        let noSpaces = commentTitleField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        if noSpaces != "" {
            saveBarButton.isEnabled = true
        } else {
            saveBarButton.isEnabled = false
        }
    }
    
    @IBAction func commentPlayButtonPressed(_ sender: UIButton) {
        //MARK: primary function of view controller allowing user to start recording, stop recording, play recording, stop playing recording all based on if the user is uploading a Comment or viewing another user's comment
        if uploading {
            if audioRecorder == nil {
                print("RECORDING")
                startRecording()
                saveBarButton.isEnabled = false
            } else {
                print("RECORDING STOPPED")
                finishRecording(success: true)
                saveBarButton.isEnabled = true
            }
        } else {
            if let AudioPlayer = AudioPlayer, AudioPlayer.isPlaying {
                //stop playback
                commentPlayButton.setImage(UIImage(systemName: "play.circle.fill"), for: .normal)
                playBackCounter(start: false)
                AudioPlayer.stop()
            } else {
                //set up player, and play
                commentPlayButton.setImage(UIImage(systemName: "pause.circle.fill"), for: .normal)
                tempCount = 0
                playBackCounter(start: true)
                var path = getDocumentsDirectory().appendingPathComponent(comment.audioFileName)
                comment.loadAudio(pod: pod) { (success) in
                    if success {
                        path = URL(string: self.comment.audioURL)!
                        print("Using loaded audio with path \(path)")
                    } else{
                        print("ERROR: could not load audio for \(self.comment.audioURL), using local path")
                    }
                }
                do {
                    try AVAudioSession.sharedInstance().setMode(.default)
                    try AVAudioSession.sharedInstance().setActive(true, options: .notifyOthersOnDeactivation)
                    AudioPlayer = try AVAudioPlayer(contentsOf: path)
                    guard let AudioPlayer = AudioPlayer else {
                        return
                    }
                    AudioPlayer.delegate = self
                    AudioPlayer.play()
                    AudioPlayer.setVolume(100.0, fadeDuration: 0.0)
                } catch {
                    print("Was not able to play audio")
                }
//
            }
        }
    }
}
