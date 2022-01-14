//
//  ViewController.swift
//  Family Grocery
//
//  Created by administrator on 11/01/2022.
//

import UIKit
import FirebaseAuth

class ViewController: UIViewController {

    @IBOutlet weak var emailTF: UITextField!
    
    @IBOutlet weak var passwordTf: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        //self.navigationController?.navigationBar.backgroundColor = .lightGray
        passwordTf.isSecureTextEntry = true
    }

    @IBAction func loginButtonTapped(_ sender: Any) {
        guard let email = emailTF.text , !email.isEmpty,
              let password = passwordTf.text , !password.isEmpty else {
            self.warningAlert(message: "please fill in all fields ..")
            return
        }
        
        FirebaseAuth.Auth.auth().signIn(withEmail: email, password: password, completion: { authResult , error in
            
            guard let result = authResult, error == nil else {
                    print("Failed to log in user with email \(email)")
                    self.warningAlert(message: "invalid Email or Password ..")
                    return
                }
            
            let user = result.user
            print("logged in user: \(user)")
            
            let onlineUser = User(id: user.uid, email: email)
            DatabaseManger.shared.onlineUsers(with: onlineUser, completion: { success in
                if success {
                    print ("\(onlineUser.email) online")
                }
            })
            UserDefaults.standard.set(onlineUser.id, forKey: "userID")
            UserDefaults.standard.set(onlineUser.email, forKey: "userEmail")
            self.navigationController?.dismiss(animated: true, completion: nil)
        })
        
    }
    
    @IBAction func signupButtonTapped(_ sender: Any) {
        
        guard let email = emailTF.text , !email.isEmpty,
              let password = passwordTf.text , !password.isEmpty , password.count >= 6 else {
              warningAlert(message: "please fill in all fields \n and make sure the password is at least 6 characters .. ")
            return
        }
        
        FirebaseAuth.Auth.auth().createUser(withEmail: email, password: password, completion: { authResult , error in
            
            guard let result = authResult, error == nil else {
                print("Error creating user")
                self.warningAlert(message: "this email is already sign up ..")
                return
            }
            let user = result.user
            print("Created User: \(user.uid)")
            
            let newUser = User(id: user.uid, email: email)
            DatabaseManger.shared.insertUser(with: newUser, completion: { success in
                if success {
                    print ("new user added \(newUser)")
                }else {
                    print("faild to add new user .. ")
                }
            })
            
            DatabaseManger.shared.onlineUsers(with: newUser, completion: { success in
                if success {
                    print ("\(newUser.email) online")
                }
                
            })
            UserDefaults.standard.set(newUser.id, forKey: "userID")
            UserDefaults.standard.set(newUser.email, forKey: "userEmail")
            self.navigationController?.dismiss(animated: true, completion: nil)
        })
        
    }
    
    func warningAlert(message:String){
        let alert = UIAlertController(title: "Warning", message: message, preferredStyle: .alert)
          
          alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler:nil))
          
          present(alert, animated: true, completion: nil)
    }
    
}

