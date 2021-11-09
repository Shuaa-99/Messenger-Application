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
import FBSDKLoginKit
import JGProgressHUD

class LogInViewController: UIViewController,LoginButtonDelegate {
    private let spinner = JGProgressHUD(style: .dark)

    @IBOutlet weak var emailTxtField: MDCOutlinedTextField!
    
    @IBOutlet weak var logInButton: UIButton!
    @IBOutlet weak var logWithFacebookButton: UIButton!
    @IBOutlet weak var passTxtField: MDCOutlinedTextField!
    override func viewDidLoad() {
        super.viewDidLoad()
              
              //--------------
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
    
    @IBAction func gotoRegesterPress(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "RegisterViewController")
        (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.changeRootViewController(vc)

    }
    
    @IBAction func loginWithFaceBookPress(_ sender: Any) {
        if let token = AccessToken.current, !token.isExpired {
            let token = token.tokenString
            let request = FBSDKLoginKit.GraphRequest(graphPath: "me", parameters: ["fields" : "email,name"],
      tokenString: token, version: nil, httpMethod: .get)
            request.start(completionHandler: {connection, result,error in
                print("\(result)")
            })
        }
            else{
                let loginButton = LoginManager()
                loginButton.logIn(permissions: ["public_profile", "email"], from: self) {  result, error in
                }
                //permissions = ["public_profile", "email"]
               // view.addSubview(loginButton)
            }
    }
    func loginButton(_ loginButton: FBLoginButton, didCompleteWith result: LoginManagerLoginResult?, error: Error?) {
            let token = result?.token?.tokenString
            let request = FBSDKLoginKit.GraphRequest(graphPath: "me", parameters: ["fields" : "email,name"],
      tokenString: token, version: nil, httpMethod: .get)
            request.start(completionHandler: {connection, result,error in
                print("\(result)")
            })
    
        }
    
        func loginButtonDidLogOut(_ loginButton: FBLoginButton) {
    
        }
    
//    override func viewDidAppear(_ animated: Bool) {
//        super.viewDidAppear(animated)
//    }
    @IBAction func logInButtonPress(_ sender: Any) {
        firebaseAuth()
    }
    func firebaseAuth() {
        spinner.show(in: view)
        // Firebase Login
        FirebaseAuth.Auth.auth().signIn(withEmail: emailTxtField.text!, password: passTxtField.text!, completion: { [weak self] authResult, error in
        
            guard let strongSelf = self else {
                return
            }
            DispatchQueue.main.async {
                strongSelf.spinner.dismiss()
            }
           
            guard let result = authResult, error == nil else {
                print("Failed to log in user with email \(self!.emailTxtField.text ?? "")")
                self!.passTxtField.text = ""
                return
            }
            let user = result.user
            
            UserDefaults.standard.set(self!.emailTxtField.text, forKey: "email")
            print("logged in user: \(user)")
 
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "TabBaeController")
            (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.changeRootViewController(vc)
        })

    }
}


 
 
    
     
   
