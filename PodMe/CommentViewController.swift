//
//  CommentViewController.swift
//  PodMe
//
//  Created by Phillip  Tracy on 12/2/21.
//

import UIKit
import Firebase
import AVFoundation
class CommentViewController: UIViewController {
    @IBOutlet weak var commentTitleField: UITextField!
    @IBOutlet weak var commentAuthorLabel: UILabel!
    @IBOutlet weak var commentPlayButton: UIButton!
    @IBOutlet weak var commentSlider: UISlider!
    @IBOutlet weak var commentLengthLabel: UILabel!
    @IBOutlet weak var saveBarButton: UIBarButtonItem!
    @IBOutlet weak var cancelBarButton: UIBarButtonItem!
    
    var comment: Comment!
    var pod: Pod!
    var uploading = false
    
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
            uploading = true
        } else  {
            //in view mode, disable updates
        }
        updateUserInterface()
    }
    
    func updateUserInterface() {
        commentTitleField.text = comment.commentTitle
        commentAuthorLabel.text = comment.displayName
        
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
            //            if AudioPlayer != nil && AudioPlayer!.isPlaying{
            //                AudioPlayer!.stop()
            //            }
            //TODO: Once audio player is setup, stop by here to stop it once you leave
            navigationController?.popViewController(animated: true)
        }
    }
    
    func startRecording() {
        testButton.alpha = 0.5
        testButton.isEnabled = false
        let identifier = UUID()
        pod.audioFileName = "\(identifier.uuidString).m4a"
        let audioFileURL = getDocumentsDirectory().appendingPathComponent(pod.audioFileName)

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
            playbutton.tintColor = .red
            playbutton.setImage(UIImage(systemName: "pause.circle.fill"), for: .normal)
            isPlaying = true
            lengthLabel.text = makeTimeString(hours: 0, minutes: 0, seconds: 0)
            timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(timerCounter), userInfo: nil, repeats: true)
        } catch {
            finishRecording(success: false)
        }
    }
    
    func finishRecording(success: Bool) {
        audioRecorder.stop()
        audioRecorder = nil
        timer.invalidate()
        pod.seconds = count
        count = 0
        if success {
            playbutton.tintColor = UIColor(named: "PrimaryColor")
            playbutton.setImage(UIImage(systemName: "play.circle.fill"), for: .normal)
            isPlaying = false
            testButton.alpha = 1.0
            testButton.isEnabled = true
        } else {
            playbutton.tintColor = UIColor(named: "PrimaryColor")
            playbutton.setImage(UIImage(systemName: "play.circle.fill"), for: .normal)
            isPlaying = false
            oneButtonAlert(title: "Recording Failed", message: "Please Try Again!")
            // recording failed :(
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
        let noSPaces = commentTitleField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        if noSPaces != "" {
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
            } else {
                print("RECORDING STOPPED")
                finishRecording(success: true)
            }
        } else {
//            if let AudioPlayer = AudioPlayer, AudioPlayer.isPlaying {
//                //stop playback
//                playbutton.setImage(UIImage(systemName: "play.circle.fill"), for: .normal)
//                playBackCounter(start: false)
//                AudioPlayer.stop()
//            } else {
//                //set up player, and play
//                playbutton.setImage(UIImage(systemName: "pause.circle.fill"), for: .normal)
//                tempCount = 0
//                playBackCounter(start: true)
//                let path = getDocumentsDirectory().appendingPathComponent(pod.audioFileName)
//                do {
//                    try AVAudioSession.sharedInstance().setMode(.default)
//                    try AVAudioSession.sharedInstance().setActive(true, options: .notifyOthersOnDeactivation)
//                    AudioPlayer = try AVAudioPlayer(contentsOf: path)
//                    guard let AudioPlayer = AudioPlayer else {
//                        return
//                    }
//                    AudioPlayer.delegate = self
//                    AudioPlayer.play()
//                } catch {
//                    print("Was not able to play audio")
//                }
////
//            }
        }
    }
}
