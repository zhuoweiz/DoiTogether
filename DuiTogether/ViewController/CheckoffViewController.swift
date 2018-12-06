//
//  CheckoffViewController.swift
//  DuiTogether
//
//  Created by Joey on 12/4/18.
//  Copyright © 2018 Joey. All rights reserved.
//

import UIKit

class CheckoffViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate {
    
    let sharedModel = GroupsModel.shared
    let sharedUserModel = UserDataModel.shared
    
    var navTitletitle = ""
    var detailComment = "..."
    var checkoffProofImageUrl : String = ""
    
    var thisGid = ""
    var thisUid = ""
    var thisCid = ""

    @IBOutlet weak var checkoffTableview: UITableView!
    @IBOutlet weak var navItem: UINavigationItem!
    @IBOutlet weak var proofimageview: UIImageView!
    @IBOutlet weak var detailcommentoutlet: UILabel!
    @IBOutlet weak var checkoffButton: UIButton!
    @IBOutlet weak var checkofftableTitle: UILabel!
    
    @IBOutlet weak var otherCheckoffTable: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // UI set up
        navItem.title = navTitletitle
        detailcommentoutlet.text = detailComment
        if let url = URL(string: checkoffProofImageUrl) {
            print("url for image works... \(url.absoluteString)")
            download(url: url, image: proofimageview)
        }
        
        checkoffButton.layer.masksToBounds = true
        checkoffButton.layer.cornerRadius = 6.0

        // Do any additional setup after loading the view.
        navigationController?.navigationBar.prefersLargeTitles = false;
        
        // if its the user's check off, no verify button
        let group = sharedModel.getGroupById(gid: thisGid)
        let verifiedList: [String] = group.getCheckoffVerifiedList(cid: thisCid)
        
        if(verifiedList.contains(thisUid)) {
            checkoffButton.isHidden = true;
        } else {
            if(group.getcheckoffOwnerId(bycid: thisCid) == thisUid) {
                checkoffButton.isHidden = true;
            } else {
                print("TEMPTESTING \(group.getcheckoffOwnerId(bycid: thisCid))")
                checkoffButton.isHidden = false;
            }
        }
        
        checkofftableTitle.text = "\(NSLocalizedString("Verification record", comment: "")) \(verifiedList.count)/\(group.getSize()-1)"
        
        // UI autolayout NOT WORKING
//        if(view.frame.size.width>420) {
//            proofimageview.frame.size = CGSize(width: proofimageview.frame.width, height:900)
//        } else if(view.frame.size.width>375) {
//            proofimageview.frame.size = CGSize(width: proofimageview.frame.width, height:400)
//        } else if(view.frame.size.width>320) {
//            proofimageview.frame.size = CGSize(width: proofimageview.frame.width, height:260)
//        }
    }
    override func viewDidDisappear(_ animated: Bool) {
        navigationController?.navigationBar.prefersLargeTitles = true;
    }
    
    @IBAction func checkoffAction(_ sender: UIButton) {
        let group = sharedModel.getGroupById(gid: thisGid)
        
        group.verifyCheckoff(uid: thisUid, cid: thisCid) {(data: String) in
            self.checkoffTableview.reloadData()
            self.checkoffButton.isHidden = true;
        }
    }
    
    // table view setting
    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        let group = sharedModel.getGroupById(gid: thisGid)
        // let verifiedList: [String] = group.getCheckoffVerifiedList(cid: thisCid)
        return group.getSize()-1;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "checkoffCell")!
        
        let group = sharedModel.getGroupById(gid: thisGid)
        let verifiedList: [String] = group.getCheckoffVerifiedList(cid: thisCid)
        // load verified first
        if(indexPath.item<verifiedList.count) {
            cell.backgroundColor = UIColor(red: 0/255, green: 242/255, blue: 255/255, alpha: 1.0)
            cell.textLabel?.text = "verified"
        } else {
            cell.backgroundColor = UIColor(red: 255/255, green: 99/255, blue: 79/255, alpha: 1.0)
            cell.textLabel?.text = "need verification"
        }
        
        cell.textLabel?.textColor = .black
        
        return cell;
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
