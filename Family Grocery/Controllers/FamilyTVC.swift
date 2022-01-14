//
//  FamilyTVC.swift
//  Family Grocery
//
//  Created by administrator on 12/01/2022.
//

import UIKit
import FirebaseAuth

class FamilyTVC: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Sign out", style: .plain, target: self, action: #selector(signoutButtonTapped))
        self.navigationItem.title = "Family(online)"

    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 0
    }

    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
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

}
