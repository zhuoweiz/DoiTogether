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
    
    @IBOutlet weak var groupNameNavItem: UINavigationItem!
    
    @IBOutlet weak var groupInfoOutlet: UIView!
    @IBOutlet weak var taskComplex: UILabel!
    
    @IBOutlet weak var groupRuleOutlet: UIView!
    @IBOutlet weak var JoinButtonOutlet: UIButton!
    
    @IBOutlet weak var navBar: UINavigationItem!
    
    @IBOutlet weak var checkOffTable: UITableView!
    @IBOutlet weak var bigScrollView: UIScrollView!
    
    var complexText = ""
    var group: LocalGroup? = nil;
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // UI setting
        JoinButtonOutlet.layer.cornerRadius = 6;
        JoinButtonOutlet.clipsToBounds = true;

        // Do any additional setup after loading the view. TODO: change after data setting up
        taskComplex.text = complexText;
        groupNameNavItem.title =  complexText;
        
        // Show setup, TODO: change after data setting up
        checkOffTable.isHidden = true
        bigScrollView.isScrollEnabled = false;
        
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
        print("reloading fav page")
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
        
        if authPermission {
            // signed in
            // hide button, show table
            JoinButtonOutlet.isHidden = true
            checkOffTable.isHidden = false
            bigScrollView.isScrollEnabled = true
            
            print("before handler...")
            
            // switch page (NOT WORKING)
            if let completionHandler = self.completionHandler {
                print("completiong handler...")
                completionHandler(group)
                print("completiong handler...")
                self.navigationController?.popViewController(animated: false)
            }
            
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
    var sharedModel = GroupsModel.shared
    
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

