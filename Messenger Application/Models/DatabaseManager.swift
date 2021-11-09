//
//  DatabaseManager.swift
//  Messenger Application
//
//  Created by administrator on 01/11/2021.
//

import Foundation
import FirebaseDatabase
import FirebaseStorage
import SwiftUI
// singleton creation below
// final - cannot be subclassed
final class DatabaseManger {
    
    static let shared = DatabaseManger()
   
    // reference the database below
    static func safeEmail(emailAddress: String) -> String {
        var safeEmail = emailAddress.replacingOccurrences(of: ".", with: "-")
        safeEmail = safeEmail.replacingOccurrences(of: "@", with: "-")
        return safeEmail
    }
    private let database = Database.database().reference()
    public typealias UploadPictureCompletion = (Result<String,Error>)->Void
    private let storage = Storage.storage().reference()
    // create a simple write function
    
    public enum StorageErrors:Error{
        case filedToUpload
        case faildToGetDownloadUrl
    }
    
//    public func storeInDatabase(FirsName: String, LastName: String) {
//        // NoSQL - JSON (keys and objects)
//        // child refers to a key that we want to write data to
//        // in JSON, we can point it to anything that JSON supports - String, another object
//        // for users, we might want a key that is the user's email addresscopy
//
//        database.child("User").setValue(["First_Name": FirsName, "Last_Name": LastName])
//
//    }
}
// MARK: - account management
extension DatabaseManger {
    
    // have a completion handler because the function to get data out of the database is asynchrounous so we need a completion block
    
    public func uploadProfilePicture(with data: Data, fileName: String, completion: @escaping UploadPictureCompletion){
        storage.child("images/\(fileName)").putData(data,metadata: nil){metadata,error in
            guard error == nil else {
                print("the upload dosn't work ")
                completion(.failure(StorageErrors.filedToUpload))
                return
            }
            self.storage.child("images/\(fileName)").downloadURL { url, error in
                guard let url = url , error == nil else {
                              print("Failed to get download url")
                              completion(.failure(StorageErrors.faildToGetDownloadUrl))
                              return
                          }
                          
                          let urlString = url.absoluteString
                          
                          print("download url returned: \(urlString)")
                          
                          completion(.success(urlString))
                      }
           
        }
    }

    public func userExists(with email:String, completion: @escaping ((Bool) -> Void)) {
        // will return true if the user email does not exist
        
        // firebase allows you to observe value changes on any entry in your NoSQL database by specifying the child you want to observe for, and what type of observation you want
        // let's observe a single event (query the database once)
        
        var safeEmail = email.replacingOccurrences(of: ".", with: "-")
        safeEmail = safeEmail.replacingOccurrences(of: "@", with: "-")
        
        database.child(safeEmail).observeSingleEvent(of: .value,with:{ snapshot in
            // snapshot has a value property that can be optional if it doesn't exist
            
            guard snapshot.value as? String != nil else {
                // otherwise... let's create the account
                completion(false)
                return
            }
            
            // if we are able to do this, that means the email exists already!
            
            completion(true) // the caller knows the email exists already
        })
    }
    
    /// Insert new user to database
    public func insertUser(with user: ChatAppUser){
        let userDic = ["first_name":user.firstName,"last_name":user.lastName ,"E_mail": user.emailAddress ]
        database.child(user.safeEmail).setValue(userDic){ error ,_ in
            self.userExists(with: user.emailAddress, completion: { isInserted in
               if isInserted == true {
                   print("work!")
               }else{
                   print("")
               }
            })
       
        }
    }
    func createUser(user:ChatAppUser,completion: @escaping(String?)->Void){
        database.child(user.safeEmail).setValue([
            "first_name" : user.firstName,
            "last_name" : user.lastName
        ]) {error, reference in
            guard error == nil else{
                return
            }
            //--
            self.database.child("users").observeSingleEvent(of: .value) { snapshot in
                if var useersDic = snapshot.value as? [[String: String]]{
                    let newElement = [
                        "name": user.firstName + "_" + user.lastName,
                        "email": user.safeEmail]
                    useersDic.append(newElement)
                    self.database.child("users").setValue(useersDic)

                completion(nil)
                    
                }
            else {
                var UserDic: [[String: String]] = [[
                "name": user.firstName + "_" + user.lastName,
                "email": user.safeEmail
               ]
               ]
                self.database.child("users").setValue(UserDic)
                //--
                completion(nil)        }
    }
}
    }
    //--
    public func getAllUsers(completion: @escaping (Result<[[String: String]],Error>)->Void){
        database.child("users").observeSingleEvent(of: .value, with: { snapshot  in
            guard let value = snapshot.value as? [[String: String]] else {
                completion(.failure(DataBeaseError.failedToFetch))
                return
            }
            completion(.success(value))
        })
    }
    public enum DataBeaseError: Error {
        case failedToFetch
    }
    //--
}
//sending message
extension DatabaseManger {
    public func createNewConversation(with otherUserEmail: String, name: String,currentUserName: String,firstMessage: Message,completion:@escaping(Bool?)-> Void){
        guard let currentEmail = UserDefaults.standard.value(forKey: "email") as? String else{
            return
        }
        var safeEmail = DatabaseManger.safeEmail(emailAddress: currentEmail)
        safeEmail = safeEmail.lowercased()
        let ref = database.child("\(safeEmail)")
        ref.observeSingleEvent(of: .value,with: { [weak self] snapshot in
            guard var userNode = snapshot.value as? [String: Any] else{
                completion(false)
                print("user dosn't found")
                return
            }
            let messageDate = firstMessage.sentDate
            let dateString = ChatViewController.dateFormatter.string(from: messageDate)
            var message = ""
            switch firstMessage.kind{
                
            case .text(let messageTxt):
                message = messageTxt
            case .attributedText(_):
                break
            case .photo(_):
                break

            case .video(_):
                break
            case .location(_):
                break
            case .emoji(_):
                break
            case .audio(_):
                break
            case .contact(_):
                break
            case .linkPreview(_):
                break
            case .custom(_):
                break
            }
            let conversationId = "Conversation_\(firstMessage.messageId)"
            let newConversationData: [String:Any] = [
                "id": conversationId,
                "other_user_email":otherUserEmail,
                "name": name,
                "latest_message": [
                    "date": dateString,
                    "message": message,
                    "is_read":false
                ]
            ]
            //لليووزر
            
           
            //
            let safeEail = DatabaseManger.safeEmail(emailAddress: otherUserEmail).lowercased()
            
            let reff = self?.database.child("\(safeEail)")
            reff?.observeSingleEvent(of: .value,with: { [weak self] snapshot in
                guard var otheruserNode = snapshot.value as? [String: Any] else{
                    completion(false)
                    print("user dosn't found")
                    return
                }
                let recipient_NewConversationData: [String:Any] = [
                    "id": conversationId,
                    "other_user_email":safeEmail,
                    "name": "\(userNode["first_name"]!)_\(userNode["last_name"]!)",
                    "latest_message": [
                        "date": dateString,
                        "message": message,
                        "is_read":false
                    ]
                ]
                
            if var conversations = otheruserNode["conversations"] as? [[String: Any]]{
                conversations.append(recipient_NewConversationData)
                otheruserNode["conversations"] = conversations

                reff!.setValue(otheruserNode,withCompletionBlock: { [weak self] error, _ in
                    guard error == nil else {
                        completion(false)
                        return
                    }
                   
                })
            }else{
                otheruserNode["conversations"] = [
                recipient_NewConversationData
               ]
                reff!.setValue(otheruserNode,withCompletionBlock: {[weak self] error, _ in
                    guard error == nil else {
                        completion(false)
                        return
                    }
                   
                })
            }
            })
            //
            if var conversations = userNode["conversations"] as? [[String: Any]]{
                conversations.append(newConversationData)
                userNode["conversations"] = conversations

                ref.setValue(userNode,withCompletionBlock: { [weak self] error, _ in
                    guard error == nil else {
                        completion(false)
                        return
                    }
                    self?.finishCreatingConversation(name: name, conversationID: conversationId, firstMessage: firstMessage, completion: completion)
                })
            }else{
               userNode["conversations"] = [
                newConversationData
               ]
                ref.setValue(userNode,withCompletionBlock: {[weak self] error, _ in
                    guard error == nil else {
                        completion(false)
                        return
                    }
                    self?.finishCreatingConversation(name:name,conversationID: conversationId, firstMessage: firstMessage, completion: completion)
                })
            }
        })
    }
    private func finishCreatingConversation( name:String,conversationID: String, firstMessage: Message, completion: @escaping (Bool) -> Void) {
//        {
//            "id": String,
//            "type": text, photo, video,
//            "content": String,
//            "date": Date(),
//            "sender_email": String,
//            "isRead": true/false,
//        }
        let messageDate = firstMessage.sentDate
        let dateString = ChatViewController.dateFormatter.string(from: messageDate)
        var message = ""
        switch firstMessage.kind{
            
        case .text(let messageTxt):
            message = messageTxt
        case .attributedText(_):
            break
        case .photo(_):
            break

        case .video(_):
            break
        case .location(_):
            break
        case .emoji(_):
            break
        case .audio(_):
            break
        case .contact(_):
            break
        case .linkPreview(_):
            break
        case .custom(_):
            break
        }
        guard let  myEmail = UserDefaults.standard.value(forKey: "email") as? String else{
            completion(false)
            return
        }
        let currentUserEmail = DatabaseManger.safeEmail(emailAddress: myEmail)
        let messageDic: [String:Any] = [
            "id": firstMessage.messageId,
            "type": firstMessage.kind.messageKindString,
                       "content": message ,
                       "date":dateString,
                       "sender_email": currentUserEmail,
                       "isRead": false,
            "name": name
        ]
        let value: [String:Any] = [
            "messages": [
            messageDic
            ]
        ]
        print("adding convo:\(conversationID)")
        database.child("\(conversationID)").setValue(value, withCompletionBlock: {error, _ in
            guard error == nil else{
                completion(false)
                return
            }
            completion(true)
        })
    }
    public func getAllConversation(for email: String,completion: @escaping(Result<[Conversation],Error>)->Void){
        database.child("\(email)/conversations").observe(.value,with: {snapshot in
            guard let value = snapshot.value as? [[String:Any]] else{
                completion(.failure(DataBeaseError.failedToFetch))
                return
            }
            let conversations: [Conversation] = value.compactMap ({ dictionary in
                guard let conversationId = dictionary["id"] as? String,
                      let name = dictionary["name"] as? String,
                      let otherUserEmail = dictionary["other_user_email"] as? String,
                      let latestMessage = dictionary["latest_message"] as? [String:Any],
                      let date = latestMessage["date"] as? String,
                      let message = latestMessage["message"] as? String,
                      let isRead = latestMessage["is_read"] as? Bool else{
                          return nil
                      }
                let latestMmessageObject = LatestMessage(date: date,
                                                         text: message,
                                                         isRead: isRead)
                return Conversation(id: conversationId,
                                    name: name,
                                    otherUserEmail: otherUserEmail,
                                    latestMessage: latestMmessageObject)

            })
            completion(.success(conversations))
        })
    }
    public func getAllMessageForConversation(with id: String, completion: @escaping (Result<[Message],Error>)->Void){
        database.child("\(id)/messages").observe(.value,with: {snapshot in
            guard let value = snapshot.value as? [[String:Any]] else{
                completion(.failure(DataBeaseError.failedToFetch))
                return
            }
            let messages: [Message] = value.compactMap ({ dictionary in
                guard let name = dictionary["name"] as? String,
                    let isRead = dictionary["is_read"] as? Bool,
                    let messageID = dictionary["id"] as? String,
                    let content = dictionary["content"] as? String,
                    let senderEmail = dictionary["sender_email"] as? String,
                    let type = dictionary["type"] as? String,
                    let dateString = dictionary["date"] as? String,
                    let date = ChatViewController.dateFormatter.date(from: dateString)else {
                        return nil
                }
                let sender = Sender(photoURL: "", senderId:
                                        senderEmail,
                                    displayName: name)
                return Message(sender: sender,
                               messageId: messageID,
                               sentDate: date,
                               kind: .text(content))
            
            })
            completion(.success(messages))
        })
    }
    
    public func sendMessage(to conversation: String, name: String, newMessage: Message, completion: @escaping (Bool) -> Void) {
        // return bool if successful
        
        // add new message to messages
        // update sender latest message
        // update recipient latest message
        
        self.database.child("\(conversation)/messages").observeSingleEvent(of: .value,with: { [weak self] snapshot in
            
            guard let strongSelf = self else {
                return
            }
            
            guard var currentMessages = snapshot.value as? [[String: Any]] else {
                debugPrint("Cannot get messages")
                completion(false)
                return
            }
            
            let messageDate = newMessage.sentDate
            let dateString = ChatViewController.dateFormatter.string(from: messageDate)
            
            var message = ""
            
            switch newMessage.kind {
            case .text(let messageText):
                message = messageText
            case .attributedText(_):
                break
            case .photo(_):
                break
            case .video(_):
                break
            case .location(_):
                break
            case .emoji(_):
                break
            case .audio(_):
                break
            case .contact(_):
                break
            case .linkPreview(_):
                break
            case .custom(_):
                break
            }
            
            guard let myEmail = UserDefaults.standard.value(forKey: "email") as? String else {
                completion(false)
                return
            }
            
            let currentUserEmail = DatabaseManger.safeEmail(emailAddress: myEmail)
            
            let newMessageEntry: [String: Any] = [
                "id": newMessage.messageId,
                "type": newMessage.kind.messageKindString,
                "content": message,
                "date": dateString,
                "sender_email": currentUserEmail,
                "is_read": false,
                "name": name,
            ]
            
            currentMessages.append(newMessageEntry)
            
            strongSelf.database.child("\(conversation)/messages").setValue(currentMessages,withCompletionBlock: { error, _ in
                guard error == nil else {
                    completion(false)
                    return
                }
                completion(true)
                
            })
            
        })
        
    }
    
}




struct ChatAppUser {
    let firstName: String
    let lastName: String
    let emailAddress: String
    var profilePictureFilName: String{
        return "\(safeEmail)_profile_picture.png"
    }

    // create a computed property safe email
    
    var safeEmail: String {
        var safeEmail = emailAddress.replacingOccurrences(of: ".", with: "-")
        safeEmail = safeEmail.replacingOccurrences(of: "@", with: "-")
        return safeEmail
    }
}
struct Conversation {
    let id :String
    let name : String
    let otherUserEmail : String
    
    let latestMessage :LatestMessage
    
}

struct LatestMessage {
    let date : String
    let text : String
    let isRead :Bool
    
}

    
    
    
