//
//  PlazaViewController.swift
//  DuiTogether
//
//  Created by Joey on 11/19/18.
//  Copyright © 2018 Joey. All rights reserved.
//

import UIKit
import Firebase

class PlazaViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    var sharedModel = GroupsModel.shared
    var sharedUserModel = UserDataModel.shared
    
    @IBOutlet weak var plazaCollection: UICollectionView!
    @IBOutlet weak var navItemShow: UINavigationItem!
    
    // refresher stuff
    lazy var refresher: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.tintColor = .white
        self.extendedLayoutIncludesOpaqueBars = true
        
        refreshControl.addTarget(self, action: #selector(requestRefresherData), for: .valueChanged)
        
        return refreshControl
    }()
    @objc func requestRefresherData() {
        print("requesting data...")
        // update plaza data
        sharedModel.fetchPlazaData { (data: String) in
            print(data)
            self.plazaCollection.reloadData()
        }
        
        self.refresher.beginRefreshing()
        let deadline = DispatchTime.now() + .milliseconds(500)
        DispatchQueue.main.asyncAfter(deadline: deadline) {
            // fix: large title bumping
//            let top = self.plazaCollection.adjustedContentInset.top
//            let y = self.refresher.frame.maxY + top
//            self.plazaCollection.setContentOffset(CGPoint(x: 0, y: y), animated:true)
//            // self.plazaCollection.setContentOffset(CGPoint(x: 0, y: 1), animated:true)
            
            self.refresher.endRefreshing()
        }
    }
    
    // CollectionView UI setting start
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view. - completion handler
//        self.tabBarController?.tabBar.isHidden = false
        sharedModel.fetchPlazaData { (data: String) in
            self.plazaCollection.reloadData()
        }
        
        // Layout setup
        let layout = plazaCollection.collectionViewLayout as! UICollectionViewFlowLayout;
        //plazaCollection.delegate = self
        var sectionInset: UIEdgeInsets
        if(view.frame.size.width > 420) {
            sectionInset = UIEdgeInsets(top: 20,left: 20,bottom: 20,right: 20);
        } else {
            sectionInset = UIEdgeInsets(top: 10,left: 10,bottom: 10,right: 10);
        }
        
        layout.sectionInset = sectionInset
        
        // navbar setup
//        setupNavBar()
        
        // refresh control setup
        plazaCollection.refreshControl = refresher
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = false
    }
    
    //  setting the size of each item, there is another approach
    func collectionView(_ collectionView: UICollectionView,
                                 layout collectionViewLayout: UICollectionViewLayout,
                                 sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if indexPath.section == 0 {
            return CGSize(width: (view.frame.size.width - 40), height: 90)
        } else {
            // customize for screen size
            if(view.frame.size.width>810) {
                return CGSize(width: (view.frame.size.width - 180)/5, height: (view.frame.size.width - 80)/6)
            } else if(view.frame.size.width > 420) {
                return CGSize(width: (view.frame.size.width - 80)/3, height: 140)
            } else {
                if(indexPath.item == 0) {
                    return CGSize(width: (view.frame.size.width - 20), height: 140)
                } else {
                    return CGSize(width: (view.frame.size.width - 30)/2, height: 140)
                }
            }
        }
    }
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 2
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        if(section==0) {
            return 1
        } else {
            return sharedModel.getPlazaSize()
        }
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if(indexPath.section == 0) {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "plazaLandCell", for: indexPath) as! LandingCollectionViewCell
            
            let textColor = UIColor(red: CGFloat(109 / 255.0), green: CGFloat(192 / 255.0), blue: CGFloat(255.0 / 255.0), alpha: 1.0)
            
            cell.landingLabel.text = NSLocalizedString("Welcome new members", comment: "")
            cell.landingLabel.textColor = textColor
            cell.descLabel.text = NSLocalizedString("Read rules & Create new groups HERE", comment: "")
            cell.descLabel.textColor = textColor
            
            cell.backgroundColor = UIColor(red: CGFloat(0 / 255.0), green: CGFloat(31 / 255.0), blue: CGFloat(63/255.0), alpha: 1.0)
            
            cell.layer.masksToBounds = true;
            cell.layer.cornerRadius = 6;
            
            return cell;
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "plazaCell", for: indexPath) as! PlazaDataCollectionViewCell
            
            // red, green, blue takes a noramilized value from 0-1
//            let randomColor = Int(arc4random_uniform(UInt32(colorDB.count)))
            
            // Cell style customization
            //color dataBase
//            let colorDB = [
//                (0, 31, 63, 109,192,255),
//                (0, 116, 217, 186,218,252),
//                (127,219,255, 27,72,100),
//                (57,204,204, 0, 0, 0),
//                (61,153,112, 30,54,41),
//                (46,204,64, 14,62,19),
//                (1,255,112,0,102,43),
//                (255,133,27,102,47,0),
//                (255,65,54,128,5,0),
//                (255,220,0,102,88,0),
//                (133,20,75,234,122,177),
//                (240,18,190,101,6,79),
//                (177,13,201,238,169,249),
//                (221,221,221,0,0,0),
//                (17,17,17,221,221,221),
//                (170,170,170,0,0,0)
//            ]
//            let randomColor = indexPath.item % 16
//            let randomRed = Float(colorDB[randomColor].0)
//            let randomGreen = Float(colorDB[randomColor].1)
//            let randomBlue = Float(colorDB[randomColor].2)
            
            cell.layer.masksToBounds = true;
            cell.layer.cornerRadius = 8;
            
            // Cell content customization
            do {
                let tempGroup = try sharedModel.getPlazaGroup(atIndex: indexPath.item)
                cell.CellTaskLabel.text = "\(tempGroup!.getTask()) \(NSLocalizedString("with", comment: "")) \(tempGroup!.getName())"
                cell.CellFrequencyLabel.text = "\(tempGroup!.getAmount())  \(tempGroup!.getUnit())/\(NSLocalizedString("Day", comment:""))"
                cell.CellPopulationLabel.text = "\(tempGroup!.getSize()) \(NSLocalizedString("People in", comment: ""))"
                
                let colorCode: [Double] = tempGroup!.getColor()
                
                let textColor = UIColor(red: CGFloat(colorCode[3] / 255.0), green: CGFloat(colorCode[4] / 255.0), blue: CGFloat(colorCode[5]/255.0), alpha: 1.0)
                
                cell.backgroundColor = UIColor(red: CGFloat(colorCode[0] / 255.0), green: CGFloat(colorCode[1] / 255.0), blue: CGFloat(colorCode[2]/255.0), alpha: 1.0)
                cell.CellTaskLabel.textColor = textColor
                cell.CellFrequencyLabel.textColor = textColor
                cell.CellPopulationLabel.textColor = textColor
            } catch VendingMachineError.outOfBounds {
                print("trying to get out of bounds group on plaza page 2")
            } catch {
                
            }
            
            return cell
        }
        
    }
//  for disabling a header
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
//
//    }
    
    // header footer setting
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "plazaPopularHeader", for: indexPath) as! PlazaPopularCollectionReusableView
        
        if( indexPath.section == 0) {
            header.headerLabel.text = NSLocalizedString("Guide", comment: "")
        } else {
            header.headerLabel.text = NSLocalizedString("Popular", comment: "")
        }
        
        return header
    }
    
    // --------- Segue setting start -----------
    // Show group detail when didSelectItemAt
    var tempCH: GCompletionHandler?
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if(indexPath.section == 1) {
            let vc : GroupViewController! = storyboard?.instantiateViewController(withIdentifier: "GroupDetailSBI") as? GroupViewController
            
            // TODO: set group object here for data pass in
            do {
                let tempGroup = try sharedModel.getPlazaGroup(atIndex: indexPath.item)
                
                vc.groupNameNavItem.title = "\(tempGroup!.getName())"
                vc.complexText = "\(tempGroup!.getTask()) \(tempGroup!.getAmount()) \(tempGroup!.getUnit())/Day"
                vc.groupsizeText = "\(tempGroup!.getSize()) / \(tempGroup!.getCap()) \(NSLocalizedString("People", comment: ""))>"
                vc.progressText = "\(tempGroup!.getProgressInt()) / \(tempGroup!.getLength())"
                vc.checkoffText = NSLocalizedString("no info yet", comment: "")
                vc.ruleText = "\(tempGroup!.getRuleText())"
                vc.thisGid = tempGroup!.getgid()
                if(sharedUserModel.hasGroupByID(gid: tempGroup!.getgid())) {
                    vc.hasTent = true
                }
                
                // let colorCode: [Double] = tempGroup!.getColor() // for theme customization for each group page in the future
                
            } catch VendingMachineError.outOfBounds {
                print("trying to get out of bounds group on plaza page 1")
            } catch {
                
            }
            
            //        present(vc, animated: true, completion: nil);
            self.navigationController?.pushViewController(vc, animated: true)
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

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "CreateGroupSI", let createGroupVC = segue.destination as? CreateGroupViewController{
            
            createGroupVC.completionHandler = { question, answer  in
                
                print("dismissing CreateGroupSI segue")
                // What does this do
                self.dismiss(animated: true, completion: nil)
            }
        } else if segue.identifier == "ShowPlazaGroupSI", let joinGroupVC = segue.destination as? GroupViewController {
            
            print("trying to switch page cleanly")
            
            joinGroupVC.completionHandler = { group in
                // I can update join data base here too...
                // trying to switch page
//                let vc : GroupPageViewController! = self.storyboard?.instantiateViewController(withIdentifier: "GroupShowDetailSBI") as? GroupPageViewController
//                vc.group = group
//                self.navigationController?.pushViewController(vc, animated: false)
                
                print("dismissing GroupViewPage segue")
                // What does this do
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    // helper functions
    // nav bar large titles helper function
    func setupNavBar() {
        navigationController?.navigationBar.prefersLargeTitles = true;
    }
}
