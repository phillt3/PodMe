//
//  PodCommentTableViewCell.swift
//  PodMe
//
//  Created by Phillip  Tracy on 12/2/21.
//

import UIKit
import AVFoundation

class PodCommentTableViewCell: UITableViewCell, AVAudioPlayerDelegate {

    @IBOutlet weak var commentTitleLabel: UILabel!
    @IBOutlet weak var authorNameLabel: UILabel!
    @IBOutlet weak var lengthLabel: UILabel!
    @IBOutlet weak var commentPlayButton: UIButton!

    
    
    var AudioPlayer: AVAudioPlayer?
    var pod: Pod!
    var comment: Comment! {
        didSet {
            commentTitleLabel.text = comment.commentTitle
            authorNameLabel.text = comment.displayName
            lengthLabel.text = comment.timeString
        }
    }

    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        commentPlayButton.setImage(UIImage(systemName: "play.circle.fill"), for: .normal)
    }
    
    @IBAction func commentPlayButtonPressed(_ sender: UIButton) {
        print("Here we are...")
        if let AudioPlayer = AudioPlayer, AudioPlayer.isPlaying {
            //stop playback
            commentPlayButton.setImage(UIImage(systemName: "play.circle.fill"), for: .normal)
            AudioPlayer.stop()
        } else {
            //set up player, and play
            commentPlayButton.setImage(UIImage(systemName: "pause.circle.fill"), for: .normal)
            var path = getDocumentsDirectory().appendingPathComponent(comment.audioFileName)
            comment.loadAudio(pod : pod) { (success) in
                if success {
                    path = URL(string: self.comment.audioURL)!
                    print("Using loaded audio with path \(path)")
                } else{
                    print("ERROR: could not load audio for \(self.comment.audioURL), using local path")
                }
                do {
                    try AVAudioSession.sharedInstance().setMode(.default)
                    try AVAudioSession.sharedInstance().setActive(true, options: .notifyOthersOnDeactivation)
                    self.AudioPlayer = try AVAudioPlayer(contentsOf: path)
                    guard let AudioPlayer = self.AudioPlayer else {
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
