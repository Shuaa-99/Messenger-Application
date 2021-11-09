//
//  ProfileViewController.swift
//  Messenger Application
//
//  Created by administrator on 27/10/2021.
//
import UIKit
import Firebase
import FirebaseAuth
import SDWebImage
class ProfileViewController: UIViewController {

    @IBOutlet weak var profilPic: UIImageView!

    @IBOutlet weak var nameTxt: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
      
//        nameTxt.text = registerVC.fNameTxtField.text
        // Do any additional setup after loading the view.
        profilPic.layer.cornerRadius = profilPic.frame.size.width/2
        profilPic.layer.borderWidth = 1
        profilPic.layer.borderColor = UIColor.white.cgColor
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        let nameTxtt = UserDefaults.standard.value(forKey: "name") as? String
//        self.nameTxt.text = nameTxtt
        let profileImgeSTR = UserDefaults.standard.value(forKey: "profile_picture_url") as! String
        let uRL = URL.init(string: profileImgeSTR)
        self.profilPic.sd_setImage(with: uRL, completed: nil)
       
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
       
        validateAuth()
    }
    @IBAction func logOutBtnPress(_ sender: Any) {
        do {
                    try Auth.auth().signOut()
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    let vc = storyboard.instantiateViewController(withIdentifier: "LogInViewController")
//            self?.navigationController?.pushViewController(vc, animated: true)
            (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.changeRootViewController(vc)
                }
                catch {
                    print("dosn't log Out ")
                } }
    private func validateAuth(){
                // current user is set automatically when you log a user in
            if Auth.auth().currentUser == nil {
                // present login view controller if user not logged in
                let vc = storyboard?.instantiateViewController(withIdentifier: "LogInViewController") as! LogInViewController
                let nav = UINavigationController(rootViewController: vc)
                nav.modalPresentationStyle = .fullScreen
                present(nav, animated: false)
            }
            }
  

}
