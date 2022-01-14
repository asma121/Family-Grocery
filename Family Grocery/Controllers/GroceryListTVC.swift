//
//  GroceryListTVC.swift
//  Family Grocery
//
//  Created by administrator on 11/01/2022.
//

import UIKit
import FirebaseAuth

class GroceryListTVC: UITableViewController {
    
    public var groceryItemList = [[String:Any]]()
    public var numberOfOnlineUsers = 0
   

    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "plus"), style: .plain, target: self, action: #selector(addItemAlert))
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "\(numberOfOnlineUsers)", style: .plain, target: self, action: #selector(familyOnlineList))
        self.navigationItem.title = "Groceries To Buy"
        
        fetchItems()
       
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
        return  groceryItemList.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "GroceryListCell", for: indexPath)
        cell.textLabel?.text = groceryItemList[indexPath.row]["name"] as? String
        cell.detailTextLabel?.text = groceryItemList[indexPath.row]["addByUser"] as? String
       return cell
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        let name = groceryItemList[indexPath.row]["name"] as? String
        self.deletItem(itemName: name!)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let oldName = groceryItemList[indexPath.row]["name"] as? String
        self.updateItemAlert(oldName: oldName!)
    }
 

    
    @objc func familyOnlineList(){
        let  familyTVC = self.storyboard?.instantiateViewController(identifier: "FamilyTVC") as! FamilyTVC
        //self.numberOfOnlineUsers = familyTVC.onlineUsers.count
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
    
    func updateItemAlert(oldName:String){
       let alert = UIAlertController(title: "Grocery Item", message: "update an Item", preferredStyle: .alert)
       alert.addTextField()
        alert.textFields?[0].text = oldName
         
       alert.addAction(UIAlertAction(title: "Save", style: .default , handler: { action in
           guard let itemName = alert.textFields?[0].text , !itemName.isEmpty else {
               return
           }
           self.updateItem(oldName: oldName, newName: itemName)
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
                self.fetchItems()
            }
        })
    }
    
    func fetchItems(){
        DatabaseManger.shared.getGroceryItems { result in
            switch result {
            case .success(let groceryItems):
                self.groceryItemList.removeAll()
                for value in groceryItems.values {
                    guard let item = value as? [String:Any] else {
                        return
                    }
                    self.groceryItemList.append(item)
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                }
            case .failure(let error):
                print("faild to get items \(error)")
            }
        }
    }
    
    func updateItem(oldName: String , newName:String){
        DatabaseManger.shared.updateGroceryItem(oldItemName: oldName, newItemName: newName, completion: { success in
            if success{
                print("item updated .. ")
                self.fetchItems()
            }
        })
    }
    
    func deletItem(itemName : String){
        DatabaseManger.shared.deleteGroceryItem(itemName: itemName, completion: { success in
            if success {
                print("item Deleted .. ")
                self.fetchItems()
            }
        })
    }

}
