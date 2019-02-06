//
//  CreateCheckoffViewController.swift
//  DuiTogether
//
//  Created by Joey on 12/4/18.
//  Copyright © 2018 Joey. All rights reserved.
//

import UIKit
import Firebase
import imgurupload_client
import Alamofire

class CreateCheckoffViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UITextViewDelegate {
    
    let sharedModel = GroupsModel.shared
    let sharedUserModel = UserDataModel.shared
    var thisgid = ""
    var thisuid = ""
    var imgurl:URL? = nil
    var imgData: Data? = nil
    var imgname: String? = nil
    var uploadUrl: String = ""
    var nudityPassed: Float = 0.1
    
    @IBOutlet weak var pickedImageView: UIImageView!
    @IBOutlet weak var commentTextView: UITextView!
    @IBOutlet weak var scrollViewOuelte: UIScrollView!
    @IBOutlet weak var failMessage: UILabel!
    
    // logic var
    var hasPicked = false;
    
    var imagePicker = UIImagePickerController()
    var pickedImage : UIImage!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.prefersLargeTitles = false
        // Do any additional setup after loading the view.
        pickedImageView.clipsToBounds = true
        pickedImageView.layer.cornerRadius = 12.0
    }
    override func viewWillAppear(_ animated: Bool) {
        failMessage.isHidden = true
    }
    override func viewWillDisappear(_ animated: Bool) {
        
    }
    
    @IBAction func addImageAction(_ sender: Any) {
        if UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum){
            print("Button capture")
            
            imagePicker.delegate = self
            imagePicker.sourceType = .savedPhotosAlbum;
            imagePicker.allowsEditing = true
            
            self.present(imagePicker, animated: true, completion: nil)
        }
    }
    
    @objc func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        let loadingLabel : UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: view.frame.width-30, height: 30))
        loadingLabel.text = " Image moderation check..."
        loadingLabel.adjustsFontSizeToFitWidth = true
        loadingLabel.center = self.view.center
        imagePicker.view.addSubview(loadingLabel)
        
        pickedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage
        imgurl = info[UIImagePickerController.InfoKey.imageURL] as? URL

        //get filename
        if imgurl != nil {
            imgname = (imgurl!.absoluteString as NSString).lastPathComponent
        }
        
        let imageData: Data = (info[UIImagePickerController.InfoKey.editedImage] as! UIImage).pngData()!
        imgData = imageData
        
        ImgurUpload.upload(imageData: imageData, apiKey: "3ed9465fe5c8557", completionHandler: { (response) in
            // print(response ?? "nothing to say")
            // parse response by getting the link
            var imglink = "null link"
            if let object = response!.result.value as? [String:Any], let message = object["data"] as? [String:Any] {
                
                for (key, value) in message {
                    if(key == "link") {
                        imglink = value as! String
                    }
                }
                // print("WORKING MIRACLE: \(imglink)")
                //TODO after get response, make an api call from the image detection api
                let parameters: Parameters = [
                    "api_user": "1551926080",
                    "api_secret": "H5gcA6WR9uiRms4T6crJ",
                    "url": imglink
                ]
                print(object)
                print("imglink is: \(imglink)")
                Alamofire.request("https://api.sightengine.com/1.0/nudity.json", parameters: parameters).responseJSON { response in
                    
                    if let object = response.result.value as? [String:Any], let message = object["nudity"] as? [String:Any] {
                        
                        for (key, value) in message {
                            if(key == "raw") {
                                let stringfloat = "\(value)"
                                print(stringfloat)
                                self.nudityPassed = Float(stringfloat)!
                                print("SUCCESS nudity is: \(self.nudityPassed)")
                            }
                        }
                    }
                    print(response)
                    loadingLabel.isHidden = true
                    self.imagePicker.view.willRemoveSubview(loadingLabel) // NOT WORKING
                    picker.dismiss(animated: true, completion: { () -> Void in
                        if(self.nudityPassed > 0.80) {
                            self.hasPicked = false;
                            self.triggerModerationFail()
                        } else {
                            self.hasPicked = true;
                            self.pickedImageView.image = self.pickedImage
                        }
                    })
                }
            }
            
//            guard let jsonArray = response as? [[String: Any]] else {
//                return
//            }
//            for dic in jsonArray {
//                guard let title = dic["link"] as? String else { return }
//                print(title) //Output
//            }

        })
        
        
    }
    
    func triggerModerationFail() {
        // animate a message about moderation fail
//        let failMessageLabel : UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: view.frame.width-30, height: 30))
//        failMessageLabel.text = " Image moderation check failed"
//        failMessageLabel.adjustsFontSizeToFitWidth = true
//        failMessageLabel.textColor = .red
//        failMessageLabel.center = self.view.center
//        self.view.addSubview(failMessageLabel)
        failMessage.isHidden = false
    }
    
    @IBAction func doneCheckOff(_ sender: UIButton) {
        if(hasPicked == false) {
            // validation fail, push alert
            let alertController = UIAlertController(title: NSLocalizedString("Alert", comment: ""),
                                                    message: NSLocalizedString("You have to add an image to check off", comment: ""),
                                                    preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: NSLocalizedString("Got it", comment: ""), style: .cancel, handler: nil)
            // Using the handler parameter, send the code to be executed (handle the action)
            
            alertController.addAction(cancelAction)
            self.present(alertController, animated: true, completion: nil)
        } else {
            // validation success, TODO data modifiers
            // upload image, get linke
            let storage = Storage.storage()
            let storageRef = storage.reference()
            
            // time formatter
            // let timecode = Tformater()
            let checkoffimgRef = storageRef.child("checkoffimgs/\(thisuid)\(thisgid)\(imgname ?? "nullpath")")
            
            let _ = checkoffimgRef.putData(imgData!, metadata: nil) { (metadata, error) in
                guard let metadata = metadata else {
                    // Uh-oh, an error occurred!
                    return
                }
                // Metadata contains file metadata such as size, content-type.
                let _ = metadata.size
                // You can also access to download URL after upload.
                checkoffimgRef.downloadURL { (url, error) in
                    self.uploadUrl = url?.absoluteString ?? "null link"
                    print("success.. \(self.uploadUrl)")
                    self.createCheckoff()
                    
                    guard let _ = url else {
                        // Uh-oh, an error occurred!
                        print("ERROR: image upload in check off")
                        return
                    }
                }
            }
            
//            let _ = checkoffimgRef.putFile(from: imgurl!, metadata: nil) { metadata, error in
//                guard let metadata = metadata else {
//                    // Uh-oh, an error occurred!
//                    return
//                }
//                // Metadata contains file metadata such as size, content-type.
//                let _ = metadata.size
//                // You can also access to download URL after upload.
//                checkoffimgRef.downloadURL { (url, error) in
////                    if let url = url {
////                        print("url \(url.absoluteString)")
////                    } else {
////                        print("test2")
////                    }
//                    self.uploadUrl = url?.absoluteString ?? "null link"
//                    print("success.. \(self.uploadUrl)")
//                    self.createCheckoff()
//
//                    guard let _ = url else {
//                        // Uh-oh, an error occurred!
//                        print("ERROR: image upload in check off")
//                        return
//                    }
//                }
//            }
            
            // pop vc
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    @IBAction func tappedOnce(_ sender: UITapGestureRecognizer) {
        commentTextView.resignFirstResponder()
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        scrollViewOuelte.setContentOffset(CGPoint(x: 0, y: 225), animated: true)
    }
    func textViewDidEndEditing(_ textView: UITextView) {
        scrollViewOuelte.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
    }
    func createCheckoff() {
        // print("testing... checkoffcreationg func")
        // create a checkoff, and put id inside days of the current group
        let db = Firestore.firestore();
        // var ref: DocumentReference? = nil
        
        // Add a new document in collection "cities"
        db.collection("checkoffs").document("\(self.thisuid)\(self.thisgid)\(Tformater())").setData([
            "uid": "\(self.thisuid)",
            "username" : "\(self.sharedUserModel.getusername())",
            "gid": "\(self.thisgid)",
            "imgurl": "\(self.uploadUrl)",
            "dayid": "\(Tformater())",
            "comments": self.commentTextView.text,
            "isVerified": false,
            "verifierList": [], // store ids
            "creationdate": Date()
        ]) { err in
            if let err = err {
                print("Error writing document: \(err)")
            } else {
                print("Firebase: checkoff doc added with ID")
                
                // after creation of checkoff doc, put this id to group
                // count days first
//                let daya:Date = self.sharedModel.getGroupById(gid: self.thisgid).getCreationDate()
//                let dayb:Date = Date()
//                let dayCount = countDays(dateA: daya, dateB: dayb)
//                db.collection("groups").document(self.thisgid).collection("days").document("day\(dayCount)").setData([
//                    "\(self.thisuid)": "\(self.thisuid)\(self.thisgid)\(Tformater())"
//                ]) { err in
//                    if let err = err {
//                        print("Error writing document: \(err)")
//                    } else {
//                        print("Firesbase: day for checkoff successfully written!")
//                    }
//                }
                db.collection("groups").document(self.thisgid).collection("checkoffs").document("\(self.thisuid)\(self.thisgid)\(Tformater())").setData([
                    "creationdate" : Date()
                ]) { err in
                    if let err = err {
                        print("Error writing document: \(err)")
                    } else {
                        print("Firesbase: day for checkoff successfully written!")
                    }
                }
            }
        }
        
//        ref = db.collection("checkoffs").addDocument(data: [
//            "uid": "\(self.thisuid)",
//            "gid": "\(self.thisgid)",
//            "imgurl": "\(self.uploadUrl)",
//            "dayid": "\(Tformater())",
//            "comments": self.commentTextView.text,
//            "creationdate": Date()
//        ]) { err in
//            if let err = err {
//                print("Error adding document: \(err)")
//            } else {
//                print("Firebase: checkoff doc added with ID: \(ref!.documentID)")
//
//
//            }
//        }
    }
}
