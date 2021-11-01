//
//  RegisterViewController.swift
//  Messenger Application
//
//  Created by administrator on 27/10/2021.
//

import UIKit
import Firebase
import FirebaseAuth
import MaterialComponents.MaterialTextFields
import MaterialComponents.MaterialTextControls_FilledTextAreas
import MaterialComponents.MaterialTextControls_FilledTextFields
import MaterialComponents.MaterialTextControls_OutlinedTextAreas
import MaterialComponents.MaterialTextControls_OutlinedTextFields
class RegisterViewController: UIViewController , UIImagePickerControllerDelegate, UINavigationControllerDelegate{

    @IBOutlet weak var fNameTxtField: MDCOutlinedTextField!
    
    @IBOutlet weak var lNameTxtField: MDCOutlinedTextField!
    
    @IBOutlet weak var emailTxtField: MDCOutlinedTextField!
    @IBOutlet weak var passTxtField: MDCOutlinedTextField!
    
    @IBOutlet weak var registerButton: UIButton!
    @IBOutlet weak var profilImage: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
       fNameTxtField.label.text = "First Name"
        lNameTxtField.label.text = "Last Name "
        emailTxtField.label.text = "Email Address"
        passTxtField.label.text = "Password"
        registerButton.layer.cornerRadius = 6
        registerButton.layer.borderWidth = 2
        registerButton.layer.borderColor = UIColor.black.cgColor
        // Do any additional setup after loading the view.
    }
    
    @IBAction func takeImageButton(_ sender: Any) {
            let picker = UIImagePickerController()
            picker.allowsEditing = true
            picker.delegate = self
            self.present(picker, animated: true)
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[.editedImage] as? UIImage{
            profilImage.setBackgroundImage(image, for: .normal)
            dismiss(animated: true)
           profilImage.layer.masksToBounds = true
                  profilImage.layer.cornerRadius = 45
    profilImage.layer.cornerRadius = profilImage.frame.size.height/2

        }else{
            print("image not found")
        }
    }
    
    @IBAction func registerButtonPress(_ sender: Any) {
        firebaseAuth()
    }
    func firebaseAuth(){
        // Firebase Login / check to see if email is taken
        // try to create an account
        FirebaseAuth.Auth.auth().createUser(withEmail: emailTxtField.text!, password: passTxtField.text!, completion: { authResult , error  in
        guard let result = authResult, error == nil else {
            print("Error creating user")
            return
        }
        let user = result.user
        print("Created User: \(user)")
    })}
}
