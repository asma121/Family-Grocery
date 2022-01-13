//
//  ViewController.swift
//  Family Grocery
//
//  Created by administrator on 11/01/2022.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var emailTF: UITextField!
    
    @IBOutlet weak var passwordTf: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.navigationController?.navigationBar.backgroundColor = .lightGray
    }

    @IBAction func loginButtonTapped(_ sender: Any) {
       navgaiteToGroceryListTVC()
    }
    
    @IBAction func signupButtonTapped(_ sender: Any) {
        navgaiteToGroceryListTVC()
    }
    
    func navgaiteToGroceryListTVC(){
        let groceryListTVC = self.storyboard?.instantiateViewController(identifier: "GroceryListTVC") as! GroceryListTVC
        let nav = UINavigationController(rootViewController: groceryListTVC)
        nav.modalPresentationStyle = .fullScreen
        present(nav, animated: true)
    }
}

