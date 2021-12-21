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
    @IBOutlet weak var commentTitleField: UITextField!
    @IBOutlet weak var commentAuthorLabel: UILabel!
    @IBOutlet weak var commentPlayButton: UIButton!
    @IBOutlet weak var commentSlider: UISlider!
    @IBOutlet weak var commentLengthLabel: UILabel!
    @IBOutlet weak var saveBarButton: UIBarButtonItem!
    @IBOutlet weak var cancelBarButton: UIBarButtonItem!
    @IBOutlet weak var testButton: UIButton!
    @IBOutlet weak var commentGuideLabel: UILabel!
    
    var comment: Comment!
    var pod: Pod!
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
        saveBarButton.isEnabled = false
        let tap = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:)))
        tap.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tap)
        
        guard pod != nil else {
            print("ERROR: No pod passed to CommentViewController")
            return
        }
        if comment == nil {
            comment = Comment()
            testButton.alpha = 0.5
            testButton.isEnabled = false
            commentSlider.isHidden = true
            commentSlider.isEnabled = false
            uploading = true
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
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        commentPlayButton.setImage(UIImage(systemName: "play.circle.fill"), for: .normal)
        playBackCounter(start: false)
    }
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if !flag {
            finishRecording(success: false)
        }
    }
    
    @objc func playBackTimerCounter() -> Void {
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
        if start == true {
            commentLengthLabel.text = makeTimeString(hours: 0, minutes: 0, seconds: 0)
            playBackTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(playBackTimerCounter), userInfo: nil, repeats: true)
        } else {
            playBackTimer.invalidate()
        }
    }
    
    func secondsToHoursMinutesSeconds(seconds: Int) -> (Int, Int, Int) {
        return (seconds / 3600, seconds % 3600 / 60, ((seconds % 3600) % 60))
    }
    
    @objc func timerCounter() -> Void {
        count = count + 1
        let time = secondsToHoursMinutesSeconds(seconds: count)
        let timeString = makeTimeString(hours: time.0, minutes: time.1, seconds: time.2)
        commentLengthLabel.text = timeString
    }
    
    func makeTimeString(hours: Int, minutes: Int, seconds : Int) -> String {
        var timeString = ""
        timeString += String(format : "%02d", hours)
        timeString += " : "
        timeString += String(format : "%02d", minutes)
        timeString += " : "
        timeString += String(format : "%02d", seconds)
        return timeString
    }
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    func updateUserInterface() {
        commentTitleField.text = comment.commentTitle
        commentAuthorLabel.text = comment.displayName
        commentLengthLabel.text = comment.timeString
        
        if comment.commentingUserID == Auth.auth().currentUser?.uid {
            self.navigationItem.leftItemsSupplementBackButton = false
        } else {
            cancelBarButton.hide()
        }
    }
    
    func updateFromUserInterface() {
        comment.commentTitle = commentTitleField.text!
        comment.timeString = commentLengthLabel.text!
    }
    
    func leaveViewController() {
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
        testButton.alpha = 0.5
        testButton.isEnabled = false
        let identifier = UUID()
        comment.audioFileName = "\(identifier.uuidString).m4a"
        let audioFileURL = getDocumentsDirectory().appendingPathComponent(comment.audioFileName)

        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 12000,
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
        let path = getDocumentsDirectory().appendingPathComponent(comment.audioFileName)
        //let url = URL(fileURLWithPath: path)
        do {
            AudioPlayer = try AVAudioPlayer(contentsOf: path)
            AudioPlayer?.play()
        } catch {
            // couldn't load file :(
            print("Could not load file.")
        }
    }
    
    @IBAction func commentCancelButtonPressed(_ sender: UIBarButtonItem) {
        leaveViewController()
    }
    
    @IBAction func commentSaveButtonPressed(_ sender: UIBarButtonItem) {
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
        let noSpaces = commentTitleField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        if noSpaces != "" {
            saveBarButton.isEnabled = true
        } else {
            saveBarButton.isEnabled = false
        }
    }
    
    @IBAction func commentPlayButtonPressed(_ sender: UIButton) {
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
            print("Here we are...")
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
                } catch {
                    print("Was not able to play audio")
                }
//
            }
        }
    }
}
