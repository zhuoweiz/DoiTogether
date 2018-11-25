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

class MyTentsViewController: UIViewController, FUIAuthDelegate{
    
    
    @IBOutlet weak var signinOutlet: UIButton!
    @IBOutlet weak var collectionViewOutlet: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if Auth.auth().currentUser != nil {
            // User is signed in.
            signinOutlet.isHidden = true
            
        } else {
            // No user is signed in.
            signinOutlet.isHidden = false
        }
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
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
