//
//  ViewController.swift
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
class LogInViewController: UIViewController {
    
    @IBOutlet weak var emailTxtField: MDCOutlinedTextField!
    
    @IBOutlet weak var logInButton: UIButton!
    @IBOutlet weak var logWithFacebookButton: UIButton!
    @IBOutlet weak var passTxtField: MDCOutlinedTextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        emailTxtField.label.text = "Email Address"
       passTxtField.label.text = "Password"
        logWithFacebookButton.layer.cornerRadius = 6
        logWithFacebookButton.layer.borderWidth = 2
        logWithFacebookButton.layer.borderColor = UIColor.black.cgColor
      logInButton.layer.cornerRadius = 6
        logInButton.layer.borderWidth = 2
       logInButton.layer.borderColor = UIColor.black.cgColor
        // Do any additional setup after loading the view.
    }

    @IBAction func logInButtonPress(_ sender: Any) {
        firebaseAuth()
    }
    func firebaseAuth() {
        // Firebase Login
        FirebaseAuth.Auth.auth().signIn(withEmail: emailTxtField.text!, password: passTxtField.text!, completion: { [weak self] authResult, error in
            guard let strongSelf = self else {
                return
            }
            guard let result = authResult, error == nil else {
                print("Failed to log in user with email \(self!.emailTxtField.text ?? "")")
                return
            }
            let user = result.user
            print("logged in user: \(user)")
            // if this succeeds, dismiss
            strongSelf.navigationController?.dismiss(animated: true, completion: nil)
           let conVC =  ConversationViewController()
            self?.navigationController?.pushViewController(conVC, animated: true)
        })

    }
}


 
 
    
     
   
