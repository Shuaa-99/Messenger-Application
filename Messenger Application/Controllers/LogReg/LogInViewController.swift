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
    @IBOutlet weak var nameTxtField: MDCOutlinedTextField!
    
    @IBOutlet weak var passTxtField: MDCOutlinedTextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        nameTxtField.label.text = "Email Address"
       passTxtField.label.text = "Password"

        // Do any additional setup after loading the view.
    }


}

