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
    
    var pod: Pod!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if pod == nil {
            pod = Pod()
        }
        updateUserInterface()
        
    }
    func updateUserInterface() {
        titleTextField.text = pod.title
        authorTextField.text = pod.postingUserID
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
    
}
