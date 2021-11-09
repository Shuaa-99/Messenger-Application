//
//  ConversationViewController.swift
//  Messenger Application
//
//  Created by administrator on 27/10/2021.
//

import UIKit

import Firebase
import FirebaseAuth
import JGProgressHUD
import IQKeyboardManagerSwift
import SwiftUI
struct conversation{
    let id: String
    let name: String
    let otherUserEmail: String
    let latestMessage: LatestMessage
}
struct latestMessage{
    let date: String
    let text: String
    let isRead: Bool
}
class ConversationViewController: UIViewController {

    private let spinner = JGProgressHUD(style: .dark)
   private var conversations = [Conversation]()
    
    private let tableView: UITableView = {
           let table = UITableView()
 table.isHidden = true
      table.register(ConversationTableViewCell.self,
                      forCellReuseIdentifier: ConversationTableViewCell.identifier)
      
        return table
    }()

    private let noConversationsLabel: UILabel = {
        let label = UILabel()
        label.text = "No Conversations!"
        label.textAlignment = .center
        label.textColor = .gray
        label.font = .systemFont(ofSize: 21, weight: .medium)
        label.isHidden = true
        return label
    }()
    @IBAction func startNewCovBtn(_ sender: UIBarButtonItem) {
        let vvc = NewConversationViewController()
        vvc.completion = {
            [weak self] result in
               print("\(result)")
            self?.createNewConversation(result: result)
        }
        let navVVC = UINavigationController(rootViewController: vvc)
        present(navVVC,animated: true)
    }
    private func createNewConversation(result:[String: String]){
        guard let name = result["name"],
              let email = result["email"] else{
                  return
              }
        let vcc = ChatViewController(with: email, id: nil)
        vcc.isNewConversation = true
        vcc.title = name
    vcc.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(vcc, animated: true)
    }
   
    override func viewDidLayoutSubviews() {
           super.viewDidLayoutSubviews()
           tableView.frame = view.bounds
       }
    override func viewDidLoad() {
           super.viewDidLoad()
           view.addSubview(tableView)
           view.addSubview(noConversationsLabel)
           setupTableView()
           fetchConversations()
       }
    private func startListeningForCOnversations() {
        guard let email = UserDefaults.standard.value(forKey: "email") as? String else {
            return
        }
        let safeEmail = DatabaseManger.safeEmail(emailAddress: email)

        DatabaseManger.shared.getAllConversation(for: safeEmail) { [weak self] result in
            switch result {
            case .success(let conversations):
                print("successfully got conversation models")
                guard !conversations.isEmpty else {
                    return
                }
                self?.conversations = conversations
                
                DispatchQueue.main.async {
                    self?.tableView.reloadData()
                }
            case .failure(let error):
                print("failed to get convos \(error)")
                
            }
           
        }


}
    
                override func viewDidAppear(_ animated: Bool) {
                    super.viewDidAppear(animated)
                    
                    startListeningForCOnversations()
                }

    private func setupTableView() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
               tableView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
               tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
               tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
               tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
               tableView.delegate = self
               tableView.dataSource = self
    }
    private func fetchConversations(){
        // fetch from firebase and either show table or label
        let email = UserDefaults.standard.value(forKey: "email") as! String
        let safeEmail = DatabaseManger.safeEmail(emailAddress: email).lowercased()
        DatabaseManger.shared.getAllConversation(for: safeEmail) { result in
            switch result{
            case .success(let conversations):
                self.conversations = conversations
                
                self.tableView.reloadData()
                
            case .failure(let error):
                break
            }
            
           
        }
            
        tableView.isHidden = false
    }
}

extension ConversationViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return conversations.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = conversations[indexPath.row]
      let cell = tableView.dequeueReusableCell(withIdentifier: ConversationTableViewCell.identifier, for: indexPath) as! ConversationTableViewCell
       cell.configure(with: model)
       
       // cell.textLabel?.text = "Hi world"
       // cell.accessoryType = .disclosureIndicator
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let model = conversations[indexPath.row]

        let vcc = ChatViewController(with: model.otherUserEmail, id: model.id)
        vcc.title = model.name
       vcc.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(vcc, animated: true)
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 118
    }

}
