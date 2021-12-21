//
//  ProfileViewController.swift
//  PodMe
//
//  Created by Phillip  Tracy on 12/20/21.
//

import UIKit

class ProfileViewController: UIViewController {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var changePhotoButton: UIButton!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var pronounsTextField: UITextField!
    @IBOutlet weak var aboutTextField: UITextView!
    @IBOutlet weak var saveBarButton: UIBarButtonItem!    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    @IBAction func cancelButtonPressed(_ sender: UIBarButtonItem) {
        let isPresentingInAddMode = presentingViewController is UINavigationController
        if isPresentingInAddMode {
            dismiss(animated: true, completion: nil)
        } else {
            navigationController?.popViewController(animated: true)
        }
    }
    
    @IBAction func changePhotoButtonPressed(_ sender: UIButton) {
    }
    @IBAction func saveButtonPressed(_ sender: UIBarButtonItem) {
    }
    
    
}
