//
//  AddFactViewController.swift
//  FunFactTest
//
//  Created by Rushi Dolas on 7/26/18.
//  Copyright © 2018 Rushi Dolas. All rights reserved.
//

import UIKit
import Firebase
import FirebaseStorage
import MapKit
import FirebaseAuth

class AddNewFactViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate, UITextViewDelegate, UITextFieldDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var landmarkImage: UIImageView!
    @IBOutlet weak var landmarkType: UIPickerView!
    @IBOutlet weak var landmarkNameTextField: UITextField?
    @IBOutlet weak var addressTextField: UITextField?
    @IBOutlet weak var imageCaption: UITextView!
    @IBOutlet weak var funFactDescription: UITextView!
    @IBOutlet weak var sourceTextField: UITextField!
    @IBOutlet weak var submitButton: CustomButton!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var addressBtn: UIButton!
    @IBOutlet weak var landmarkNameBtn: UIButton!
    @IBOutlet weak var sourceBtn: UIButton!
    @IBOutlet weak var autocompleteTableView: UITableView!
    
    var address: String?
    var landmarkName: String?
    var landmarkID: String!
    var pickerData: [String] = [String]()
    var coordinate = CLLocationCoordinate2D()
    var type: String?
    var city: String?
    var state: String?
    var country: String?
    var zipcode: String?
    var popup = UIAlertController()
    var tag = 100
    var hashtags = [String: Int]()
    var autocompleteHashtags = [String]()
    var mode = ""
    var funFactID = ""
    var landmarkTypeText = ""
    var imageCaptionText = ""
    var image = ""
    var funFactDesc = ""
    var source = ""
    var typedSubstring = ""
    var likes = 0
    var dislikes = 0
    var verificationFlag = "N"
    var disputeFlag = "N"
    var landmark = Landmark(id: "",
                            name: "",
                            address: "",
                            city: "",
                            state: "",
                            zipcode: "",
                            country: "",
                            type: "",
                            coordinates: GeoPoint(latitude: 0, longitude: 0),
                            image: "")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.tintColor = .darkGray
        
        downloadHashtags { (hashtags) in
            self.hashtags = hashtags
        }
        funFactDescription.keyboardDistanceFromTextField = 200
        autocompleteTableView.translatesAutoresizingMaskIntoConstraints = false
        autocompleteTableView.delegate = self
        autocompleteTableView.dataSource = self
        autocompleteTableView.isScrollEnabled = true
        autocompleteTableView.isHidden = true
        contentView.bringSubviewToFront(autocompleteTableView)

        scrollView.scrollIndicatorInsets = UIEdgeInsets(top: 30, left: 0, bottom: 0, right: 2)
        scrollView.autoresizingMask = UIView.AutoresizingMask(rawValue: UIView.AutoresizingMask.RawValue(UInt8(UIView.AutoresizingMask.flexibleWidth.rawValue) | UInt8(UIView.AutoresizingMask.flexibleHeight.rawValue)))
        scrollView.isUserInteractionEnabled = true
        
        addressBtn.titleLabel?.font = UIFont.fontAwesome(ofSize: 25, style: .solid)
        addressBtn.setTitle(String.fontAwesomeIcon(name: .mapMarked), for: .normal)
        
        landmarkNameBtn.titleLabel?.font = UIFont.fontAwesome(ofSize: 25, style: .solid)
        landmarkNameBtn.setTitle(String.fontAwesomeIcon(name: .university), for: .normal)
        
        sourceBtn.titleLabel?.font = UIFont.fontAwesome(ofSize: 25, style: .solid)
        sourceBtn.setTitle(String.fontAwesomeIcon(name: .book), for: .normal)

        imageCaption.tag = 0
        funFactDescription.tag = 1
        pickerData = Constants.landmarkTypes
        self.landmarkType.delegate = self
        self.landmarkType.dataSource = self
        self.funFactDescription.delegate = self
        self.imageCaption.delegate  = self
        self.sourceTextField.delegate  = self
        
        let cancelItem = UIBarButtonItem(
            title: "Cancel",
            style: .plain,
            target: self,
            action: #selector(cancelAction(_:))
        )
        navigationItem.rightBarButtonItem = cancelItem
        
        addressTextField?.layer.borderWidth = 0
        addressTextField?.layer.borderColor = UIColor.darkGray.cgColor
        addressTextField?.layer.cornerRadius = 5
        landmarkNameTextField?.layer.borderWidth = 0
        landmarkNameTextField?.layer.borderColor = UIColor.darkGray.cgColor
        landmarkNameTextField?.layer.cornerRadius = 5
        
        landmarkType?.layer.borderWidth = 0
        landmarkType?.layer.borderColor = UIColor.darkGray.cgColor
        landmarkType?.layer.cornerRadius = 5
        
        addressTextField?.text = address
        landmarkNameTextField?.text = landmarkName
        
        if address != nil {
            addressTextField?.isUserInteractionEnabled = false
            landmarkNameTextField?.isUserInteractionEnabled = false
        }
        
        let mytapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(viewAddressScreen))
        mytapGestureRecognizer.numberOfTapsRequired = 1
        addressTextField?.addGestureRecognizer(mytapGestureRecognizer)
        addressTextField?.isUserInteractionEnabled = true
        landmarkImage.layer.borderWidth = 0.5
        landmarkImage.layer.borderColor = UIColor.lightGray.cgColor
        landmarkImage.layer.cornerRadius = 5
        
        let imagePickerTapGesture = UITapGestureRecognizer(target: self, action: #selector(viewImagePicker))
        imagePickerTapGesture.numberOfTapsRequired = 1
        landmarkImage?.addGestureRecognizer(imagePickerTapGesture)
        landmarkImage?.isUserInteractionEnabled = true
        
        imageCaption.layer.borderWidth = 0
        imageCaption.layer.borderColor = UIColor.darkGray.cgColor
        imageCaption.layer.cornerRadius = 5
        
        imageCaption.text = "Click on the icon to select image. Enter image caption here."
        imageCaption.textColor = UIColor.lightGray
        
        funFactDescription.text = "Enter the fun fact details. Maximum 300 characters. Please keep the facts relevant and precise. Make sure to enter #hashtags to make your facts searchable."
        funFactDescription.textColor = UIColor.lightGray
        
        funFactDescription.layer.borderWidth = 0
        funFactDescription.layer.borderColor = UIColor.darkGray.cgColor
        funFactDescription.layer.cornerRadius = 5
        
        sourceTextField.layer.borderWidth = 0
        sourceTextField.layer.borderColor = UIColor.darkGray.cgColor
        sourceTextField.layer.cornerRadius = 5
        
        submitButton.backgroundColor = Constants.redColor
        
        submitButton.widthAnchor.constraint(equalToConstant: self.view.frame.width - 20).isActive = true
        
        if mode == "edit" {
            navigationItem.title = "Edit Fun Fact"
            getLandmarkObject(landmarkID: landmarkID, completionHandler: { (landmark) in
                self.landmark = landmark
                self.landmarkType.selectRow(self.pickerData.firstIndex(of: self.landmark.type)!, inComponent: 0, animated: true)
                self.addressTextField?.text = landmark.address
            })
            funFactDescription.text = funFactDesc
            imageCaption.text = imageCaptionText
            sourceTextField.text = source
            funFactDescription.textColor = UIColor.black
            imageCaption.textColor = UIColor.black
            setupImage()
        }
        else {
            navigationItem.title = "Add A New Fun Fact"
            landmarkImage.image = UIImage.fontAwesomeIcon(name: .images, style: .solid, textColor: .lightGray, size: CGSize(width: landmarkImage.frame.width, height: landmarkImage.frame.height), backgroundColor: .clear)
        }
    }
    
    func downloadHashtags(completionHandler: @escaping ([String:Int]) -> ()) {
        var hashtags = [String:Int]()
        let db = Firestore.firestore()
        db.collection("hashtags").getDocuments() { (snap, error) in
            if let err = error {
                print("Error getting documents: \(err)")
            } else {
                for doc in snap!.documents {
                    hashtags[doc.documentID] = doc.data()["count"] as? Int
                }
            }
            completionHandler(hashtags)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Hide the navigation bar on the this view controller
        self.navigationController?.toolbar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Show the navigation bar on other view controllers
        self.navigationController?.toolbar.isHidden = false
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let backItem = UIBarButtonItem()
        backItem.title = ""
        navigationItem.backBarButtonItem = backItem
        
        let destinationAddFactVC = segue.destination as? AddressViewController
        destinationAddFactVC?.callback = { addDet in
            self.landmarkNameTextField?.text = addDet.landmarkName
            self.addressTextField?.text = addDet.address
            self.landmarkName = addDet.landmarkName
            self.address = addDet.address
            self.country = addDet.country
            self.city = addDet.city
            self.state = addDet.state
            self.zipcode = addDet.zipcode
            self.coordinate = addDet.coordinate!
            let add = addDet.address ?? ""
            let city = addDet.city ?? ""
            let state = addDet.state ?? ""
            let country = addDet.country ?? ""
            let zipcode = addDet.zipcode ?? ""
            let address = (add+city+state+country+zipcode).lowercased()
            
            self.checkIfLandmarkExists(address: address, completionHandler: { (id) in
                print (id)
                self.landmarkID = id
            })
            
        }
    }
    
    func checkIfLandmarkExists(address: String, completionHandler: @escaping (String) -> ()) {
        let db = Firestore.firestore()
        var landmarkID = ""
        db.collection("landmarks").getDocuments { (snapshot, error) in
            if let error = error {
                print("Error getting documents: \(error)")
            } else {
                for document in snapshot!.documents {
                    let addr = ((document.data()["address"] as! String)
                        + (document.data()["city"] as! String)
                        + (document.data()["state"] as! String)
                        + (document.data()["country"] as! String)
                        + (document.data()["zipcode"] as! String)).lowercased()
                    
                    if addr == address  {
                        print ("!!!Landmark Exists!!!")
                        landmarkID = document.data()["id"] as! String
                        completionHandler(landmarkID)
                    }
                    else {
                        completionHandler(landmarkID)
                    }
                }
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @objc func viewAddressScreen(recognizer: UITapGestureRecognizer) {
        performSegue(withIdentifier: "addressDetail", sender: nil)
    }
    @objc func viewImagePicker(recognizer: UITapGestureRecognizer) {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.photoLibrary){
            let imag = UIImagePickerController()
            imag.delegate = self
            imag.sourceType = UIImagePickerController.SourceType.photoLibrary
            //imag.mediaTypes = [kUTTypeImage];
            imag.allowsEditing = false
            self.present(imag, animated: true, completion: nil)
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        // Local variable inserted by Swift 4.2 migrator.
        let info = convertFromUIImagePickerControllerInfoKeyDictionary(info)
        
        let selectedImage = info[convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.originalImage)] as! UIImage
        //var tempImage:UIImage = editingInfo[UIImagePickerControllerOriginalImage] as UIImage
        landmarkImage.image = selectedImage
        self.dismiss(animated: true, completion: nil)
    }

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerData[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        var label = view as! UILabel?
        if label == nil {
            label = UILabel()
        }
        
        let data = pickerData[row]
        let title = NSAttributedString(string: data, attributes: [NSAttributedString.Key.font: UIFont(name: "Avenir Next", size: 14)!])
        label?.attributedText = title
        label?.textAlignment = .center
        return label!
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        type = pickerData[row]
    }
    
    func textViewDidChange(_ textView: UITextView) {
        
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        tag = textView.tag
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor.black
        }
        navigationController?.navigationBar.isHidden = true
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            if textView.tag == 0 {
                textView.text = "Click on the icon to select image. Enter image caption here."
            }
            else if textView.tag == 1 {
                textView.text = "Enter the fun fact details. Maximum 300 characters. Please keep the facts relevant and precise. Make sure to enter #hashtags to make your facts searchable."
            }
            
            textView.textColor = UIColor.lightGray
        }
        navigationController?.navigationBar.isHidden = false
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        navigationController?.navigationBar.isHidden = true
    }

    // Finish Editing The Text Field
    func textFieldDidEndEditing(_ textField: UITextField) {
        navigationController?.navigationBar.isHidden = false
    }
    
    // Hide the keyboard when the return key pressed
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        autocompleteTableView.isHidden = true
        let newText = (textView.text as NSString).replacingCharacters(in: range, with: text)
        let numberOfChars = newText.count
        let tags = newText.components(separatedBy: "#")
        var tagSubstring = ""
        if tags.count > 1 && !((tags.last?.contains(" "))! || (tags.last?.contains("."))!) {
            tagSubstring = tags.last!
            autocompleteTableView.isHidden = false
            searchAutocompleteEntriesWithSubstring(substring: tagSubstring)
        }
        return numberOfChars < 300
    }
    
    @objc func cancelAction(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func addFunFact(_ sender: Any) {
        if validatePage() {
            return
        }
        let db = Firestore.firestore()
        
        //Date formatting start
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let myString = formatter.string(from: Date())
        let yourDate = formatter.date(from: myString)
        formatter.dateFormat = "MMM dd, yyyy"
        let myStringafd = formatter.string(from: yourDate!)
        //Date formatting end
        var tempLandmarkID = ""
        tempLandmarkID = (landmarkID == "") ? db.collection("landmarks").document().documentID : landmarkID
        city = (city == "" || city == nil) ? landmark.city : city
        address = (address == "" || address == nil) ? landmark.address : address
        state = (state == "" || state == nil) ? landmark.state : state
        zipcode = (zipcode == "" || zipcode == nil) ? landmark.zipcode : zipcode
        country = (country == "" || country == nil) ? landmark.country : country
        coordinate = (coordinate.latitude == 0) ? CLLocationCoordinate2D(latitude: landmark.coordinates.latitude, longitude: landmark.coordinates.longitude) : coordinate
        print ("*********landmark.city = \(landmark.city )")
        
        //Upload Landmark details - merge if landmark already exists
        db.collection("landmarks").document(tempLandmarkID).setData([
            "id": tempLandmarkID as Any,
            "name": landmarkName as Any,
            "address": address as Any,
            "city": city as Any,
            "state": state as Any,
            "zipcode": zipcode as Any,
            "country": country as Any,
            "image": "", //TODO
            "type": type as Any,
            "coordinates": GeoPoint(latitude: self.coordinate.latitude as Double, longitude: self.coordinate.longitude as Double)
        ], merge: true) { err in
            if let err = err {
                print("Error writing document: \(err)")
            } else {
                print("Document successfully written!")
            }
        }
        //Upload fun fact details
        let ffID = (mode != "edit") ? db.collection("funFacts").document().documentID : funFactID
        db.collection("funFacts").document(ffID).setData([
            "landmarkId": tempLandmarkID as Any,
            "id": ffID,
            "description": funFactDescription.text,
            "likes": likes,
            "dislikes": dislikes,
            "verificationFlag": verificationFlag,
            "imageName": ffID,
            "disputeFlag": disputeFlag,
            "submittedBy": Auth.auth().currentUser?.uid ?? "",
            "dateSubmitted": myStringafd,
            "imageCaption": imageCaption.text!,
            "source": sourceTextField.text!,
            "tags": funFactDescription.text.hashtags()
        ], merge: true){ err in
            if let err = err {
                print("Error writing document: \(err)")
                self.showAlert(message: "fail")
            } else {
                print("Document successfully written!")
                self.showAlert(message: "success")
            }
        }
        uploadImage(imageName: ffID + ".jpeg")
        addHashtags(funFactID: ffID, hashtags: funFactDescription.text.hashtags())
        addUserSubmitted(funFactID: ffID, userID: Auth.auth().currentUser?.uid ?? "")
    }
    
    func addHashtags(funFactID: String, hashtags: [String]) {
        let db = Firestore.firestore()
        let funFactRef = db.collection("funFacts").document(funFactID)
        
        for hashtag in hashtags {
            db.collection("hashtags").document(hashtag).collection("funFacts").document(funFactID).setData([
                "funFactID": funFactRef
            ], merge: true){ err in
                if let err = err {
                    print("Error writing document: \(err)")
                } else {
                    print("Document successfully written!")
                }
            }
        }
    }
    func addUserSubmitted(funFactID: String, userID: String) {
        let db = Firestore.firestore()
        let funFactRef = db.collection("funFacts").document(funFactID)
        
        db.collection("users").document(userID).collection("funFactsSubmitted").document(funFactID).setData([
            "funFactID": funFactRef
        ], merge: true){ err in
            if let err = err {
                print("Error writing document: \(err)")
            } else {
                print("Document successfully written!")
            }
        }
    }
    
    func getLandmarkObject(landmarkID: String, completionHandler: @escaping (Landmark) -> ()) {
        let db = Firestore.firestore()
        print("inside getLandmarkObject")
        var landmark = Landmark(id: "",
                                name: "",
                                address: "",
                                city: "",
                                state: "",
                                zipcode: "",
                                country: "",
                                type: "",
                                coordinates: GeoPoint(latitude: 0, longitude: 0),
                                image: "")
        db.collection("landmarks").document(landmarkID).getDocument { (snapshot, error) in
            if let document = snapshot {
                landmark.id = document.data()?["id"] as! String
                landmark.name = document.data()?["name"] as! String
                landmark.address = document.data()?["address"] as! String
                landmark.city = document.data()?["city"] as! String
                landmark.state = document.data()?["state"] as! String
                landmark.zipcode = document.data()?["zipcode"] as! String
                landmark.country = document.data()?["country"] as! String
                landmark.type = document.data()?["type"] as! String
                landmark.coordinates = document.data()?["coordinates"] as! GeoPoint
                landmark.image = document.data()?["image"] as! String
                print (landmark)
                completionHandler(landmark)
            }
            else {
                let error = error
                print ("Error getting doc \(String(describing: error))")
            }
        }
    }
    
    func validatePage() -> Bool {
        var errors = false
        let title = "Error"
        var message = ""
        let image = UIImage.fontAwesomeIcon(name: .camera, style: .solid, textColor: .darkGray, size: CGSize(width: landmarkImage.bounds.width, height: landmarkImage.bounds.height), backgroundColor: .clear)
        let imageData = image.jpegData(compressionQuality: 1.0)
        let formImageData = landmarkImage.image!.jpegData(compressionQuality: 1.0)
        if (addressTextField?.text?.isEmpty)! {
            errors = true
            message += "Please enter a street address"
            Utils.alertWithTitle(title: title, message: message, viewController: self, toFocus: self.addressTextField!, type: "textfield")
        }
        if (landmarkNameTextField?.text?.isEmpty)! {
            errors = true
            message += "Please enter a landmark name"
            Utils.alertWithTitle(title: title, message: message, viewController: self, toFocus: self.landmarkNameTextField!, type: "textfield")
        }
        if funFactDescription?.text == "Enter the fun fact details. Maximum 300 characters. Please keep the facts relevant and precise. Make sure to enter #hashtags to make your facts searchable." {
            errors = true
            message += "Please enter a fun fact description"
            Utils.alertWithTitle(title: title, message: message, viewController: self, toFocus: self.funFactDescription!, type: "textview")
        }
        if (sourceTextField?.text?.isEmpty)! {
            errors = true
            message += "Please enter a valid source"
            Utils.alertWithTitle(title: title, message: message, viewController: self, toFocus: self.sourceTextField!, type: "textfield")
        }
        if imageData == formImageData  {
            errors = true
            message += "Please select an image for your fun fact"
            Utils.alertWithTitle(title: title, message: message, viewController: self, toFocus: self.landmarkImage!, type: "imageview")
        }
        if (type ?? "").isEmpty || type == "--- Select landmark type ---" {
            errors = true
            message += "Please enter a valid landmark type"
            Utils.alertWithTitle(title: title, message: message, viewController: self, toFocus: self.landmarkType!, type: "pickerview")
        }
        return errors
    }
    func alertWithTitle(title: String!, message: String, viewController: UIViewController, toFocus: Any, type: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: UIAlertAction.Style.cancel,handler: {_ in
            switch(type) {
            case "textfield":
                (toFocus as! UITextField).becomeFirstResponder()
            case "textview":
                (toFocus as! UITextView).becomeFirstResponder()
            case "imageview":
                (toFocus as! UIImageView).becomeFirstResponder()
            case "pickerview":
                (toFocus as! UIPickerView).becomeFirstResponder()
            default:
                print("default")
            }
            
        })
        alert.addAction(action)
        viewController.present(alert, animated: true, completion:nil)
    }
    
    func showAlert(message: String) {
        if message == "success" {
            popup = UIAlertController(title: "Success", message: "Fun Fact uploaded successfully!", preferredStyle: .alert)
        }
        if message == "fail" {
            popup = UIAlertController(title: "Error", message: "Error while uploading Fun Fact", preferredStyle: .alert)
        }

        self.present(popup, animated: true, completion: nil)
        Timer.scheduledTimer(timeInterval: 2.0, target: self, selector: #selector(self.dismissAlert), userInfo: nil, repeats: false)
    }
    
    @objc func dismissAlert() {
        popup.dismiss(animated: true)
        navigationController?.popViewController(animated: true)
    }
    
    func setupImage() {
        let imageId = funFactID
        let imageName = "\(imageId).jpeg"
        let imageFromCache = CacheManager.shared.getFromCache(key: imageName) as? UIImage
        if imageFromCache != nil {
            print("******In cache")
            self.landmarkImage.image = imageFromCache
            self.landmarkImage.layer.cornerRadius = 5
        } else {
            let imageName = "\(funFactID).jpeg"
            
            let storage = Storage.storage()
            let storageRef = storage.reference()
            let gsReference = storageRef.child("images/\(imageName)")
            self.landmarkImage.sd_setImage(with: gsReference, placeholderImage: UIImage())
            self.landmarkImage.layer.cornerRadius = 5
        }
    }
    
    func uploadImage(imageName: String) {
        let storage = Storage.storage()
        var data = Data()
        // Create a storage reference from our storage service
        let storageRef = storage.reference()
        // Data in memory

        do {
            try landmarkImage.image?.compressImage(300, completion: { (image, compressRatio) in
                print(image.size)
                data = image.jpegData(compressionQuality: compressRatio)!
            })
        } catch {
            print("Error")
        }
        
        // Create a reference to the file you want to upload
        let landmarkRef = storageRef.child("images/\(imageName)")
        
        // Upload the file to the path "images/rivers.jpg"
        landmarkRef.putData(data, metadata: nil) { (metadata, error) in
            guard let metadata = metadata
                else {
                // Uh-oh, an error occurred!
                return
            }
            // Metadata contains file metadata such as size, content-type.
            metadata.contentType = "image/jpeg"
            metadata.cacheControl = "public,max-age=300"
            landmarkRef.putData(data, metadata: metadata)
            // You can also access to download URL after upload.
            landmarkRef.downloadURL { (url, error) in
                guard url != nil else {
                    // Uh-oh, an error occurred!
                    return
                }
            }
        }
    }
}

extension UIImage {
    enum CompressImageErrors: Error {
        case invalidExSize
        case sizeImpossibleToReach
    }
    func compressImage(_ expectedSizeKb: Int, completion : (UIImage,CGFloat) -> Void ) throws {
        
        let minimalCompressRate :CGFloat = 0.4 // min compressRate to be checked later
        
        if expectedSizeKb == 0 {
            throw CompressImageErrors.invalidExSize // if the size is equal to zero throws
        }
        
        let expectedSizeBytes = expectedSizeKb * 1024
        let imageToBeHandled: UIImage = self
        var actualHeight : CGFloat = self.size.height
        var actualWidth : CGFloat = self.size.width
        var maxHeight : CGFloat = 841 //A4 default size I'm thinking about a document
        var maxWidth : CGFloat = 594
        var imgRatio : CGFloat = actualWidth/actualHeight
        let maxRatio : CGFloat = maxWidth/maxHeight
        var compressionQuality : CGFloat = 1
        var imageData:Data = imageToBeHandled.jpegData(compressionQuality: compressionQuality)!
        while imageData.count > expectedSizeBytes {
            
            if (actualHeight > maxHeight || actualWidth > maxWidth){
                if(imgRatio < maxRatio){
                    imgRatio = maxHeight / actualHeight
                    actualWidth = imgRatio * actualWidth
                    actualHeight = maxHeight
                }
                else if(imgRatio > maxRatio){
                    imgRatio = maxWidth / actualWidth;
                    actualHeight = imgRatio * actualHeight
                    actualWidth = maxWidth
                }
                else{
                    actualHeight = maxHeight
                    actualWidth = maxWidth
                    compressionQuality = 1
                }
            }
            let rect = CGRect(x: 0.0, y: 0.0, width: actualWidth, height: actualHeight)
            UIGraphicsBeginImageContext(rect.size)
            imageToBeHandled.draw(in: rect)
            let img = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            if let imgData = img!.jpegData(compressionQuality: compressionQuality) {
                if imgData.count > expectedSizeBytes {
                    if compressionQuality > minimalCompressRate {
                        compressionQuality -= 0.1
                    } else {
                        maxHeight = maxHeight * 0.9
                        maxWidth = maxWidth * 0.9
                    }
                }
                imageData = imgData
            }
        }
        completion(UIImage(data: imageData)!, compressionQuality)
    }
}
extension String
{
    func hashtags() -> [String] {
        if let regex = try? NSRegularExpression(pattern: "#[a-z0-9]+", options: .caseInsensitive) {
            let string = self as NSString
            
            return regex.matches(in: self, options: [], range: NSRange(location: 0, length: string.length)).map {
                string.substring(with: $0.range).replacingOccurrences(of: "#", with: "").lowercased()
            }
        }
        return []
    }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKeyDictionary(_ input: [UIImagePickerController.InfoKey: Any]) -> [String: Any] {
	return Dictionary(uniqueKeysWithValues: input.map {key, value in (key.rawValue, value)})
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKey(_ input: UIImagePickerController.InfoKey) -> String {
	return input.rawValue
}

extension AddNewFactViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return autocompleteHashtags.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? HashtagCell
        let index = indexPath.row as Int
        
        cell?.hashtag?.text = "#\(autocompleteHashtags[index])"
        cell?.count?.text = "\(String(describing: self.hashtags[autocompleteHashtags[index]]!)) posts"
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedCell = tableView.cellForRow(at: indexPath)! as! HashtagCell
        let tempStr = self.funFactDescription.text.components(separatedBy: "#").dropLast().joined(separator: "#")
        
        self.funFactDescription.text = tempStr + selectedCell.hashtag.text!
        autocompleteTableView.isHidden = true
    }
    
    func searchAutocompleteEntriesWithSubstring(substring: String) {
        autocompleteHashtags.removeAll(keepingCapacity: true)
        for curString in self.hashtags.keys
        {
            let myString:NSString! = curString as NSString
            let substringRange :NSRange! = myString.range(of: substring)
            
            if (substringRange.location  == 0) {
                autocompleteHashtags.append(curString)
            }
        }
        autocompleteTableView.reloadData()
    }
}
