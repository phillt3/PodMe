//
//  ProfileViewController.swift
//  PodMe
//
//  Created by Phillip  Tracy on 12/20/21.
//

import UIKit
import SDWebImage
class ProfileViewController: UIViewController {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var changePhotoButton: UIButton!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var pronounsTextField: UITextField!
    @IBOutlet weak var aboutTextField: UITextView!
    @IBOutlet weak var saveBarButton: UIBarButtonItem!
    
    var profile: Profile!
    var editFlag: Bool!
    var photoFlag: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if profile == nil {
            print("ISSUE: Profile should not be nil")
        }
        if editFlag {
            print("User is editing profile")
        } else {
            changePhotoButton.isHidden = true
            changePhotoButton.isEnabled = false
            pronounsTextField.isEnabled = false
            aboutTextField.isEditable = false
            saveBarButton.hide()
        }
        updateUserInterface()
    }
    
    func updateFromUserInterface() {
        profile.pronouns = pronounsTextField.text ?? ""
        profile.about = aboutTextField.text ?? ""
        if imageView.image! == UIImage(systemName: "person.crop.circle") {
            photoFlag = false
        } else {
            photoFlag = true
        }
        profile.profileImage = imageView.image!
    }
    
    func updateUserInterface() {
        nameTextField.text = profile.displayName
        pronounsTextField.text = profile.pronouns
        aboutTextField.text = profile.about
        
//        imageView.layer.cornerRadius = self.imageView.frame.size.width / 2
//        imageView.clipsToBounds = true
        
//        guard let url = URL(string: profile.photoURL) else {
//            imageView.image = UIImage(systemName: "person.fill")
//            return
//        }
        
        profile.loadImage { success in
            if success{
                if self.photoFlag {
                    self.imageView.image = self.profile.profileImage
                }
            }
        }
//        imageView.sd_imageTransition = .fade
//        imageView.sd_imageTransition?.duration = 0.1
        //imageView.sd_setImage(with: url, placeholderImage: UIImage(systemName: "person.c.circle"))
    }
    
    @IBAction func cancelButtonPressed(_ sender: UIBarButtonItem) {
        let isPresentingInAddMode = presentingViewController is UINavigationController
        if isPresentingInAddMode {
            dismiss(animated: true, completion: nil)
        } else {
            navigationController?.popViewController(animated: true)
        }
    }
    
    func leaveViewController() {
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
        updateFromUserInterface()
        profile.saveData { (success) in
            if success {
                self.leaveViewController()
            } else {
                self.oneButtonAlert(title: "Save Failed", message: "For some reason, the data would not save to the cloud.")
            }
        }
    }
    
    
}
