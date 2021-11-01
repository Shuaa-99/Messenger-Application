//
//  ConversationViewController.swift
//  Messenger Application
//
//  Created by administrator on 27/10/2021.
//

import UIKit
import Firebase
class ConversationViewController: UIViewController {
        override func viewDidLoad() {
            super.viewDidLoad()
            // root view controller that gets instantiated when app launches
                // check to see if user is signed in using ... user defaults
                // they are, stay on the screen. If not, show the login screen
                    
                    do {
                        try FirebaseAuth.Auth.auth().signOut()
                    }
                    catch {
                    }
                   DatabaseManger.shared.test() // call test!
                }
                override func viewDidAppear(_ animated: Bool) {
                    super.viewDidAppear(animated)
              
                }
                private func validateAuth(){
                    // current user is set automatically when you log a user in
                    if FirebaseAuth.Auth.auth().currentUser == nil {
                        // present login view controller

                        let storyboard = UIStoryboard(name: "Main", bundle: nil)
                        let vc = storyboard.instantiateViewController(withIdentifier: "LogInViewController")
                        let nav = UINavigationController(rootViewController: vc)
                        nav.modalPresentationStyle = .fullScreen
                        present(nav, animated: false)
                    }
                }

   

}
