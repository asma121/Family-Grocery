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
            let offlineUser = User(id: userID, email: userEmail)
            
            DatabaseManger.shared.offlineUser(user: offlineUser, completion: { success in
                if success{
                    print("\(offlineUser.email) offline")
                }
            })
        }catch{
            print("Faild to logout")
        }
    }
    
    func fetchOnlineUsers(){
        DatabaseManger.shared.getOnlineUsers(completion: { result in
            switch result {
            case .success(let userCollection):
                self.onlineUsers.removeAll()
                let users = userCollection
                for (_,value) in users {
                    self.onlineUsers.append(value)
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                }
            case .failure(let error):
                print("faild to get users : \(error)")
            }
        })
    }

}
