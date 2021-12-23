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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if profile == nil {
            print("Profile should not be nil")
        }
        updateUserInterface()
    }
    
    func updateUserInterface() {
        nameTextField.text = profile.displayName
        pronounsTextField.text = profile.pronouns
        aboutTextField.text = profile.about
        
        imageView.layer.cornerRadius = self.imageView.frame.size.width / 2
        imageView.clipsToBounds = true
        
        guard let url = URL(string: profile.photoURL) else {
            imageView.image = UIImage(systemName: "person.crop.circle")
            return
        }

        imageView.sd_imageTransition = .fade
        imageView.sd_imageTransition?.duration = 0.1
        imageView.sd_setImage(with: url, placeholderImage: UIImage(systemName: "person.crop.circle"))
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
