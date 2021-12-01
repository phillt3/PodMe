//
//  PodDetailViewController.swift
//  PodMe
//
//  Created by Phillip  Tracy on 11/4/21.
//

import UIKit
import AVFoundation

class PodDetailViewController: UIViewController, AVAudioPlayerDelegate, AVAudioRecorderDelegate{
    
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var authorTextField: UITextField!
    @IBOutlet weak var lengthLabel: UILabel!
    @IBOutlet weak var descriptionTextField: UITextView!
    @IBOutlet weak var playbutton: UIButton!
    @IBOutlet weak var timeSlider: UISlider!
    
    @IBOutlet weak var cancelBarButton: UIBarButtonItem!
    @IBOutlet weak var saveBarButton: UIBarButtonItem!
    
    var pod: Pod!
    var uploading = false
    var isPlaying = false
    
    var recordingSession: AVAudioSession!
    var audioRecorder: AVAudioRecorder!
    var AudioPlayer: AVAudioPlayer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        recordingSession = AVAudioSession.sharedInstance()

        do {
            try recordingSession.setCategory(.playAndRecord, mode: .default)
            try recordingSession.setActive(true)
            recordingSession.requestRecordPermission() { [unowned self] allowed in
                DispatchQueue.main.async {
                    if allowed {
                        print("Permission Granted")
                    } else {
                        oneButtonAlert(title: "Permission Denied", message: "Please allow permission to use app.")
                    }
                }
            }
        } catch {
            oneButtonAlert(title: "Error", message: "Please try again!")
        }
        
        playbutton.setImage(UIImage(systemName: "play.circle.fill"), for: .normal)
        playbutton.tintColor = UIColor(named: "PrimaryColor")
        
        if pod == nil {
            pod = Pod()
            uploading = true
        } else {
            disableTextEditing()
            saveBarButton.hide()
            uploading = false
        }
        updateUserInterface()
        
    }
    
    
    func updateUserInterface() {
        titleTextField.text = pod.title
        authorTextField.text = pod.displayName
        descriptionTextField.text = pod.description
    }
    
    func updateFromUserInterface() {
        pod.title = titleTextField.text!
        pod.description = descriptionTextField.text!
    }
    
    func leaveViewController() {
        let isPresentingInAddMode = presentingViewController is UINavigationController
        if isPresentingInAddMode {
            dismiss(animated: true, completion: nil)
        } else {
            navigationController?.popViewController(animated: true)
        }
    }
    
    func disableTextEditing(){
        titleTextField.isEnabled = false
        descriptionTextField.isEditable = false
        
    }
    
    
    func startRecording() {
        let identifier = UUID()
        pod.audioFileName = "\(identifier.uuidString).m4a"
        let audioFilename = getDocumentsDirectory().appendingPathComponent(pod.audioFileName)

        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 12000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]

        do {
            audioRecorder = try AVAudioRecorder(url: audioFilename, settings: settings)
            audioRecorder.delegate = self
            audioRecorder.record()
            //recordButton.setTitle("Tap to Stop", for: .normal)
            playbutton.tintColor = .red
            playbutton.setImage(UIImage(systemName: "pause.circle.fill"), for: .normal)
            isPlaying = true
        } catch {
            finishRecording(success: false)
        }
    }
    
    func finishRecording(success: Bool) {
        audioRecorder.stop()
        audioRecorder = nil
        if success {
            //recordButton.setTitle("Tap to Re-record", for: .normal)
            playbutton.tintColor = UIColor(named: "PrimaryColor")
            playbutton.setImage(UIImage(systemName: "play.circle.fill"), for: .normal)
            isPlaying = false
        } else {
            //recordButton.setTitle("Tap to Record", for: .normal)
            playbutton.tintColor = UIColor(named: "PrimaryColor")
            playbutton.setImage(UIImage(systemName: "play.circle.fill"), for: .normal)
            isPlaying = false
            oneButtonAlert(title: "Recording Failed", message: "Please Try Again!")
            // recording failed :(
        }
    }
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if !flag {
            finishRecording(success: false)
        }
    }
    
    @IBAction func saveButtonPressed(_ sender: UIBarButtonItem) {
        updateFromUserInterface()
        pod.saveData { (success) in
            if success {
                self.leaveViewController()
            } else {
                self.oneButtonAlert(title: "Save Failed", message: "For some reason, the data would not save to the cloud.")
            }
        }
    }
    
    @IBAction func testButtonPressed(_ sender: UIButton) {
        
        let path = getDocumentsDirectory().appendingPathComponent(pod.audioFileName)
        //let url = URL(fileURLWithPath: path)

        do {
            AudioPlayer = try AVAudioPlayer(contentsOf: path)
            AudioPlayer?.play()
        } catch {
            // couldn't load file :(
            print("Could not load file.")
        }
    }
    
    
    @IBAction func cancelButtonPressed(_ sender: UIBarButtonItem) {
        leaveViewController()
    }
    
    @IBAction func playButtonPressed(_ sender: UIButton) {
        if uploading {
            if audioRecorder == nil {
                print("RECORDING")
                startRecording()
            } else {
                print("RECORDING STOPPED")
                finishRecording(success: true)
            }
        } else {
            if isPlaying {
                //playing stopped
                print("Playing stopped")
                playbutton.setImage(UIImage(systemName: "play.circle.fill"), for: .normal)
                isPlaying = false
            } else {
                //playing started
                print("Playing")
                playbutton.setImage(UIImage(systemName: "pause.circle.fill"), for: .normal)
                isPlaying = true
            }
        }
    }
}
