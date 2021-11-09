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
//import FirebaseMLModelDownloader
import JGProgressHUD

class RegisterViewController: UIViewController , UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    private let spinner = JGProgressHUD(style: .dark)
    @IBOutlet weak var fNameTxtField: MDCOutlinedTextField!
    
    @IBOutlet weak var lNameTxtField: MDCOutlinedTextField!
    
    @IBOutlet weak var emailTxtField: MDCOutlinedTextField!
    @IBOutlet weak var passTxtField: MDCOutlinedTextField!
    @IBOutlet weak var registerButton: UIButton!
    @IBOutlet weak var profilImage: UIButton!
    var selectedProfilePic : UIImage!
    override func viewDidLoad() {
        super.viewDidLoad()
       fNameTxtField.label.text = "First Name"
        lNameTxtField.label.text = "Last Name "
        emailTxtField.label.text = "Email Address"
        passTxtField.label.text = "Password"
        registerButton.layer.cornerRadius = 2
        registerButton.layer.borderWidth = 2
        registerButton.layer.borderColor = UIColor.black.cgColor
        // Do any additional setup after loading the view.
    }

    @IBAction func goToLogInPress(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "LogInViewController")
        (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.changeRootViewController(vc)
    }
    @IBAction func takeImageButton(_ sender: Any) {
            let picker = UIImagePickerController()
            picker.allowsEditing = true
            picker.delegate = self
            self.present(picker, animated: true)
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[.editedImage] as? UIImage{
            self.selectedProfilePic = image
            profilImage.setBackgroundImage(image, for: .normal)
            dismiss(animated: true)
            profilImage.layer.borderColor = UIColor.white.cgColor
            profilImage.layer.borderWidth = 4
                 profilImage.layer.masksToBounds = true
              profilImage.layer.cornerRadius = 30
            profilImage.layer.cornerRadius = profilImage.frame.size.width/3

        }else{
            print("image not found")
        }
    }
//    func sendPicToVc () {
//        let pic : UIImage!
//        
//    }
    @IBAction func registerButtonPress(_ sender: Any) {
        firebaseAuth()
    }
    func firebaseAuth(){
       
        // Firebase Login / check to see if email is taken
        // try to create an account
       spinner.show(in: view)
       
        FirebaseAuth.Auth.auth().createUser(withEmail: emailTxtField.text!, password: passTxtField.text!, completion: { authResult , error  in
            
            guard let result = authResult, error == nil else {
            print("Error creating user")
              
            return
        }
           
        let user = result.user
            print("Created User: \(user)")// creat  ChatAppUser
            
            let chatApp : ChatAppUser
                chatApp = .init(firstName: self.fNameTxtField.text!, lastName: self.lNameTxtField.text!, emailAddress: self.emailTxtField.text!)
            
            DatabaseManger.shared.insertUser(with: chatApp)
            
            DatabaseManger.shared.createUser(user: chatApp, completion: {
                success in
                if (success != nil){
                    //رفع الصورة        
                    guard let image = self.selectedProfilePic, let data = image.pngData()
                        
                    else{
                        
                        return
                    }
                    let filName = chatApp.profilePictureFilName
                    DatabaseManger.shared.uploadProfilePicture(with: data, fileName: filName){
                        result in
                        switch result{
                        case .success(let downlodURL):
                            print(downlodURL)
                            
                            UserDefaults.standard.set(downlodURL, forKey: "profile_picture_url")
                            UserDefaults.standard.synchronize()
                            
                           
                        case .failure(let error):
                            print(error)
                        }
                    }
                }
            })
           
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "TabBaeController")
            (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.changeRootViewController(vc)
            
           

            

        } )
        }
}
