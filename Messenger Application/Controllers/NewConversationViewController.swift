//
//  NewChatViewController.swift
//  Messenger Application
//
//  Created by administrator on 03/11/2021.
//

import UIKit
import JGProgressHUD
import SwiftUI
//import protoc_gen_swift
class NewConversationViewController: UIViewController {
    private let spinner = JGProgressHUD(style: .dark)
    public var completion: (([String: String]) -> (Void))?
    private var users = [[String: String]]()
    private var results = [[String: String]]()
    private var hasFetched = false
    private let mySearch : UISearchBar = {
        let mySearchBar = UISearchBar()
        mySearchBar.placeholder = "Search for users ..."
        return mySearchBar
    }()
    private let tableview: UITableView = {
        let table = UITableView()
        table.isHidden = false
        table.register(UITableViewCell.self, forCellReuseIdentifier: "mycell")
        return table
    }()
    private let noResult: UILabel = {
        let lable = UILabel()
        lable.isHidden = true
        lable.text = "No result "
        lable.textAlignment = .center
        lable.textColor = .systemPink
        lable.font = .systemFont(ofSize: 30, weight: .medium)
        return lable
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(noResult)
        view.addSubview(tableview)
        tableview.translatesAutoresizingMaskIntoConstraints = false
        tableview.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        tableview.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        tableview.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        tableview.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        tableview.delegate = self
        tableview.dataSource = self
        
        mySearch.delegate = self
        view.backgroundColor = .white
        navigationController?.navigationBar.topItem?.titleView = mySearch
       
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Cancel",
                                                            style: .done, target: self, action: #selector(dismissSelf))
        // Do any additional setup after loading the view.
        mySearch.becomeFirstResponder()
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableview.frame = view.bounds
//        noResult.frame = CGRect(x: view.intrinsicContentSize.width/4,
//                                      y: (view.intrinsicContentSize.height-200)/2,
//                                      width: view.intrinsicContentSize.width/2,
//                                      height: 200)
    }
 @objc private func dismissSelf() {
        dismiss(animated: true, completion: nil)
    }

}
extension NewConversationViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return results.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
     //   let model = results[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "mycell", for: indexPath)
        cell.textLabel?.text = results[indexPath.row]["name"]
       // cell.configure(with: model)
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        // start conversation
     let targetUserData = results[indexPath.row]
        

        dismiss(animated: true, completion: { [weak self] in
            self?.completion?(targetUserData)
        })

//
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        return 90
//
        
    }
}

extension NewConversationViewController: UISearchBarDelegate{
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar){
        searchUsers(query: searchBar.text!)
        
    }
    
    


    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        guard let text = searchBar.text,!text.replacingOccurrences(of: "", with: "").isEmpty else{
            return
        }
        searchBar.resignFirstResponder()
        results.removeAll()
        spinner.show(in: view)
        self.searchUsers(query: text)
        
    }
    func searchUsers(query: String){
        if hasFetched{
            filterUsers(with: query)
        }
        else{
            DatabaseManger.shared.getAllUsers(completion: { [weak self] result in
                switch result {
                case .success(let usersDic):
                    self?.hasFetched = true
                    self?.users = usersDic
                    self?.filterUsers(with: query)
                case .failure(let error):
                    print("dosn;t get users\(error)")
                }
            })
        }
    }
    func filterUsers(with term: String) {
        guard hasFetched else {
            return
        }
        self.spinner.dismiss()
       let results: [[String: String]] = self.users.filter({
            guard let name = $0["name"]?.lowercased() else{
                return false
            }
            return name.hasPrefix(term.lowercased())
        })
        self.results = results
        updateUI()
    }
    func updateUI() {
        if results.isEmpty {
            noResult.isHidden = false
            tableview.isHidden = true
        }
        else {
           noResult.isHidden = true
                tableview.isHidden = false
                tableview.reloadData()
        }
    }
}
    
