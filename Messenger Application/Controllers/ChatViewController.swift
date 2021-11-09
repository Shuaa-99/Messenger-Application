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
    private var currentUserName: String = ""
    private var selfSender: Sender? {
        guard let email = UserDefaults.standard.value(forKey: "email") as? String else{
            return nil
        }
        let safeEmail = DatabaseManger.safeEmail(emailAddress: email)
   return  Sender(photoURL: "",
        senderId: safeEmail ,
             displayName: "Me")
    
}
   
    init(with email: String, id: String?)
    {
     self.conversationId = id
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
    private func listenForMessages(id: String,shouldScrollToBottom: Bool){
        DatabaseManger.shared.getAllMessageForConversation(with: id, completion: {[weak self] result in
            switch result{
            case .success(let messages):
                print("success in getting messages\(messages)")
                guard !messages.isEmpty else{
                    print(" messages are empty")

                    return
                }
                self?.messages = messages
                DispatchQueue.main.async {
                    self?.messagesCollectionView.reloadDataAndKeepOffset()

                    if shouldScrollToBottom{
                        self?.messagesCollectionView.scrollToBottom()

                    }
                }
            case .failure(let error):
                print("failed to get message\(error)")
            }
        })
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        messageInputBar.inputTextView.becomeFirstResponder()
        if let conversationId = conversationId {
            listenForMessages(id: conversationId, shouldScrollToBottom: true)

        }
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
        let message = Message(sender: selfSender, messageId: messageId, sentDate: Date(), kind: .text(text))
        if isNewConversation{
            let message = Message(sender: selfSender,
                                  messageId: messageId,
                                  sentDate: Date(),
                                  kind: .text(text))
            DatabaseManger.shared.createNewConversation(with: otherUserEmail, name: self.title ?? "User", currentUserName: self.currentUserName, firstMessage: message) { [weak self] conversationId in
                if conversationId != false {
                    print("message sent")
//                    self?.conversationId = conversationId as? String
//                    self?.isNewConversation = false
//                    self?.listenForMessages(id: conversationId, shouldScrollToBottom: true)


                }else{
                    print("dosn't sent")
                }
            }
        }
        else{guard let conversationId = conversationId, let name = self.title else {
            return}
            // append to existing conversation data
            DatabaseManger.shared.sendMessage(to: conversationId, name: name, newMessage: message) { success in
                if success {
                    print("message sent")
                }else {
                    print("failed to send")
                }
            }
            
        
        }
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
       
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return messages[indexPath.section]
    }
    
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return messages.count
    }
}
