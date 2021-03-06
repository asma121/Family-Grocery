//
//  FamilyTVC.swift
//  Family Grocery
//
//  Created by administrator on 12/01/2022.
//

import UIKit
import FirebaseAuth

class FamilyTVC: UITableViewController {
    
    var onlineUsers = [String]()
    var usersDelegate:OnlineUserDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Sign out", style: .plain, target: self, action: #selector(signoutButtonTapped))
        self.navigationItem.title = "Family(online)"
        fetchOnlineUsers()

    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        fetchOnlineUsers()
        
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return onlineUsers.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FamilyCell", for: indexPath)
        cell.textLabel?.text = onlineUsers[indexPath.row]
        return cell
    }

    
    @objc func signoutButtonTapped(){
        let alert = UIAlertController(title: "Sign Out", message: "would you want to Sign out?", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Sign out", style: .destructive, handler: { action in
            self.signOut()
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler:nil))
        
        present(alert, animated: true, completion: nil)

    }
    
    func fetchOnlineUsers(){
        DatabaseManger.shared.getOnlineUsers(completion: { result in
            switch result {
            case .success(let userCollection):
                self.onlineUsers.removeAll()
                let users = userCollection
                for (_,value) in users {
                    self.onlineUsers.append(value)
                    self.usersDelegate?.getOnlineUsers(number: self.onlineUsers.count)
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                }
            case .failure(let error):
                print("faild to get users : \(error)")
            }
        })
    }
    
    func signOut(){
        do{
            try FirebaseAuth.Auth.auth().signOut()
            let VC = self.storyboard?.instantiateViewController(identifier: "ViewController") as! ViewController
            let nav = UINavigationController(rootViewController: VC)
            nav.modalPresentationStyle = .fullScreen
            present(nav, animated: true)
            
            guard let userID = UserDefaults.standard.value(forKey: "userID") as? String,
                  let userEmail = UserDefaults.standard.value(forKey: "userEmail") as? String else {
                return
            }
            let user = User(id: userID, email: userEmail)
            
            DatabaseManger.shared.offlineUser(user: user, completion: { success in
                if success{
                    print("\(user.email) offline")
                }
            })
        }catch{
            print("Faild to logout")
        }
    }
    
}

protocol OnlineUserDelegate {
    func getOnlineUsers(number : Int)
}
