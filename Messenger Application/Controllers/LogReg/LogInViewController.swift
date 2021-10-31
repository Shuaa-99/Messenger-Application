//
//  ViewController.swift
//  Messenger Application
//
//  Created by administrator on 27/10/2021.
//

import UIKit
import MaterialComponents.MaterialTextFields
import MaterialComponents.MaterialTextControls_FilledTextAreas
import MaterialComponents.MaterialTextControls_FilledTextFields
import MaterialComponents.MaterialTextControls_OutlinedTextAreas
import MaterialComponents.MaterialTextControls_OutlinedTextFields
class LogInViewController: UIViewController {
    
    @IBOutlet weak var emailTxtField: MDCOutlinedTextField!
    
    @IBOutlet weak var logInButton: UIButton!
    @IBOutlet weak var faceook: UIButton!
    @IBOutlet weak var passTxtField: MDCOutlinedTextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        emailTxtField.label.text = "Email Address"
       passTxtField.label.text = "Password"
        faceook.layer.cornerRadius = 6
        faceook.layer.borderWidth = 2
        faceook.layer.borderColor = UIColor.black.cgColor
      logInButton.layer.cornerRadius = 6
        logInButton.layer.borderWidth = 2
       logInButton.layer.borderColor = UIColor.black.cgColor
        // Do any additional setup after loading the view.
    }


}

