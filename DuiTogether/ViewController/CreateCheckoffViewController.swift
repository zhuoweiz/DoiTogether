//
//  CreateCheckoffViewController.swift
//  DuiTogether
//
//  Created by Joey on 12/4/18.
//  Copyright © 2018 Joey. All rights reserved.
//

import UIKit
import Firebase

class CreateCheckoffViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UITextViewDelegate {
    
    let sharedModel = GroupsModel.shared
    let sharedUserModel = UserDataModel.shared
    var thisgid = ""
    var thisuid = ""
    var imgurl:URL? = nil
    var imgname: String? = nil
    var uploadUrl: String = ""
    
    @IBOutlet weak var pickedImageView: UIImageView!
    @IBOutlet weak var commentTextView: UITextView!
    @IBOutlet weak var scrollViewOuelte: UIScrollView!
    
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
    
    @IBAction func addImageAction(_ sender: Any) {
        if UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum){
            print("Button capture")
            
            imagePicker.delegate = self
            imagePicker.sourceType = .savedPhotosAlbum;
            imagePicker.allowsEditing = false
            
            self.present(imagePicker, animated: true, completion: nil)
        }
    }
    
    @objc func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        pickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage
        imgurl = info[UIImagePickerController.InfoKey.imageURL] as? URL
        
        //get filename
        if imgurl != nil {
            imgname = (imgurl!.absoluteString as NSString).lastPathComponent
        }
        
        picker.dismiss(animated: true, completion: { () -> Void in
            self.hasPicked = true;
            self.pickedImageView.image = self.pickedImage
        })
    }
    
    @IBAction func doneCheckOff(_ sender: UIButton) {
        if(hasPicked == false) {
            // validation fail, push alert
            
            // Code sniplet in a method
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
            
            let _ = checkoffimgRef.putFile(from: imgurl!, metadata: nil) { metadata, error in
                guard let metadata = metadata else {
                    // Uh-oh, an error occurred!
                    return
                }
                // Metadata contains file metadata such as size, content-type.
                let _ = metadata.size
                // You can also access to download URL after upload.
                checkoffimgRef.downloadURL { (url, error) in
//                    if let url = url {
//                        print("url \(url.absoluteString)")
//                    } else {
//                        print("test2")
//                    }
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
