//
//  NewConversationViewController.swift
//  Messenger Application
//
//  Created by administrator on 27/10/2021.
//

import UIKit
import MessageKit
import InputBarAccessoryView
struct Message: MessageType{
  public  var sender: SenderType
 public   var messageId: String
  public  var sentDate: Date
 public   var kind: MessageKind
}
extension MessageKind {
    var messageKindString: String {
        switch self {
        case .text(_):
            return "text"
        case .attributedText(_):
            return "attributed_text"
        case .photo(_):
            return "photo"
        case .video(_):
            return "video"
        case .location(_):
            return "location"
        case .emoji(_):
            return "emoji"
        case .audio(_):
            return "audio"
        case .contact(_):
            return "contact"
        case .linkPreview(_):
            return "link_preview"
        case .custom(_):
            return "custom"
        }
    }
}
struct Sender: SenderType{
   public var photoURL: String
public    var senderId: String
    public var displayName: String
}

class ChatViewController: MessagesViewController {
    public static let dateFormatter: DateFormatter = {
        let formattre = DateFormatter()
        formattre.dateStyle = .medium
        formattre.timeStyle = .long
        formattre.locale = .current
        return formattre
    }()
    public let otherUserEmail: String
    private var conversationId: String?
    public var isNewConversation = false
    private var messages = [Message]()

    private var selfSender: Sender? {
        guard let email = UserDefaults.standard.value(forKey: "email") as? String else{
            return nil
        }
   return  Sender(photoURL: "",
        senderId: email ,
             displayName: "Shuaa")
    
}
   
    
    init(with email: String)
         //, id: String?)
    {
       // self.conversationId = id
        self.otherUserEmail = email
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
    
        super.viewDidLoad()
      
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        messageInputBar.delegate = self
        // Do any additional setup after loading the view.
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        messageInputBar.inputTextView.becomeFirstResponder()
    }
}
extension ChatViewController: InputBarAccessoryViewDelegate{
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        guard !text.replacingOccurrences(of: " ", with: "").isEmpty,
        let selfSender = self.selfSender,
        let messageId = createMessageId()
        else {
//            let selfSender = self.selfSender,
//            let messageId = createMessageId() else {
                return
       }
        print("sender:\(text)")
        if isNewConversation{
            let message = Message(sender: selfSender, messageId: messageId, sentDate: Date(), kind: .text(text))
            DatabaseManger.shared.createNewConversation(with: otherUserEmail, name: self.title ?? "User" , firstMessage: message, completion: {success in
                if success {
                    print("message sent")
                }else{
                    print("dosn't sent")
                }
            })
        }
        else{}
    }
    private func createMessageId() ->String? {
        guard let currentUserEmail = UserDefaults.standard.value(forKey: "email") as? String
     else {
            return nil
        }
        let safeCurrentEmail = DatabaseManger.safeEmail(emailAddress: currentUserEmail)
        let dateString = Self.dateFormatter.string(from: Date())
        let newID = "\(otherUserEmail)_\(safeCurrentEmail)_\(dateString)"
        print("created Message ID\(newID)")
        return newID
    }
}

extension ChatViewController: MessagesDataSource, MessagesLayoutDelegate, MessagesDisplayDelegate{
    func currentSender() -> SenderType {
        if let sender = selfSender {
        return sender
        }
        fatalError("self Sender is nil ")
        return Sender(photoURL: "", senderId: "12", displayName: "")
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return messages[indexPath.section]
    }
    
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return messages.count
    }
}
