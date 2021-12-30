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
    var imagePickerController = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imagePickerController.delegate = self
        
        let tap = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:)))
        tap.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tap)
        
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
            nameTextField.isEnabled = false
            saveBarButton.hide()
        }
        updateUserInterface()
    }
    
    func cameraOrLibraryAlert() {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let photoLibraryAction = UIAlertAction(title: "Photo Library", style: .default){ (_) in
            self.accessPhotoLibrary()        }
        let cameraAction = UIAlertAction(title: "Camera", style: .default){ (_) in
            self.accessCamera()
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler:  nil)
        
        alertController.addAction(photoLibraryAction)
        alertController.addAction(cameraAction)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    func updateFromUserInterface() {
        profile.pronouns = pronounsTextField.text ?? ""
        profile.about = aboutTextField.text ?? ""
        profile.displayName = nameTextField.text ?? "unknown name"
        profile.profileImage = imageView.image!
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
        
//        profile.loadImage { success in
//            if success{
//                self.imageView.image = self.profile.profileImage
//            }
//        }
        imageView.sd_imageTransition = .fade
        imageView.sd_imageTransition?.duration = 0.3
        imageView.sd_setImage(with: url, placeholderImage: UIImage(systemName: ""))
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
        cameraOrLibraryAlert()
        updateUserInterface()
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

extension ProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let editedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage{
            imageView.image = editedImage
            profile.profileImage = editedImage
        } else if let originalImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            imageView.image = originalImage
            profile.profileImage = originalImage
        }
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func accessPhotoLibrary(){
        imagePickerController.sourceType = .photoLibrary
        present(imagePickerController, animated: true, completion: nil)
    }
    
    func accessCamera(){
        if UIImagePickerController.isSourceTypeAvailable(.camera){
            imagePickerController.sourceType = .camera
            present(imagePickerController, animated: true, completion: nil)
        } else {
            self.oneButtonAlert(title: "Camera Not Available", message: "There is no camera available on this device.")
        }
    }
}
