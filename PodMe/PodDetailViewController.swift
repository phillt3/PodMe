//
//  PodDetailViewController.swift
//  PodMe
//
//  Created by Phillip  Tracy on 11/4/21.
//

import UIKit

class PodDetailViewController: UIViewController {
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
    
    
    @IBAction func cancelButtonPressed(_ sender: UIBarButtonItem) {
        leaveViewController()
    }
    
    @IBAction func playButtonPressed(_ sender: UIButton) {
        if uploading {
            playbutton.tintColor = .red
            playbutton.setImage(UIImage(systemName: "pause.circle.fill"), for: .normal)
        } else {
            print("Else")
        }
    }
}
