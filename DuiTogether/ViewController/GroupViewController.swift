//
//  GroupViewController.swift
//  DuiTogether
//
//  Created by Joey on 11/23/18.
//  Copyright © 2018 Joey. All rights reserved.
//

import UIKit
import Firebase
import FirebaseUI

//typealias GCompletionHandler = ((_ group: LocalGroup?) -> Void)
typealias GCompletionHandler = ((_ group: LocalGroup?) -> Void)
class GroupViewController: UIViewController, FUIAuthDelegate, UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate{
    
    var sharedModel = GroupsModel.shared
    var sharedUserModel = UserDataModel.shared
    
    @IBOutlet weak var groupNameNavItem: UINavigationItem!
    
    @IBOutlet weak var groupInfoOutlet: UIView!
    @IBOutlet weak var taskComplex: UILabel!
    @IBOutlet weak var groupRuleOutlet: UIView!
    
    @IBOutlet weak var JoinButtonOutlet: UIButton!
    @IBOutlet weak var navBar: UINavigationItem!
    @IBOutlet weak var checkOffTable: UITableView!
    @IBOutlet weak var bigScrollView: UIScrollView!
    
    // rest outlets
    @IBOutlet weak var groupsizeOutlet: UILabel!
    @IBOutlet weak var progressOutlet: UILabel!
    @IBOutlet weak var checkOffOverviewOutlet: UILabel!
    @IBOutlet weak var ruleTextOutlet: UITextView!
    
    // ui passed in var
    var groupsizeText = ""
    var progressText = ""
    var checkoffText = ""
    var ruleText = ""
    var complexText = ""
    var group: LocalGroup? = nil
    
    // logic passed in var
    var hasTent:Bool = false
    var thisGid: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tabBarController?.tabBar.isHidden = true
        
        // UI pre setting
        JoinButtonOutlet.layer.cornerRadius = 6;
        JoinButtonOutlet.clipsToBounds = true;

        // UI dynamic data
        taskComplex.text = complexText;
        groupsizeOutlet.text = groupsizeText
        progressOutlet.text = progressText
        checkOffOverviewOutlet.text = checkoffText
        ruleTextOutlet.text = ruleText
        
        // Show setup
        if(hasTent) {
            JoinButtonOutlet.isHidden = true
            checkOffTable.isHidden = false
            bigScrollView.isScrollEnabled = true
        } else {
            JoinButtonOutlet.isHidden = false
            checkOffTable.isHidden = true
            bigScrollView.isScrollEnabled = false;
        }
        
        // Should have stay unchanged
        checkOffTable.isScrollEnabled = false;
        
        navBar.rightBarButtonItem = UIBarButtonItem(title: "CheckOff", style: .plain, target: self, action: #selector(CheckOff))
    }
    
    // helper function
    @objc func CheckOff() {
        print("check off")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        // setup view did load here
        checkOffTable.reloadData()
    }
    
    var completionHandler: GCompletionHandler?
    @IBAction func JoinGroupAction(_ sender: UIButton) {
        // TODO: auth permission
        var authPermission: Bool
        if Auth.auth().currentUser != nil {
            // User is signed in.
            authPermission = true
        } else {
            // No user is signed in.
            authPermission = false
        }
        
        // if user is signed in
        if authPermission {
            // Code sniplet in a method
            let alertController = UIAlertController(title: NSLocalizedString("Alert", comment: ""),
                                                    message: NSLocalizedString("Joining a group requires huge commitment, you can't bail in the middle, are you sure to join?", comment: ""),
                                                    preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: NSLocalizedString("Not yet", comment: ""), style: .cancel, handler: nil)
            // Using the handler parameter, send the code to be executed (handle the action)
            // We need to capture the action, hence the "action in"
            let okAction = UIAlertAction(title: NSLocalizedString("Yes I am", comment: ""), style: .default, handler: { action in
                
                print("Alert ok action")
                
                // hide button, show table
                let thisuid = self.sharedUserModel.user!.GetUid()
                self.JoinButtonOutlet.isHidden = true
                self.checkOffTable.isHidden = false
                self.bigScrollView.isScrollEnabled = true
                
                // data modifiers
                self.sharedModel.getGroupById(gid: self.thisGid).addUid(uid: thisuid) // 1
                self.sharedUserModel.user?.AddGroup(gid: self.thisGid) // 2
                let db = Firestore.firestore() // 3
                let washingtonRef = db.collection("users").document(thisuid)
                // Atomically add a new region to the "regions" array field.
                washingtonRef.updateData([
                    "groups": FieldValue.arrayUnion([self.thisGid])
                    ])
                // 4
                let laRef = db.collection("groups").document(self.thisGid)
                // Atomically add a new region to the "regions" array field.
                laRef.updateData([
                    "users": FieldValue.arrayUnion([thisuid])
                    ])

                // switch page (NOT WORKING)
                // print("before handler...")
                if let completionHandler = self.completionHandler {
                    print("NOT WORKING completiong handler...")
                    completionHandler(self.group)
                    print("NOT WORKING completiong handler...")
                    self.navigationController?.popViewController(animated: false)
                }
            } )
            alertController.addAction(cancelAction)
            alertController.addAction(okAction)
            self.present(alertController, animated: true, completion: nil)
        } else {
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
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    // MARK: - Table view data source
    
    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 10;
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // TODO: get the detailed check off page
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "chcekOffCell")!
        
        cell.backgroundColor = .orange
        cell.textLabel?.textColor = .black
        
        cell.tintColor = .black
        cell.textLabel?.tintColor = .white
        
//        let card = sharedModel.flashcard(atIndex: indexPath.row)
        
        // Modify cell
        cell.textLabel?.text = "check in record"
        
        return cell;
    }
    
    
    /*
     // Override to support conditional editing of the table view.
     override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the specified item to be editable.
     return true
     }
     */
    
    
    // Override to support editing the table view.
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // 1) Delete the data from model
//            sharedModel.removeFlashcard(atIndex: indexPath.row);
            
            // 2) Delete the cell (UI)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
    // scroll view setting
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let scrollViewHeight = bigScrollView.frame.size.height;
        let scrollContentSizeHeight = bigScrollView.contentSize.height;
        let scrollOffset = bigScrollView.contentOffset.y;
        
        if (scrollOffset == 0)
        {
            // then we are at the top
            print("scroll at top!")
        }
        else if (scrollOffset + scrollViewHeight == scrollContentSizeHeight)
        {
            // then we are at the end
            print("scrolling to bottom!")
            checkOffTable.isScrollEnabled = true;
        } else {
            checkOffTable.isScrollEnabled = false;
            print("just scrolling...")
            
        }
    }
}

