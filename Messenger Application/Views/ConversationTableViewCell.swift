//
//  ConversationTableViewCell.swift
//  Messenger Application
//
//  Created by administrator on 07/11/2021.
//

import UIKit
import SDWebImage
class ConversationTableViewCell: UITableViewCell {
    static let identifier = "ConversationTableViewCell"

    private let userImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 50
        imageView.layer.masksToBounds = true
        return imageView
    }()
    
       private let userNameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 21, weight: .semibold)
        return label
    }()
    private let userMessageLable: UILabel = {
     let label = UILabel()
     label.font = .systemFont(ofSize: 19, weight: .regular)
        label.numberOfLines = 0
     return label
 }()
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(userImageView)
        contentView.addSubview(userNameLabel)
        contentView.addSubview(userMessageLable)
        userNameLabel.translatesAutoresizingMaskIntoConstraints = false
        userNameLabel.leadingAnchor.constraint(equalTo: userImageView.trailingAnchor,constant: 20).isActive = true
        userNameLabel.centerYAnchor.constraint(equalTo: userImageView.centerYAnchor).isActive = true
        userMessageLable.translatesAutoresizingMaskIntoConstraints = false
        userMessageLable.leadingAnchor.constraint(equalTo: userImageView.trailingAnchor,constant: 20).isActive = true
        userMessageLable.topAnchor.constraint(equalTo: userNameLabel.bottomAnchor,constant: 5).isActive = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        userImageView.frame = CGRect(x: 10,
                                     y: 10,
                                     width: 100,
                                     height: 100)

        

    }
    public func configure(with model: Conversation){
        self.userMessageLable.text = model.latestMessage.text
        self.userNameLabel.text = model.name
        let path = "images/\(model.otherUserEmail)_profile_picture.png"
//        DatabaseManger.shared.uploadProfilePicture(with: <#T##Data#>, fileName: model., [weak self] result in
//            switch result {
//            case .success(let url):
//
//                DispatchQueue.main.async {
//                    self?.userImageView.sd_setImage(with: url, completed: nil)
//                }
//
//            case .failure(let error):
//                print("failed to get image url: \(error)")
//            }
//        })
        
    }
}
