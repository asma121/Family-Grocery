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
    
    // '/' '.' '#' '$' '[' or ']''
    public func itemKey(key : String) -> String {
        var safeKey = key.replacingOccurrences(of: ".", with: " ")
        safeKey = safeKey.replacingOccurrences(of: "/", with: " ")
        safeKey = safeKey.replacingOccurrences(of: "#", with: " ")
        safeKey = safeKey.replacingOccurrences(of: "$", with: " ")
        safeKey = safeKey.replacingOccurrences(of: "[", with: " ")
        safeKey = safeKey.replacingOccurrences(of: "]", with: " ")
        return safeKey
    }
        
}

// MARK: - account management
extension DatabaseManger {
    /// online users .. append to "online" if it's exist  or create it if it's not ..
    public func onlineUsers(with user: User, completion: @escaping (Bool) -> Void){
        self.database.child("online").observeSingleEvent(of: .value) { snapshot in
            if var usersCollection = snapshot.value as? [String: String] {
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
    
    /// get online users by observing root "online" ..
    public func getOnlineUsers(completion: @escaping (Result<[String:String], Error>) -> Void){
        self.database.child("online").observeSingleEvent(of: .value, with: { snapshot in
            guard let result = snapshot.value as? [String:String] else {
                completion(.failure(DatabaseError.failedToFetch))
                return
            }
            completion(.success(result))
        })
    }
    
    /// putting user in offline mode by assgining nil ..
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
    /// insert an item .. append to "grocery-items" if it's exist  or create it if it's not ..
    public func insertItem(with item:Item, completion: @escaping (Bool) -> Void){
        let key = itemKey(key: item.name)
        self.database.child("grocery-items").observeSingleEvent(of: .value) { snapshot in
            if var itemsCollection = snapshot.value as? [String:Any] {
                itemsCollection[key] = [
                    "name":item.name,
                    "addByUser":item.addByUser,
                    "completed":item.completed
                ]
                
                self.database.child("grocery-items").setValue(itemsCollection) { error, _ in
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
    
    /// get grocery Items by observing root "grocery-items" ..
    public func getGroceryItems(completion:@escaping (Result<[String:Any], Error >)->Void){
        self.database.child("grocery-items").observeSingleEvent(of: .value, with: {snapshot in
            guard let result = snapshot.value as? [String:Any] else {
                completion(.failure(DatabaseError.failedToFetch))
                return
            }
            completion(.success(result))
        })
    }
    
    /// updating item by assgining nil to it  .. then add the new one ..
    public func updateGroceryItem(oldItemName : String, newItemName:String, completion:@escaping (Bool)->Void ){
      
        guard let addByUser = UserDefaults.standard.value(forKey: "userEmail") as? String else {
            return
        }
        self.database.child("grocery-items").observeSingleEvent(of: .value) { snapshot in
           if var items = snapshot.value as? [String:Any] {
            let oldKey = self.itemKey(key: oldItemName)
            let newKey = self.itemKey(key: newItemName)
            let newItem = Item(name: newItemName, addByUser: addByUser)
             items[oldKey] = nil
            items[newKey] = [
                "name":newItem.name,
                "addByUser":newItem.addByUser,
                "completed":newItem.completed
            ]
            
            self.database.child("grocery-items").setValue(items) { error, _ in
                guard error == nil else {
                    completion(false)
                    return
                }
                completion(true)
               }
            }
        }
        
    }
    
    /// deleting item by assgining nil to it  ..
    public func deleteGroceryItem(itemName:String , completion : @escaping (Bool) -> Void){
        self.database.child("grocery-items").observeSingleEvent(of: .value) { snapshot in
           if var items = snapshot.value as? [String:Any] {
             items[itemName] = nil
            
            self.database.child("grocery-items").setValue(items) { error, _ in
                guard error == nil else {
                    completion(false)
                    return
                }
                completion(true)
               }
            }
        }
    }
    
    public enum DatabaseError: Error {
           case failedToFetch
       }
}

