//
//  ConversationViewController.swift
//  Messenger Application
//
//  Created by administrator on 27/10/2021.
//

import UIKit
import Firebase
class ConversationViewController: UIViewController {

    // check to see if user is signed in using ... user defaults
        // they are, stay on the screen. If not, show the login screen
        override func viewDidLoad() {
            super.viewDidLoad()
        }
        override func viewDidAppear(_ animated: Bool) {
            super.viewDidAppear(animated)
            let isLoggedIn = UserDefaults.standard.bool(forKey: "logged_in")
            if !isLoggedIn {
                // present login view controller
                
                let vc = LogInViewController()
                let nav = UINavigationController(rootViewController: vc)
                nav.modalPresentationStyle = .fullScreen
                present(nav, animated: false)
            }
        }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
