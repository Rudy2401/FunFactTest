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
    @IBOutlet var landmarkNameTextField: UITextField?
    @IBOutlet var addressTextField: UITextField?
    @IBOutlet weak var imageCaption: UITextView!
    @IBOutlet weak var funFactDescription: UITextView!
    @IBOutlet weak var sourceTextField: UITextField!
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var contentView: UIView!
    var address: String?
    var landmarkName: String?
    var pickerData: [String] = [String]()
    var coordinate = CLLocationCoordinate2D()
    var type: String?
    var city: String?
    var state: String?
    var country: String?
    var zipcode: String?
    var listOfLandmarks = ListOfLandmarks.init(listOfLandmarks: [])
    var listOfFunFacts = ListOfFunFacts.init(listOfFunFacts: [])
    var funFactDict = [String: [FunFact]]()
    var popup = UIAlertController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.tintColor = UIColor.darkGray

        scrollView.scrollIndicatorInsets = UIEdgeInsets(top: 30, left: 0, bottom: 0, right: 2)
        self.hideKeyboardWhenTappedAround()
        funFactDict = Dictionary(grouping: listOfFunFacts.listOfFunFacts, by: { $0.landmarkId })
        imageCaption.tag = 0
        funFactDescription.tag = 1
        pickerData = ["--- Select landmark type ---", "Apartment", "Office Building", "Stadium", "Museum", "Park", "Restaurant/Cafe", "Landmark"]
        self.landmarkType.delegate = self
        self.landmarkType.dataSource = self
        self.funFactDescription.delegate = self
        self.imageCaption.delegate  = self
        self.sourceTextField.delegate  = self
        navigationController?.navigationBar.prefersLargeTitles = true
        
        let cancelItem = UIBarButtonItem(
            title: "Cancel",
            style: .plain,
            target: self,
            action: #selector(cancelAction(_:))
        )
        navigationItem.rightBarButtonItem = cancelItem
        
        navigationItem.title = "Add A New Fun Fact"
        
        addressTextField?.layer.borderWidth = 0.5
        addressTextField?.layer.borderColor = UIColor.darkGray.cgColor
        addressTextField?.layer.cornerRadius = 5
        landmarkNameTextField?.layer.borderWidth = 0.5
        landmarkNameTextField?.layer.borderColor = UIColor.darkGray.cgColor
        landmarkNameTextField?.layer.cornerRadius = 5
        
        landmarkType?.layer.borderWidth = 0.5
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
        landmarkImage.layer.borderColor = UIColor.darkGray.cgColor
        landmarkImage.layer.cornerRadius = 5
        landmarkImage.image = UIImage.fontAwesomeIcon(name: .camera, style: .solid, textColor: .darkGray, size: CGSize(width: landmarkImage.bounds.width, height: landmarkImage.bounds.height), backgroundColor: .clear)
        
        let imagePickerTapGesture = UITapGestureRecognizer(target: self, action: #selector(viewImagePicker))
        imagePickerTapGesture.numberOfTapsRequired = 1
        landmarkImage?.addGestureRecognizer(imagePickerTapGesture)
        landmarkImage?.isUserInteractionEnabled = true
        
        imageCaption.layer.borderWidth = 0.5
        imageCaption.layer.borderColor = UIColor.darkGray.cgColor
        imageCaption.layer.cornerRadius = 5
        
        imageCaption.text = "Enter image caption."
        imageCaption.textColor = UIColor.lightGray
        
        funFactDescription.text = "Enter the fun fact details. Maximum 300 characters. Please keep the facts relevant and precise."
        funFactDescription.textColor = UIColor.lightGray
        
        funFactDescription.layer.borderWidth = 0.5
        funFactDescription.layer.borderColor = UIColor.darkGray.cgColor
        funFactDescription.layer.cornerRadius = 5
        
        sourceTextField.layer.borderWidth = 0.5
        sourceTextField.layer.borderColor = UIColor.darkGray.cgColor
        sourceTextField.layer.cornerRadius = 5
        
        submitButton.layer.cornerRadius = 20
        submitButton.backgroundColor = Constants.redColor
        
        submitButton.widthAnchor.constraint(equalToConstant: self.view.frame.width - 20).isActive = true
        
        let submitBarButton = UIBarButtonItem(customView: submitButton)
        
        let toolBarItems: [UIBarButtonItem]
        toolBarItems = [submitBarButton]
        self.setToolbarItems(toolBarItems, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let backItem = UIBarButtonItem()
        backItem.title = ""
        navigationItem.backBarButtonItem = backItem
        
        let destinationAddFactVC = segue.destination as? AddressViewController
        destinationAddFactVC?.listOfLandmarks.listOfLandmarks = listOfLandmarks.listOfLandmarks
        destinationAddFactVC?.listOfFunFacts.listOfFunFacts = listOfFunFacts.listOfFunFacts
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
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.photoLibrary){
            let imag = UIImagePickerController()
            imag.delegate = self
            imag.sourceType = UIImagePickerControllerSourceType.photoLibrary
            //imag.mediaTypes = [kUTTypeImage];
            imag.allowsEditing = false
            self.present(imag, animated: true, completion: nil)
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let selectedImage = info[UIImagePickerControllerOriginalImage] as! UIImage
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
        let title = NSAttributedString(string: data, attributes: [NSAttributedStringKey.font: UIFont(name: "Avenir Next", size: 14)!])
        label?.attributedText = title
        label?.textAlignment = .center
        return label!
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        type = pickerData[row]
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor.black
        }
        if textView.tag == 1 {
//            moveTextView(textView, moveDistance: -250, up: true)
//            navigationController?.navigationBar.isHidden = true
        }
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            if textView.tag == 0 {
                textView.text = "Enter image caption."
            }
            else if textView.tag == 1 {
                textView.text = "Enter the fun fact details. Maximum 300 characters. Please keep the facts relevant and precise."
            }

            textView.textColor = UIColor.lightGray
        }
        if textView.tag == 1 {
//            moveTextView(textView, moveDistance: -250, up: false)
//            navigationController?.navigationBar.isHidden = false
        }
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
//        moveTextField(textField, moveDistance: -250, up: true)
//        navigationController?.navigationBar.isHidden = true
    }

    // Finish Editing The Text Field
    func textFieldDidEndEditing(_ textField: UITextField) {
//        moveTextField(textField, moveDistance: -250, up: false)
//        navigationController?.navigationBar.isHidden = false
    }
    
    // Hide the keyboard when the return key pressed
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let newText = (textView.text as NSString).replacingCharacters(in: range, with: text)
        let numberOfChars = newText.count
        return numberOfChars < 300;
    }
    
    // Move the text field in a pretty animation!
    func moveTextField(_ textField: UITextField, moveDistance: Int, up: Bool) {
        let moveDuration = 0.3
        let movement: CGFloat = CGFloat(up ? moveDistance : -moveDistance)
        
        UIView.beginAnimations("animateTextField", context: nil)
        UIView.setAnimationBeginsFromCurrentState(true)
        UIView.setAnimationDuration(moveDuration)
        self.view.frame = self.view.frame.offsetBy(dx: 0, dy: movement)
        UIView.commitAnimations()
    }
    
    // Move the text view in a pretty animation!
    func moveTextView(_ textField: UITextView, moveDistance: Int, up: Bool) {
        let moveDuration = 0.3
        let movement: CGFloat = CGFloat(up ? moveDistance : -moveDistance)
        
        UIView.beginAnimations("animateTextField", context: nil)
        UIView.setAnimationBeginsFromCurrentState(true)
        UIView.setAnimationDuration(moveDuration)
        self.view.frame = self.view.frame.offsetBy(dx: 0, dy: movement)
        UIView.commitAnimations()
    }
    @objc func cancelAction(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func addFunFact(_ sender: Any) {
        if validatePage() {
            return
        }
        let db = Firestore.firestore()
        var newLandmark = false
        var newid = ""
        let idx = String(listOfLandmarks.listOfLandmarks.count + 1)
        newid = "L" + String(repeating: "0", count: 10 - idx.count) + idx

        let formatter = DateFormatter()
        // initially set the format based on your datepicker date / server String
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        let myString = formatter.string(from: Date()) // string purpose I add here
        // convert your string to date
        let yourDate = formatter.date(from: myString)
        //then again set the date format whhich type of output you need
        formatter.dateFormat = "MMM dd, yyyy"
        // again convert your date to string
        let myStringafd = formatter.string(from: yourDate!)
        
        for landmark in listOfLandmarks.listOfLandmarks {
            if landmark.name.lowercased() == landmarkName?.lowercased() {
                print("Error: Name already exists")
                let lid = landmark.id
                
                let fidx = String((funFactDict[lid]?.count)! + 1)
                let fid = lid + "-" + String(repeating: "0", count: 3 - fidx.count) + fidx
                
                db.collection("funFacts").document(fid).setData([
                    "landmarkId": lid,
                    "id": fid,
                    "description": funFactDescription.text,
                    "likes": "0",
                    "dislikes": "0",
                    "verificationFlag": "N",
                    "imageName": fid,
                    "disputeFlag": "N",
                    "submittedBy": Auth.auth().currentUser?.uid ?? "",
                    "dateSubmitted": myStringafd,
                    "imageCaption": imageCaption.text!,
                    "source": sourceTextField.text!
                ]){ err in
                    if let err = err {
                        print("Error writing document: \(err)")
                        self.showAlert(message: "fail")
                    } else {
                        print("Document successfully written!")
                        self.showAlert(message: "success")
                    }
                }
                uploadImage(imageName: fid + ".jpeg")
                return
            }
            else {
                newLandmark = true
            }
        }
        
        if newLandmark == true {
            db.collection("landmarks").document(newid).setData([
                "id": newid,
                "name": landmarkName as Any,
                "address": address as Any,
                "city": city as Any,
                "state": state as Any,
                "zipcode": zipcode as Any,
                "country": country as Any,
                "image": newid + "-001",
                "type": type as Any,
                "latitude": String(self.coordinate.latitude as Double),
                "longitude": String(self.coordinate.longitude as Double)
            ]){ err in
                if let err = err {
                    print("Error writing document: \(err)")
                } else {
                    print("Document successfully written!")
                }
            }
            
            db.collection("funFacts").document(newid + "-001").setData([
                "landmarkId": newid,
                "id": newid + "-001",
                "description": funFactDescription.text,
                "likes": "0",
                "dislikes": "0",
                "verificationFlag": "Y",
                "imageName": newid + "-001",
                "disputeFlag": "N",
                "submittedBy": Auth.auth().currentUser?.uid ?? "",
                "dateSubmitted": myStringafd,
                "imageCaption": imageCaption.text!,
                "source": sourceTextField.text!
            ]){ err in
                if let err = err {
                    print("Error writing document: \(err)")
                    self.showAlert(message: "fail")
                } else {
                    print("Document successfully written!")
                    self.showAlert(message: "success")
                }
            }
            uploadImage(imageName: newid + "-001.jpeg")
        }
    }
    
    func validatePage() -> Bool {
        var errors = false
        let title = "Error"
        var message = ""
        let image = UIImage.fontAwesomeIcon(name: .camera, style: .solid, textColor: .darkGray, size: CGSize(width: landmarkImage.bounds.width, height: landmarkImage.bounds.height), backgroundColor: .clear)
        let imageData = UIImageJPEGRepresentation(image, 1.0)
        let formImageData = UIImageJPEGRepresentation(landmarkImage.image!, 1.0)
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
        if funFactDescription?.text == "Enter the fun fact details. Maximum 300 characters. Please keep the facts relevant and precise." {
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
        let action = UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel,handler: {_ in
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
    
    func uploadImage(imageName: String) {
        let storage = Storage.storage()
        var data = Data()
        // Create a storage reference from our storage service
        let storageRef = storage.reference()
        // Data in memory

        do {
            try landmarkImage.image?.compressImage(300, completion: { (image, compressRatio) in
                print(image.size)
                data = UIImageJPEGRepresentation(image, compressRatio)!
            })
        } catch {
            print("Error")
        }
        
        // Create a reference to the file you want to upload
        let landmarkRef = storageRef.child("images/\(imageName)")
        
        // Upload the file to the path "images/rivers.jpg"
        let uploadTask = landmarkRef.putData(data, metadata: nil) { (metadata, error) in
            guard let metadata = metadata
                else {
                // Uh-oh, an error occurred!
                return
            }
            // Metadata contains file metadata such as size, content-type.
            metadata.contentType = "image/jpeg"
            landmarkRef.putData(data, metadata: metadata)
            // You can also access to download URL after upload.
            landmarkRef.downloadURL { (url, error) in
                guard let downloadURL = url else {
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
        var imageData:Data = UIImageJPEGRepresentation(imageToBeHandled, compressionQuality)!
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
            if let imgData = UIImageJPEGRepresentation(img!, compressionQuality) {
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