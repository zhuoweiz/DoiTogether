//
//  LoginViewController.swift
//  DuiTogether
//
//  Created by Joey on 11/21/18.
//  Copyright © 2018 Joey. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseUI
import Firebase

class LoginViewController: UIViewController, FUIAuthDelegate {

    // outlets
    @IBOutlet weak var avatarShow: UIImageView!
    @IBOutlet weak var profileForm: UIView!
    
    @IBOutlet weak var emailShow: UILabel!
    
    @IBOutlet weak var SignInButtonOutlet: UIButton!
    @IBOutlet weak var SignOutButtonOutlet: UIButton!
    
    // Do any additional setup after loading the view.
    // initialize FirebaseUI
    
    // download image from url helper function
    func download(url: URL, image: UIImageView) {
        
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let d = data {
                DispatchQueue.main.async {
                    image.image = UIImage(data: d)
                }
            }
        }.resume()
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        avatarShow.layer.cornerRadius = 50.0
        avatarShow.clipsToBounds = true
        SignInButtonOutlet.clipsToBounds = true
        SignOutButtonOutlet.clipsToBounds = true
        SignInButtonOutlet.layer.cornerRadius = 6.0
        SignOutButtonOutlet.layer.cornerRadius = 6.0
        
//        if Auth.auth().currentUser != nil {
//            // User is signed in.
//            SignInButtonOutlet.isHidden = true
//
//            // show
//            profileForm.isHidden = false
//            SignOutButtonOutlet.isHidden = false
//            avatarShow.isHidden = false
//
//            
//            if let url = Auth.auth().currentUser?.photoURL {
//                print("downloading image...")
//                download(url: url.absoluteURL, image: avatarShow)
//            }
//            emailShow.text = Auth.auth().currentUser?.email
//
//        } else {
//            // No user is signed in.
//            avatarShow.isHidden = true
//            profileForm.isHidden = true
//            SignOutButtonOutlet.isHidden = true
//
//            // show
//            SignInButtonOutlet.isHidden = false
//        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if Auth.auth().currentUser != nil {
            // User is signed in.
            SignInButtonOutlet.isHidden = true
            
            // show
            profileForm.isHidden = false
            SignOutButtonOutlet.isHidden = false
            avatarShow.isHidden = false
            
            
            if let url = Auth.auth().currentUser?.photoURL {
                print("downloading image...")
                download(url: url.absoluteURL, image: avatarShow)
            }
            emailShow.text = Auth.auth().currentUser?.email
            
        } else {
            // No user is signed in.
            avatarShow.isHidden = true
            profileForm.isHidden = true
            SignOutButtonOutlet.isHidden = true
            
            // show
            SignInButtonOutlet.isHidden = false
        }
    }
    
    @IBAction func LoginAction(_ sender: UIButton) {
        let authUI = FUIAuth.defaultAuthUI()
        
        authUI?.delegate = self
        
        let providers: [FUIAuthProvider] = [
            FUIGoogleAuth(),
            ]
       
        authUI?.providers = providers
        
        let authViewController = authUI!.authViewController()
        present(authViewController, animated: true, completion: nil);
    }
    
    // Error and data handler Login
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
        
        // hide
        avatarShow.isHidden = true
        SignInButtonOutlet.isHidden = true
        
        // show
        profileForm.isHidden = false
        SignOutButtonOutlet.isHidden = false
        avatarShow.isHidden = false
        
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
        
        // after login UI change
        if let url = Auth.auth().currentUser?.photoURL {
            //print("url is: \(url)")
            avatarShow.load(url: url)
        }
        emailShow.text = Auth.auth().currentUser?.email
        emailShow.text = "\(user?.email ?? "t")"
        
//        old way of doing segue (this was for testing purpose to show a show page after successfully login, no functional use)
//        performSegue(withIdentifier: "goHome", sender: self)

    }
    // handler for google sign-in
    func application(_ app: UIApplication, open url: URL,
                     options: [UIApplication.OpenURLOptionsKey : Any]) -> Bool {
        let sourceApplication = options[UIApplication.OpenURLOptionsKey.sourceApplication] as! String?
        if FUIAuth.defaultAuthUI()?.handleOpen(url, sourceApplication: sourceApplication) ?? false {
            return true
        }
        // other URL handling goes here.
        return false
    }
    // return data handler
    func authUI(_ authUI: FUIAuth, didSignInWith authDataResult: AuthDataResult?, error: Error?) {
        
    }
    
    @IBAction func signOutAction(_ sender: UIButton) {
        do {
            try
            Auth.auth().signOut()
            UserDataModel.shared.logout()
            
            // No user is signed in.
            avatarShow.isHidden = true
            profileForm.isHidden = true
            SignOutButtonOutlet.isHidden = true
            
            // show
            SignInButtonOutlet.isHidden = false
        } catch {
            print(error)
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

}

extension UIImageView {
    func load(url: URL) {
        DispatchQueue.global().async { [weak self] in
            if let data = try? Data(contentsOf: url) {
                if let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        self?.image = image
                    }
                }
            }
        }
    }
    
//    func load_image(image_url_string:String, view:UIImageView)
//    {
//
//        var image_url: NSURL = NSURL(string: image_url_string)!
//        let image_from_url_request: NSURLRequest = NSURLRequest(URL: image_url)
//
//        NSURLConnection.sendAsynchronousRequest(
//            image_from_url_request, queue: NSOperationQueue.mainQueue(),
//            completionHandler: {(response: NSURLResponse!,
//                data: NSData!,
//                error: NSError!) -> Void in
//
//                if error == nil && data != nil {
//                    view.image = UIImage(data: data)
//                }
//        })
//    }
    
   
}
