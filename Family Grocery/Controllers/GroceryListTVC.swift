//
//  GroceryListTVC.swift
//  Family Grocery
//
//  Created by administrator on 11/01/2022.
//

import UIKit
import FirebaseAuth

class GroceryListTVC: UITableViewController {
    
    var groceryItemList = [Item]()
   

    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "plus"), style: .plain, target: self, action: #selector(addItemAlert))
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "nuoffa", style: .plain, target: self, action: #selector(familyOnlineList))
        self.navigationItem.title = "Groceries To Buy"
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        validateAuth()
        fetchItems()
       
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return groceryItemList.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "GroceryListCell", for: indexPath)
  
        return cell
    }
 

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


    
    @objc func familyOnlineList(){
        let  familyTVC = self.storyboard?.instantiateViewController(identifier: "FamilyTVC") as! FamilyTVC
        navigationController?.pushViewController(familyTVC, animated: true)
    }
    
    @objc func addItemAlert(){
        let alert = UIAlertController(title: "Grocery Item", message: "Add an Item", preferredStyle: .alert)
        alert.addTextField()
          
        alert.addAction(UIAlertAction(title: "Save", style: .default , handler: { action in
            guard let itemName = alert.textFields?[0].text , !itemName.isEmpty else {
                return
            }
            self.addItem(itemName: itemName)
          }))
          
          alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler:nil))
          
          present(alert, animated: true, completion: nil)
    }
    
    func validateAuth(){
        if FirebaseAuth.Auth.auth().currentUser == nil {
            let VC = self.storyboard?.instantiateViewController(identifier: "ViewController") as! ViewController
            let nav = UINavigationController(rootViewController: VC)
            nav.modalPresentationStyle = .fullScreen
            present(nav, animated: true)
        }
    }
    
    func addItem(itemName:String){
        guard let user = UserDefaults.standard.value(forKey: "userEmail") as? String else {
            return
        }
        let item = Item(name: itemName, addByUser: user)
        DatabaseManger.shared.insertItem(with: item, completion: { success in
            if success{
                print(" item added ..")
            }
        })
    }
    
    func fetchItems(){
        DatabaseManger.shared.getGroceryItems { result in
            switch result {
            case .success(let groceryItems):
                print("List \(self.groceryItemList)")
                print("items fetched .. \(groceryItems)")
            case .failure(let error):
                print("faild to get items \(error)")
            }
        }
    }

}
