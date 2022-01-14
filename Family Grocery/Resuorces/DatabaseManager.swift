//
//  DatabaseManager.swift
//  Family Grocery
//
//  Created by administrator on 12/01/2022.
//

import Foundation
import FirebaseDatabase

final class DatabaseManger {
    
    static let shared = DatabaseManger()
    
    // reference the database below
    
    private let database = Database.database().reference()
    
    static func safeEmail(emailAddress : String) -> String {
        var safeEmail = emailAddress.replacingOccurrences(of: ".", with: "-")
        safeEmail = safeEmail.replacingOccurrences(of: "@", with: "-")
        return safeEmail
    }
    
}

// MARK: - account management
extension DatabaseManger {
    // have a completion handler because the function to get data out of the database is asynchrounous so we need a completion block
    
    public func userExists(with email:String, completion: @escaping ((Bool) -> Void)) {
        // will return true if the user email does not exist
        
        // firebase allows you to observe value changes on any entry in your NoSQL database by specifying the child you want to observe for, and what type of observation you want
        // let's observe a single event (query the database once)
        
       // var safeEmail = DatabaseManger.safeEmail(emailAddress: email)
        
        var safeEmail = email.replacingOccurrences(of: ".", with: "-")
        safeEmail = safeEmail.replacingOccurrences(of: "@", with: "-")
        
        database.child(safeEmail).observeSingleEvent(of: .value) { snapshot in
            // snapshot has a value property that can be optional if it doesn't exist
            
            guard snapshot.value as? String != nil else {
                // otherwise... let's create the account
                completion(false)
                return
            }
            
            // if we are able to do this, that means the email exists already!
            
            completion(true) // the caller knows the email exists already
        }
    }
    
    /// Insert new user to database
    public func insertUser(with user: User, completion: @escaping (Bool) -> Void){
        // adding completion block here so once it's done writing to database, we want to upload the image
        self.database.child("users").observeSingleEvent(of: .value) { snapshot in
            // snapshot is not the value itself
            if var usersCollection = snapshot.value as? [String: String] {
                usersCollection[user.id] = user.email
                
                self.database.child("users").setValue(usersCollection) { error, _ in
                    guard error == nil else {
                        completion(false)
                        return
                    }
                    completion(true)
                }
                
            }else{
                // create that array
                let newCollection: [String: String] =
                    [
                        user.id : user.email
                    ]
                
                self.database.child("users").setValue(newCollection) { error, _ in
                    guard error == nil else {
                        completion(false)
                        return
                    }
                    completion(true)
                }
            }
        }
    }
    
    /// online users .. 
    public func onlineUsers(with user: User, completion: @escaping (Bool) -> Void){
        // adding completion block here so once it's done writing to database, we want to upload the image
        self.database.child("online").observeSingleEvent(of: .value) { snapshot in
            // snapshot is not the value itself
            if var usersCollection = snapshot.value as? [String: String] {
                // if var so we can make it mutable so we can append more contents into the array, and update it
                usersCollection[user.id] = user.email
                
                self.database.child("online").setValue(usersCollection) { error, _ in
                    guard error == nil else {
                        completion(false)
                        return
                    }
                    completion(true)
                }
                
            }else{
                let newCollection: [String: String] =
                    [
                        user.id : user.email
                    ]
                
                self.database.child("online").setValue(newCollection) { error, _ in
                    guard error == nil else {
                        completion(false)
                        return
                    }
                    completion(true)
                }
            }
        }
    }
    
    public func offlineUser(user:User , completion : @escaping (Bool) -> Void){
        self.database.child("online").observeSingleEvent(of: .value) { snapshot in
           if var usersCollection = snapshot.value as? [String:String] {
            usersCollection[user.id] = nil
            
            self.database.child("online").setValue(usersCollection) { error, _ in
                guard error == nil else {
                    completion(false)
                    return
                }
                completion(true)
               }
            }
        }
    }
}

// MARK: - dealing with Grocery Items

extension DatabaseManger {
    
    public func insertItem(with item:Item, completion: @escaping (Bool) -> Void){
        self.database.child("grocery-items").observeSingleEvent(of: .value) { snapshot in
            // snapshot is not the value itself
            if var usersCollection = snapshot.value as? [String:Any] {
                usersCollection[item.name] = [
                    "name":item.name,
                    "addByUser":item.addByUser,
                    "completed":item.completed
                ]
                
                self.database.child("grocery-items").setValue(usersCollection) { error, _ in
                    guard error == nil else {
                        completion(false)
                        return
                    }
                    completion(true)
                }
                
            }else{
                let newCollection : [String:Any] = [
                    item.name : [
                        "name":item.name,
                        "addByUser":item.addByUser,
                        "completed":item.completed
                    ]
                ]
                    
                self.database.child("grocery-items").setValue(newCollection) { error, _ in
                    guard error == nil else {
                        completion(false)
                        return
                    }
                    completion(true)
                }
            }
        }
    }
    
    public func getGroceryItems(completion:@escaping (Result<[String:Any], Error >)->Void){
        self.database.child("grocery-items").observeSingleEvent(of: .value, with: {snapshot in
            guard let result = snapshot.value as? [String:Any] else {
                completion(.failure(DatabaseError.failedToFetch))
                return
            }
            completion(.success(result))
        })
    }
    
    public enum DatabaseError: Error {
           case failedToFetch
       }
}

struct User{
    var id:String
    var email:String
}

struct Item {
    var name:String
    var addByUser : String
    var completed = false
}
