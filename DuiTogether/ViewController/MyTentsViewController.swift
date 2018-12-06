//
//  MyTentsViewController.swift
//  DuiTogether
//
//  Created by Joey on 11/25/18.
//  Copyright © 2018 Joey. All rights reserved.
//

import UIKit
import Firebase
import FirebaseUI

class MyTentsViewController: UIViewController, FUIAuthDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    var sharedModel = GroupsModel.shared
    var sharedUserModel = UserDataModel.shared
    
    @IBOutlet weak var signinOutlet: UIButton!
    @IBOutlet weak var collectionViewOutlet: UICollectionView!
    
    // refresher stuff
    lazy var refresher: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.tintColor = .white
        
        refreshControl.addTarget(self, action: #selector(requestRefresherData), for: .valueChanged)
        
        return refreshControl
    }()
    @objc func requestRefresherData() {
        print("requesting data on myTents...")
        // temptest
        print("temptest... number of groups in user: \(sharedUserModel.getTentsCount())")
        print("temptest... number of groups in allGroups: \(sharedModel.getAllGroupCount())")
        sharedModel.printAllGroups()
        
        // if User is signed in.
        let user = Auth.auth().currentUser
        if let user = user {
            // The user's ID, unique to the Firebase project.
            // Do NOT use this value to authenticate with your backend server,
            // if you have one. Use getTokenWithCompletion:completion: instead.
            let uid = user.uid
            
            sharedUserModel.fetchUserTentData(uid: uid) { (data) in
                self.collectionViewOutlet.reloadData()
            }
        }
        
        self.refresher.beginRefreshing()
        let deadline = DispatchTime.now() + .milliseconds(700)
        DispatchQueue.main.asyncAfter(deadline: deadline) {
            self.refresher.endRefreshing()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        // if logged in, fetch data
        let user = Auth.auth().currentUser
        if let user = user {
            // The user's ID, unique to the Firebase project.
            // Do NOT use this value to authenticate with your backend server,
            // if you have one. Use getTokenWithCompletion:completion: instead.
            let uid = user.uid
            
            sharedUserModel.fetchUserTentData(uid: uid) { (data) in
                self.collectionViewOutlet.reloadData()
            }
        } else {
            
        }
        
        // Layout setup
        let layout = collectionViewOutlet.collectionViewLayout as! UICollectionViewFlowLayout;
        collectionViewOutlet.delegate = self
        var sectionInset: UIEdgeInsets
        sectionInset = UIEdgeInsets(top: 10, left: 20, bottom: 10, right: 20)
        layout.sectionInset = sectionInset
        
        // UI improvement
        signinOutlet.layer.masksToBounds = true
        signinOutlet.layer.cornerRadius = 6.0
        
        // refresh control setup
        collectionViewOutlet.refreshControl = refresher
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = false
        
        if Auth.auth().currentUser != nil {
            // User is signed in.
            signinOutlet.isHidden = true
            collectionViewOutlet.isHidden = false
        } else {
            // No user is signed in.
            signinOutlet.isHidden = false
            collectionViewOutlet.isHidden = true
        }
        setupNavBar() // fix: 在某tent页面浏览后返回可能触发large title disapper
    }
    
    //
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let height:CGFloat = 160;
        let width:CGFloat = view.frame.size.width * 4/5
        
        return CGSize(width: width, height: height)
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return sharedUserModel.getTentsCount()
    }
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "tentCell", for: indexPath) as! TentDataCollectionViewCell
        
        // UI: round corner
        cell.layer.masksToBounds = true;
        cell.layer.cornerRadius = 8;
        
        // Cell content customize
        if let tempGroup = sharedUserModel.getGroupAt(index: indexPath.item) {
            cell.complexOutlet.text = tempGroup.getName()
//            "\(tempGroup.getTask()) with \(tempGroup.getName())"
            cell.amountOutlet.text = "\(tempGroup.getAmount())  \(tempGroup.getUnit())/Day"
            cell.sizeOutlet.text = "\(tempGroup.getSize()) people in"
            cell.progressOutlet.progress = tempGroup.getProgress()
            cell.statusOutlet.text = "not defined yet"
            
            let colorCode: [Double] = tempGroup.getColor()
            
            let textColor = UIColor(red: CGFloat(colorCode[3] / 255.0), green: CGFloat(colorCode[4] / 255.0), blue: CGFloat(colorCode[5]/255.0), alpha: 1.0)
            
            cell.backgroundColor = UIColor(red: CGFloat(colorCode[0] / 255.0), green: CGFloat(colorCode[1] / 255.0), blue: CGFloat(colorCode[2]/255.0), alpha: 1.0)
            cell.complexOutlet.textColor = textColor
            cell.amountOutlet.textColor = textColor
            cell.sizeOutlet.textColor = textColor
            cell.progressLabel.textColor = textColor
            cell.statusOutlet.textColor = textColor
            
            cell.progressOutlet.progressTintColor = textColor
            cell.progressOutlet.tintColor = textColor
        }
        print("return tentcell... \(indexPath.item)")
        
        return cell
    }
    
    // tab new page
    // --------- Segue setting start -----------
    // Show group detail when didSelectItemAt
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let vc : GroupViewController! = storyboard?.instantiateViewController(withIdentifier: "GroupDetailSBI") as? GroupViewController
        
        // TODO: set group object here for data pass in
//        do {
        if let tempGroup = sharedUserModel.getGroupAt(index: indexPath.item) {
            vc.groupNameNavItem.title = tempGroup.getName()
            vc.complexText = "\(tempGroup.getTask()) \(tempGroup.getAmount()) \(tempGroup.getUnit())/\(NSLocalizedString("Day", comment: ""))"
            vc.groupsizeText = "\(tempGroup.getSize()) / \(tempGroup.getCap()) \(NSLocalizedString("People", comment: ""))"
            vc.progressText = "\(tempGroup.getProgressInt()) / \(tempGroup.getLength())"
            vc.checkoffText = NSLocalizedString("no info yet", comment: "")
            vc.ruleText = "\(tempGroup.getRuleText())"
            vc.hasTent = true
            vc.thisGid = tempGroup.getgid()
            vc.group = tempGroup
        } else {
            print("Error: out of range in tent vc")
        }
        
        //        present(vc, animated: true, completion: nil);
        self.navigationController?.pushViewController(vc, animated: true)
    }
    

    
    @IBAction func signinAction(_ sender: UIButton) {
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
        guard error == nil else {
            return
        }
        //method 2 with same effect
        if error != nil {
            //log error
            return
        }
        
        // after login create UserDataModel
        UserDataModel.shared.login(email: user!.email!, uid: user!.uid, url: user?.photoURL?.absoluteString ?? "")
        
        viewDidLoad()
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    // nav bar large titles helper function
    func setupNavBar() {
        navigationController?.navigationBar.prefersLargeTitles = true;
    }
}
