//
//  SearchPanelViewController.swift
//  DuiTogether
//
//  Created by Joey on 1/9/19.
//  Copyright © 2019 Joey. All rights reserved.
//

import UIKit
import FirebaseFirestore

class SearchPanelViewController: UIViewController, UITableViewDataSource, UITableViewDelegate,UISearchBarDelegate {
    
    // UI View objects
    @IBOutlet weak var mainSearchBar: UISearchBar! // abandoned
    @IBOutlet weak var searchResultTable: UITableView!
    @IBOutlet var tabRecognizer: UITapGestureRecognizer!
    
    // Search helper datastructures
    var searchNameResults = [String]();
    var searchGidResults = [String]();
    var searchTaskResults = [String]();
    var searchResults = [String:String](); // name:gid
    
    let sharedGroups = GroupsModel.shared
    var sharedUserModel = UserDataModel.shared
    
    let mySearchController = UISearchController(searchResultsController: nil)
    var lastSearchTerm  = ""
    
    // segue helper var
    var selectedRow:Int = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        UserDefaults.standard.set(true, forKey: "TriedSearch");
        if(UserDefaults.standard.bool(forKey: "TriedSearch")) {
            if let badgVal = tabBarController?.tabBar.items?[2].badgeValue {
                tabBarController?.tabBar.items?[2].badgeValue = nil;
                print("UserDefault: set badge value from \(badgVal) to nil")
            }
        }
        
        searchResultTable.isHidden = true;
        
        //disabled for now
        tabRecognizer.isEnabled = false;
        
        // Search, Setup the Search Controller
        mySearchController.searchResultsUpdater = self
        mySearchController.obscuresBackgroundDuringPresentation = false
        mySearchController.searchBar.placeholder = "search task names for groups"
        navigationItem.searchController = mySearchController
        definesPresentationContext = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
    }
    
//    @IBAction func tappedOnce(_ sender: UITapGestureRecognizer) {
//        self.view.endEditing(true)
//        searchResultTable.isHidden = true;
//    }
//    NOT WORKING
//    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
//        print("searchBar did end editing")
//        searchResultTable.isHidden = true;
//    }
//    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
//        searchResultTable.isHidden = true;
//    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStordbyboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    // Table view control
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFiltering() {
            return searchNameResults.count
        }
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        if isFiltering() {
            cell.textLabel?.text = "\(searchTaskResults[indexPath.row]) @\(searchNameResults[indexPath.row])"
        } else {
            cell.textLabel?.text = ""
        }
        cell.textLabel?.textColor = .white
        cell.selectionStyle = .none
        return cell;
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedRow = indexPath.row;
        performSegue(withIdentifier: "search2TentsSI", sender: nil)
    }
    
    func searchBarIsEmpty() -> Bool {
        // Returns true if the text is empty or nil
        return mySearchController.searchBar.text?.isEmpty ?? true
    }
    // is updating the tableview
    func isFiltering() -> Bool {
        // tabRecognizer.isEnabled = false;
        return mySearchController.isActive && !searchBarIsEmpty()
    }
    
    func filterContentForSearchText(_ searchText: String, scope: String = "All") {
        
        searchResults = [String:String](); // name:gid NOTUSING
        
        print("search text is \(searchText)")
        
        let db = Firestore.firestore()
        let citiesRef = db.collection("groups");
        citiesRef.whereField("task", isGreaterThanOrEqualTo: searchText.lowercased()) // upcase is samller
            .order(by: "task", descending: false)
            //.limit(to: 6) // only want the first document from the search list
            .getDocuments { (QuerySnapshot, err) in
                // get the first one in the snap shot
                if let err = err {
                    print("Error getting documents for search: \(err)")
                } else {
                    var limit = 0;
                    
                    // reset result, puting here so less gap between
                    self.searchNameResults = []
                    self.searchGidResults = []
                    self.searchTaskResults = []
                    
                    for document in QuerySnapshot!.documents {
                        //print("TESTING... limit \(limit)")
                        limit += 1
                        if(limit>10) {
                            break;
                        }
                        
                        let thisGid = document.documentID
                        
                        let data: NSDictionary = document.data() as NSDictionary
                        let thisTaskName = data.value(forKey: "task") as! String
                        let thisName = data.value(forKey: "name") as! String
                        // add to filtered data
                                    //self.searchResults[thisName] = thisGid; // WASTED
                        self.searchNameResults.append(thisName);
                        self.searchTaskResults.append(thisTaskName);
                        self.searchGidResults.append(thisGid);
                        
                        let thissize : Int = (data["users"] as! [String]).count
                        
                        let newGroup = LocalGroup(
                            gid: thisGid,
                            mTask: data.value(forKey: "task") as! String,
                            mAmount: data.value(forKey: "amount") as! Int,
                            mUnit: data.value(forKey: "unit") as! String,
                            mCapacity: data.value(forKey: "capacity") as! Int,
                            mLength: data.value(forKey: "length") as! Int,
                            mRule: data.value(forKey: "rule") as! String,
                            mSize: thissize,
                            mColorCode: data.value(forKey: "colorCode") as! [Int],
                            mProgress: data.value(forKey: "progress") as! Int,
                            mName: data.value(forKey: "name") as! String,
                            creationDate: data.value(forKey: "creationDate") as! Date,
                            mVisibility: data.value(forKey: "visibility") as! String
                        )
                        
                        self.sharedGroups.addGroupToAll(gid: thisGid, group: newGroup);
                    }
//                      TESTING PURPOSES
//                    if(self.searchNameResults.count>0) {
//                        print("size is \(self.searchNameResults.count)")
//                        for i in 0...self.searchNameResults.count-1 {
//                            print("index is \(i)")
//                            print(self.searchNameResults[0]);
//                            print(i);
//                        }
//                    }
                    
                    self.searchResultTable.reloadData() // after loading all searched data
                }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if segue.identifier == "showDetail" {
//            if let indexPath = tableView.indexPathForSelectedRow {
//                let candy = candies[indexPath.row]
//                let controller = (segue.destination as! UINavigationController).topViewController as! DetailViewController
//                controller.detailCandy = candy
//                controller.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
//                controller.navigationItem.leftItemsSupplementBackButton = true
//            }
//        }

        if segue.identifier == "search2TentsSI"
            , let vc = segue.destination as? GroupViewController
        {
            // TODO: set group object here for data pass in
            do {
                let tempGroup = try sharedGroups.getPlazaGroup(atIndex: selectedRow)
                
                vc.groupNameNavItem.title = "\(tempGroup!.getName())"
                vc.complexText = "\(tempGroup!.getTask()) \(tempGroup!.getAmount()) \(tempGroup!.getUnit())/Day"
                vc.groupsizeText = "\(tempGroup!.getSize()) / \(tempGroup!.getCap()) \(NSLocalizedString("People", comment: ""))>"
                vc.progressText = "\(tempGroup!.getProgressInt()) / \(tempGroup!.getLength())"
                vc.checkoffText = NSLocalizedString("no info yet", comment: "")
                vc.ruleText = "\(tempGroup!.getRuleText())"
                vc.thisGid = tempGroup!.getgid()
                if(self.sharedUserModel.hasGroupByID(gid: tempGroup!.getgid())) {
                    vc.hasTent = true
                }
                
                // let colorCode: [Double] = tempGroup!.getColor() // for theme customization for each group page in the future
                
            } catch VendingMachineError.outOfBounds {
                print("trying to get out of bounds group on plaza page 1")
            } catch {
                
            }
            
//            vc.groupNameNavItem.title = searchNameResults[selectedRow]
//            vc.complexText = "\(searchTaskResults[selectedRow]) @\(searchNameResults[selectedRow])"
//
//            vc.groupsizeText = "0 \(NSLocalizedString("People", comment: ""))"
//            vc.progressText = "1/2"
//            vc.checkoffText = NSLocalizedString("no info yet", comment: "")
//            vc.ruleText = "what rule"
//            vc.hasTent = false // need check
//            vc.thisGid = searchGidResults[selectedRow]
            
            // when back (dont know how to trigger this... back2SearchCompletionHandler();
//            vc.back2SearchCompletionHandler = {() in
//                self.tabBarController?.tabBar.isHidden = false
//                // dismiss that stuff idk
//                self.dismiss(animated: true, completion: nil)
//            }
        }
    }

}

extension SearchPanelViewController: UISearchResultsUpdating {
    // MARK: - UISearchResultsUpdating Delegate
    
    func updateSearchResults(for searchController: UISearchController) {
        // TODO called when activate, change, comeback from top vc
        print("Testing... updateSearchResults called \(searchController.searchBar.text!)")
        
        // if not active or empty
        if(!isFiltering()) {
            searchResultTable.isHidden = true;
        } else {
            searchResultTable.isHidden = false;
            
            // to save data usage & fix update gap from poping top vc
            if(lastSearchTerm != searchController.searchBar.text!) {
                print("triggered function with search term \(lastSearchTerm)")
                lastSearchTerm = searchController.searchBar.text!;
                filterContentForSearchText(searchController.searchBar.text!);
            }
        }
        
    }
}
