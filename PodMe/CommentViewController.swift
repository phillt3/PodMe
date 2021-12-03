//
//  CommentViewController.swift
//  PodMe
//
//  Created by Phillip  Tracy on 12/2/21.
//

import UIKit

class CommentViewController: UIViewController {
    @IBOutlet weak var commentTitleField: UITextField!
    @IBOutlet weak var commentAuthorLabel: UILabel!
    @IBOutlet weak var commentPlayButton: UIButton!
    @IBOutlet weak var commentSlider: UISlider!
    @IBOutlet weak var commentLengthLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

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
    
    @IBAction func commentCancelButtonPressed(_ sender: UIBarButtonItem) {
        leaveViewController()
    }
    


}
