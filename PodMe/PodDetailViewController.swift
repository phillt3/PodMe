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
    @IBOutlet weak var testButton: UIButton!
    @IBOutlet weak var uploadGuideLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    
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
    
    var comments: Comments!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        
        let tap = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:)))
        tap.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tap)
        
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
            testButton.alpha = 0.5
            testButton.isEnabled = false
            timeSlider.isHidden = true
            timeSlider.isEnabled = false
        } else {
            //self.pod.loadAudio()
            disableTextEditing()
            saveBarButton.hide()
            testButton.isHidden = true
            testButton.isEnabled = false
            uploadGuideLabel.isHidden = true
            uploadGuideLabel.isEnabled = false
            timeSlider.setValue(0.0, animated: false)
            timeSlider.minimumValue = 0.0
            timeSlider.maximumValue = Float(pod.seconds)
            timeSlider.setThumbImage(UIImage(), for: .normal)
            uploading = false
        }
        comments = Comments()
        updateUserInterface()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        comments.loadData(pod: pod) {
            print("This runs")
            print(self.comments.commentArray)
            self.tableView.reloadData()
        }
    }
    
    func updateUserInterface() {
        titleTextField.text = pod.title
        authorTextField.text = pod.displayName
        descriptionTextField.text = pod.description
        lengthLabel.text = pod.timeString
    }
    
    func updateFromUserInterface() {
        pod.title = titleTextField.text!
        pod.description = descriptionTextField.text!
        pod.timeString = lengthLabel.text!
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        updateFromUserInterface()
        switch segue.identifier ?? "" {
        case "AddComment":
            let navigationController = segue.destination as! UINavigationController
            let destination = navigationController.viewControllers.first as! CommentViewController
            destination.pod = pod
        case "ShowComment":
            let destination = segue.destination as! CommentViewController
            let selectedIndexPath = tableView.indexPathForSelectedRow
            destination.comment = comments.commentArray[selectedIndexPath!.row]
            destination.pod = pod
        default:
            print("Couldn't find a case for segue identifier \(segue.identifier)")
        }
    }
    
    func disableTextEditing(){
        titleTextField.isEnabled = false
        descriptionTextField.isEditable = false
        
    }
    
    
    @objc func timerCounter() -> Void {
        count = count + 1
        let time = secondsToHoursMinutesSeconds(seconds: count)
        let timeString = makeTimeString(hours: time.0, minutes: time.1, seconds: time.2)
        lengthLabel.text = timeString
    }
    
    @objc func playBackTimerCounter() -> Void {
        tempCount = tempCount + 1
        if tempCount == pod.seconds{
            playBackTimer.invalidate()
        }
        timeSlider.setValue((Float(tempCount)), animated: true)
        let time = secondsToHoursMinutesSeconds(seconds: tempCount)
        let timeString = makeTimeString(hours: time.0, minutes: time.1, seconds: time.2)
        lengthLabel.text = timeString
    }
    
    func playBackCounter(start : Bool){
        if start == true {
            lengthLabel.text = makeTimeString(hours: 0, minutes: 0, seconds: 0)
            playBackTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(playBackTimerCounter), userInfo: nil, repeats: true)
        } else {
            playBackTimer.invalidate()
        }
    }
    
    func secondsToHoursMinutesSeconds(seconds: Int) -> (Int, Int, Int) {
        return (seconds / 3600, seconds % 3600 / 60, ((seconds % 3600) % 60))
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
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if !flag {
            finishRecording(success: false)
        }
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        playbutton.setImage(UIImage(systemName: "play.circle.fill"), for: .normal)
        playBackCounter(start: false)
    }
    
    
    func saveCancelAlert(title: String, message: String, segueIdentifier: String){
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let saveAction = UIAlertAction(title: "Save", style: .default) { (_) in
            self.updateFromUserInterface()
            self.pod.saveData { (success) in
                //TODO: have to test what happens in this situation
//                self.saveBarButton.title = "done"
//                self.cancelBarButton.hide()
//                self.navigationController?.setToolbarHidden(true, animated: true)
//                self.disableTextEditing()
                self.disableTextEditing()
                self.saveBarButton.hide()
                self.testButton.isHidden = true
                self.testButton.isEnabled = false
                self.uploadGuideLabel.isHidden = true
                self.uploadGuideLabel.isEnabled = false
                self.timeSlider.setValue(0.0, animated: false)
                self.timeSlider.minimumValue = 0.0
                self.timeSlider.maximumValue = Float(self.pod.seconds)
                self.timeSlider.setThumbImage(UIImage(), for: .normal)
                self.timeSlider.isHidden = false
                self.timeSlider.isEnabled = true
                self.uploading = false
                print(segueIdentifier)
                if segueIdentifier == "AddComment"{
                    self.performSegue(withIdentifier: segueIdentifier, sender: nil)
                }
            }
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(saveAction)
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
    }
    
    
    @IBAction func addCommentButtonPressed(_ sender: UIBarButtonItem) {
        if pod.documentID == "" {
            saveCancelAlert(title: "This Pod Has Not Been Saved", message: "You must save this Pod before you leave a comment.", segueIdentifier: "AddComment")
        } else {
            performSegue(withIdentifier: "AddComment", sender: nil)
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
        print(pod.audioFileName)
        print(path)
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
            if let AudioPlayer = AudioPlayer, AudioPlayer.isPlaying {
                //stop playback
                playbutton.setImage(UIImage(systemName: "play.circle.fill"), for: .normal)
                playBackCounter(start: false)
                AudioPlayer.stop()
            } else {
                //set up player, and play
                playbutton.setImage(UIImage(systemName: "pause.circle.fill"), for: .normal)
                tempCount = 0
                playBackCounter(start: true)
                var path = getDocumentsDirectory().appendingPathComponent(pod.audioFileName)
                pod.loadAudio { (success) in
                    if success {
                        path = URL(string: self.pod.audioURL)!
                        print("Using loaded audio with path \(path)")
                    } else{
                        print("ERROR: could not load audio for \(self.pod.audioURL), using local path")
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

            }
        }
    }
}

extension PodDetailViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        pod.numberOfComments = comments.commentArray.count
        return comments.commentArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CommentCell", for: indexPath) as! PodCommentTableViewCell
        cell.comment = comments.commentArray[indexPath.row]
        //update
        //TODO: deal with custom cell
        return cell
    }
    
    
}
