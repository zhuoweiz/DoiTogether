//
//  CreateGroupViewController.swift
//  DuiTogether
//
//  Created by Joey on 11/23/18.
//  Copyright © 2018 Joey. All rights reserved.
//

import UIKit
import Firebase
import FirebaseUI

typealias AddCompletionHandler = ((_ task: String?, _ taskFooter: String?) -> Void)

class CreateGroupViewController: UIViewController, UITextFieldDelegate, FUIAuthDelegate {
    
    var sharedModel = GroupsModel.shared
    var sharedUserModel = UserDataModel.shared

    // useless outlets
    @IBOutlet weak var form1: UIView!
    @IBOutlet weak var form2: UIView!
    @IBOutlet weak var submitOutlet: UIButton!
    
    @IBOutlet weak var taskInput: UITextField!
    @IBOutlet weak var amountInput: UITextField!
    @IBOutlet weak var unitInput: UITextField!
    @IBOutlet weak var lengthInput: UITextField!
    @IBOutlet weak var capacityInput: UITextField!
    @IBOutlet weak var nameInput: UITextField!
    @IBOutlet weak var ruleInput: UITextView!

    @IBOutlet weak var loginRestrictionButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tabBarController?.tabBar.isHidden = true
        
        // Do any additional setup after loading the view.
//        print("did load...")
//        self.tabBarController?.tabBar.isHidden = true
        
        // Button enable for form validation
        // submitOutlet.isEnabled = false;
        
        submitOutlet.layer.cornerRadius = 5;
        submitOutlet.clipsToBounds = true;
        
        // keyboard tool bar setup
        let toolBar = UIToolbar()
//        toolBar.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 44.0)
        toolBar.autoresizingMask = .flexibleHeight
        
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.done, target: self, action: #selector(doneClicked))
//        let cancelButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.cancel, target: self, action: #selector(cancelClicked))
        toolBar.setItems([flexibleSpace, doneButton], animated: false)
        amountInput.inputAccessoryView = toolBar;
        lengthInput.inputAccessoryView = toolBar;
        capacityInput.inputAccessoryView = toolBar;
        ruleInput.inputAccessoryView = toolBar;
        
        // auth requirement
        if let _ = Auth.auth().currentUser {
            // User is signed in.
            loginRestrictionButton.isHidden = true
            form1.isHidden = false
            form2.isHidden = false
            submitOutlet.isHidden = false
            
        } else {
            // No user is signed in.
            loginRestrictionButton.isHidden = false
            form1.isHidden = true
            form2.isHidden = true
            submitOutlet.isHidden = true
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
    }
    
    var completionHandler: AddCompletionHandler?
    @IBAction func submitAction(_ sender: UIButton) {
        
        print("creation group completion handler")
        print("\(String(describing: self.completionHandler))")
        
        if(taskInput.text == "" || amountInput.text == "" || unitInput.text == "" ||
            lengthInput.text == "" ||
            capacityInput.text == "" ||
            nameInput.text == "") {
            // validation fail, push alert
            let alertController = UIAlertController(title: NSLocalizedString("Alert", comment: ""),
                                                    message: NSLocalizedString("You have to finish all required input to continue", comment: ""),
                                                    preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: NSLocalizedString("Got it", comment: ""), style: .cancel, handler: nil)
            // Using the handler parameter, send the code to be executed (handle the action)
            
            alertController.addAction(cancelAction)
            self.present(alertController, animated: true, completion: nil)
        } else {
            if let task = taskInput.text?.lowercased(), let amount = amountInput.text, let unit = unitInput.text, let length = lengthInput.text, let capacity = capacityInput.text, let rule = ruleInput.text, let name = nameInput.text, let completionHandler = self.completionHandler {
                
                completionHandler(task, "\(amount) \(unit)/Day")
                
                // clear text fields
                taskInput.text = nil
                amountInput.text = nil
                unitInput.text = nil
                lengthInput.text = nil
                capacityInput.text = nil
                nameInput.text = nil
                ruleInput.text = ""
                
                //color dataBase
                let colorDB = [
                    (0, 31, 63, 109,192,255),
                    (0, 116, 217, 186,218,252),
                    (127,219,255, 27,72,100),
                    (57,204,204, 0, 0, 0),
                    (61,153,112, 30,54,41),
                    (1,255,112,0,102,43),
                    (255,133,27,102,47,0),
                    (255,65,54,128,5,0),
                    (255,220,0,102,88,0),
                    (133,20,75,234,122,177),
                    (221,221,221,0,0,0),
                    (17,17,17,221,221,221),
                    (255,153,102, 0,0,0), // orange black
                    (0, 250, 250,0,0,0), //light blue black
                    (237, 94, 94, 255,255,255), // red white
                    (170,170,170,0,0,0)
                ]
                let randomColor = Int(arc4random_uniform(15))
                let colorCode = [colorDB[randomColor].0,
                                 colorDB[randomColor].1,
                                 colorDB[randomColor].2,
                                 colorDB[randomColor].3,
                                 colorDB[randomColor].4,
                                 colorDB[randomColor].5]
                let creationDate = Date()
                
                // Database deal & sharedModel deal
                let db = Firestore.firestore()
                var ref: DocumentReference? = nil
                ref = db.collection("groups").addDocument(data: [
                    "name": name,
                    "task": task,
                    "amount": Int(amount) ?? 0,
                    "unit": unit,
                    "length": Int(length) ?? 0,
                    "capacity": Int(capacity) ?? 0,
                    "size" : 1,
                    "rule": rule,
                    "users": [sharedUserModel.user?.GetUid()], // add uid to the group
                    "creationDate": creationDate,
                    "progress":0,
                    "colorCode": colorCode,
                    "tags": [],
                    "visibility": ""
                    
                ]) { err in
                    if let err = err {
                        print("Error adding document: \(err)")
                    } else {
                        print("Document added with ID: \(ref!.documentID)")
                        
                        // update things after new group creation... add id to owner, change SM with new group & new id in group
                        
                        self.sharedModel.createGroup(gid: ref!.documentID, mTask: task, mAmount: Int(amount) ?? 0, mUnit: unit, mCapacity: Int(capacity)!, mLength: Int(length)!, mRule: rule, mSize: 1, mColorCode: colorCode, mProgress: 0, mName: name, creationDate: creationDate, uid: (Auth.auth().currentUser?.uid)!, mVisibility: "")
                        
                        // after creating a new group, add the group id to user
                        if let user = Auth.auth().currentUser {
                            // User is signed in.
                            let washingtonRef = db.collection("users").document("\(user.uid)")
                            
                            // Atomically add a new group to the "groups" array field.
                            washingtonRef.updateData([
                                "groups": FieldValue.arrayUnion(["\(ref!.documentID)"])
                                ])
                        } else {
                            // No user is signed in.
                            print("ERROE! not logged in but trying to add group")
                        }
                        // add gid to user and others, done in create function
                    }
                }
                
                // test stack pop
                print("get the plaza page back")
                self.tabBarController?.tabBar.isHidden = false
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    @IBAction func redirectLoginAction(_ sender: UIButton) {
        // not not logged in, go to page blabla
        let authUI = FUIAuth.defaultAuthUI()
        authUI?.delegate = self
        
        let providers: [FUIAuthProvider] = [
            FUIGoogleAuth(),
            ]
        
        authUI?.providers = providers
        
        let authViewController = authUI!.authViewController()
        present(authViewController, animated: true, completion: nil);
    }
    
    // auth error and data handler
    func authUI(_ authUI: FUIAuth, didSignInWith user: User?, error: Error?) {
        // handle user and error as necessary
        // handle user and error as necessary
        guard error == nil else {
            return
        }
        //method 2 with same effect
        if error != nil {
            //log error
            return
        }
        
        // check if user exists
        let db = Firestore.firestore()
        //        var ref: DocumentReference? = nil
        let docRef = db.collection("users").document("\(user!.uid)")
        docRef.getDocument { (document, error) in
            if let document = document, document.exists {
                let dataDescription = document.data().map(String.init(describing:)) ?? "nil"
                print("user data: \(dataDescription)")
            } else {
                print("user does not exist")
                
                // create/add a new user and add to the db
                db.collection("users").document("\(user!.uid)").setData([
                    "email": "\(user?.email ?? "")",
                    "avatarUrl": "\(user?.photoURL?.absoluteString ?? "")",
                    "creationDate" : NSDate(),
                    "groups": [
                        
                    ],
                    
                    ]) { err in
                        if let err = err {
                            print("Error adding document: \(err)")
                        } else {
                            print("Document added")
                        }
                }
            }
        }
        
        // after login create UserDataModel
        UserDataModel.shared.login(email: user!.email!, uid: user!.uid, url: user?.photoURL?.absoluteString ?? "")
        
        viewDidLoad()
    }
    
    // ---- keyboards customization starts -----
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == taskInput {
            textField.resignFirstResponder()
            amountInput.becomeFirstResponder()
        } else if textField == amountInput {
            textField.resignFirstResponder()
            unitInput.becomeFirstResponder()
        } else if textField == unitInput {
            textField.resignFirstResponder()
            lengthInput.becomeFirstResponder()
        } else if textField == lengthInput {
            textField.resignFirstResponder()
            capacityInput.becomeFirstResponder()
        } else if textField == capacityInput {
            textField.resignFirstResponder()
            nameInput.becomeFirstResponder()
        } else if textField == nameInput {
            textField.resignFirstResponder()
        } else {
            textField.resignFirstResponder()
        }
        return true;
    }
    
    @IBAction func singleTapAction(_ sender: UITapGestureRecognizer) {
//        print("tapped once for keybaord dismiss...")
        self.view.endEditing(true)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    // Helper functions
    @objc func doneClicked() {
        view.endEditing(true)
    }
    @objc func cancelClicked(tf: UITextField) {
        tf.text = nil
        view.endEditing(true)
    }

}
