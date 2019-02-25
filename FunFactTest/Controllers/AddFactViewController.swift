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

class AddNewFactViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate,
UITextViewDelegate, UITextFieldDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, AlgoliaSearchManagerDelegate, FirestoreManagerDelegate {
    
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
    
    var algoliaManager = AlgoliaSearchManager()
    var firestore = FirestoreManager()
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
    var autocompleteHashtags = [SearchHashtag]()
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
    var landLikes = 0
    var landDislikes = 0
    var numOfFunFacts = 0
    var approvalCount = 0
    var approvalUsers = [String]()
    var rejectionCount = 0
    var rejectionUsers = [String]()
    var rejectionReason = [String]()
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
                            image: "",
                            numOfFunFacts: 0,
                            likes: 0,
                            dislikes: 0)

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.tintColor = .darkGray

        algoliaManager.delegate = self
        funFactDescription.keyboardDistanceFromTextField = 200
        autocompleteTableView.translatesAutoresizingMaskIntoConstraints = false
        autocompleteTableView.delegate = self
        autocompleteTableView.dataSource = self
        autocompleteTableView.isScrollEnabled = true
        autocompleteTableView.isHidden = true
        contentView.bringSubviewToFront(autocompleteTableView)

        scrollView.scrollIndicatorInsets = UIEdgeInsets(top: 30, left: 0, bottom: 0, right: 2)
        scrollView.autoresizingMask = UIView.AutoresizingMask(rawValue:
            UIView.AutoresizingMask.RawValue(UInt8(UIView.AutoresizingMask.flexibleWidth.rawValue)
                | UInt8(UIView.AutoresizingMask.flexibleHeight.rawValue)))
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

        submitButton.backgroundColor = Colors.seagreenColor

        submitButton.widthAnchor.constraint(equalToConstant: self.view.frame.width - 20).isActive = true

        if mode == "edit" {
            navigationItem.title = "Edit Fun Fact"
            getLandmarkObject(landmarkID: landmarkID)
            self.landmarkType.selectRow(self.pickerData.firstIndex(of: self.landmark.type)!,
                                        inComponent: 0,
                                        animated: true)
            self.addressTextField?.text = landmark.address
            funFactDescription.text = funFactDesc
            imageCaption.text = imageCaptionText
            sourceTextField.text = source
            funFactDescription.textColor = UIColor.black
            imageCaption.textColor = UIColor.black
            setupImage()
        } else {
            navigationItem.title = "Add A New Fun Fact"
            landmarkImage.image = UIImage.fontAwesomeIcon(name: .fileImage,
                                                          style: .solidp,
                                                          textColor: .gray,
                                                          size: CGSize(width: landmarkImage.frame.width,
                                                                       height: landmarkImage.frame.height),
                                                          backgroundColor: .clear)
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        // Hide the navigation bar on the this view controller
        self.tabBarController?.tabBar.isHidden = true
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        // Show the navigation bar on other view controllers
        self.tabBarController?.tabBar.isHidden = false
    }
    func documentsDidUpdate() {
        print ("firestore connection made")
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let backItem = UIBarButtonItem()
        backItem.title = ""
        navigationItem.backBarButtonItem = backItem

        let destinationAddFactVC = segue.destination as? AddressViewController
        destinationAddFactVC?.callback = { addDet in
            self.landmarkNameTextField?.text = addDet.landmarkName
            self.addressTextField?.text =
                (addDet.address == nil || addDet.address?.replacingOccurrences(of: " ",
                                                                               with: "") == "") ?
                    addDet.landmarkName : addDet.address
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
            self.firestore.checkIfLandmarkExists(address: address, completionHandler:
                { (id, numOfFunFacts, landLikes, landDislikes) in
                self.landmarkID = id
                self.numOfFunFacts = numOfFunFacts
                self.landLikes = landLikes
                self.landDislikes = landDislikes
            })
        }
    }
    func documentsDidDownload() {
        print ("hashatag downloaded")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @objc func viewAddressScreen(recognizer: UITapGestureRecognizer) {
        performSegue(withIdentifier: "addressDetail", sender: nil)
    }
    @objc func viewImagePicker(recognizer: UITapGestureRecognizer) {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.photoLibrary) {
            let imag = UIImagePickerController()
            imag.delegate = self
            imag.sourceType = UIImagePickerController.SourceType.photoLibrary
            //imag.mediaTypes = [kUTTypeImage];
            imag.allowsEditing = false
            self.present(imag, animated: true, completion: nil)
        }
    }

    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        // Local variable inserted by Swift 4.2 migrator.
        let info = convertFromUIImagePickerControllerInfoKeyDictionary(info)

        guard let selectedImage = info[convertFromUIImagePickerControllerInfoKey(
            UIImagePickerController.InfoKey.originalImage)]
            as? UIImage else { return }
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
    func pickerView(_ pickerView: UIPickerView,
                    viewForRow row: Int,
                    forComponent component: Int,
                    reusing view: UIView?) -> UIView {
        guard var label = view as? UILabel? else { return UILabel() }
        if label == nil {
            label = UILabel()
        }

        let data = pickerData[row]
        let title = NSAttributedString(string: data,
                                       attributes: [NSAttributedString.Key.font: UIFont(name: "Avenir Next",
                                                                                        size: 14)!])
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
            } else if textView.tag == 1 {
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
        if self.validatePage() {
            return
        }
        let alertController = UIAlertController(title: "Submission",
                                                message: "Are you sure you want to submit?",
                                                preferredStyle: .alert)
        
        let okayAction = UIAlertAction(title: "Ok", style: .default, handler: { (_) in
            let db = Firestore.firestore()
            var tempLandmarkID = ""
            tempLandmarkID = (self.landmarkID == "") ?
                db.collection("landmarks").document().documentID : self.landmarkID
            self.city = (self.city == "" || self.city == nil) ? self.landmark.city : self.city
            self.address = (self.address == "" || self.address == nil) ? self.landmark.address : self.address
            self.state = (self.state == "" || self.state == nil) ? self.landmark.state : self.state
            self.zipcode = (self.zipcode == "" || self.zipcode == nil) ? self.landmark.zipcode : self.zipcode
            self.country = (self.country == "" || self.country == nil) ? self.landmark.country : self.country
            self.numOfFunFacts = (self.mode != "edit") ? self.numOfFunFacts: self.landmark.numOfFunFacts
            self.landLikes = (self.mode != "edit") ? self.landLikes: self.landmark.likes
            self.landDislikes = (self.mode != "edit") ? self.landDislikes: self.landmark.dislikes
            self.coordinate = (self.coordinate.latitude == 0) ?
                CLLocationCoordinate2D(latitude: self.landmark.coordinates.latitude,
                                       longitude: self.landmark.coordinates.longitude) : self.coordinate
            //Upload Landmark details - merge if landmark already exists
            let ffID = (self.mode != "edit") ? db.collection("funFacts").document().documentID : self.funFactID
            let landmark = Landmark(id: tempLandmarkID,
                                    name: self.landmarkName ?? "",
                                    address: self.address ?? "",
                                    city: self.city ?? "",
                                    state: self.state ?? "",
                                    zipcode: self.zipcode ?? "",
                                    country: self.country ?? "",
                                    type: self.type ?? "",
                                    coordinates: GeoPoint(latitude: self.coordinate.latitude as Double,
                                                          longitude: self.coordinate.longitude as Double),
                                    image: ffID,
                                    numOfFunFacts: self.numOfFunFacts,
                                    likes: self.landLikes,
                                    dislikes: self.landDislikes)
            self.firestore.addLandmark(landmark: landmark, completion: { (error) in
                if let error = error {
                    print ("Error writing document: \(error)")
                } else {
                    print("Document successfully written!")
                }
            })
            
            //Upload fun fact details
            let funFact = FunFact(landmarkId: tempLandmarkID,
                                  id: ffID,
                                  description: self.funFactDescription.text,
                                  likes: self.likes,
                                  dislikes: self.dislikes,
                                  verificationFlag: self.verificationFlag,
                                  image: ffID,
                                  imageCaption: self.imageCaption.text,
                                  disputeFlag: self.disputeFlag,
                                  submittedBy: Auth.auth().currentUser?.uid ?? "",
                                  dateSubmitted: Timestamp(date: Date()),
                                  source: self.sourceTextField.text ?? "",
                                  tags: self.funFactDescription.text.hashtags(),
                                  approvalCount: self.approvalCount,
                                  rejectionCount: self.rejectionCount,
                                  approvalUsers: self.approvalUsers,
                                  rejectionUsers: self.rejectionUsers,
                                  rejectionReason: self.rejectionReason)
            self.firestore.addFunFact(funFact: funFact, completion: { (error) in
                if let error = error {
                    print ("Error writing document: \(error)")
                } else {
                    print("Document successfully written!")
                }
            })
            self.firestore.uploadImage(imageName: ffID + ".jpeg", image: self.landmarkImage.image ?? UIImage())
            self.firestore.addHashtags(funFactID: ffID, hashtags: self.funFactDescription.text.hashtags())
            self.firestore.addUserSubmitted(funFactID: ffID, userID: Auth.auth().currentUser?.uid ?? "")
        })
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(okayAction)
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true, completion: nil)
        return
    }
    func getLandmarkObject(landmarkID: String) {
        for landmark in AppDataSingleton.appDataSharedInstance.listOfLandmarks.listOfLandmarks
            where landmark.id == landmarkID {
            self.landmark = landmark
        }
    }
    func validatePage() -> Bool {
        var errors = false
        let title = "Error"
        var message = ""
        let image = UIImage.fontAwesomeIcon(name: .fileImage,
                                            style: .solidp,
                                            textColor: .darkGray,
                                            size: CGSize(width: landmarkImage.bounds.width,
                                                         height: landmarkImage.bounds.height),
                                            backgroundColor: .clear)
        let imageData = image.jpegData(compressionQuality: 1.0)
        let formImageData = landmarkImage.image!.jpegData(compressionQuality: 1.0)
        if (addressTextField?.text?.isEmpty)! {
            errors = true
            message += "Please enter a street address"
            Utils.alertWithTitle(title: title,
                                 message: message,
                                 viewController: self,
                                 toFocus: self.addressTextField!,
                                 type: "textfield")
        }
        if (landmarkNameTextField?.text?.isEmpty)! {
            errors = true
            message += "Please enter a landmark name"
            Utils.alertWithTitle(title: title,
                                 message: message,
                                 viewController: self,
                                 toFocus: self.landmarkNameTextField!,
                                 type: "textfield")
        }
        if funFactDescription?.text == "Enter the fun fact details. Maximum 300 characters. Please keep the facts relevant and precise. Make sure to enter #hashtags to make your facts searchable." {
            errors = true
            message += "Please enter a fun fact description"
            Utils.alertWithTitle(title: title,
                                 message: message,
                                 viewController: self,
                                 toFocus: self.funFactDescription!,
                                 type: "textview")
        }
        if (sourceTextField?.text?.isEmpty)! {
            errors = true
            message += "Please enter a valid source"
            Utils.alertWithTitle(title: title,
                                 message: message,
                                 viewController: self,
                                 toFocus: self.sourceTextField!,
                                 type: "textfield")
        }
        if imageData == formImageData  {
            errors = true
            message += "Please select an image for your fun fact"
            Utils.alertWithTitle(title: title,
                                 message: message,
                                 viewController: self,
                                 toFocus: self.landmarkImage!,
                                 type: "imageview")
        }
        if (type ?? "").isEmpty || type == "--- Select landmark type ---" {
            errors = true
            message += "Please enter a valid landmark type"
            Utils.alertWithTitle(title: title,
                                 message: message,
                                 viewController: self,
                                 toFocus: self.landmarkType!,
                                 type: "pickerview")
        }
        return errors
    }
    func alertWithTitle(title: String!, message: String, viewController: UIViewController, toFocus: Any, type: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK",
                                   style: UIAlertAction.Style.cancel,
                                   handler: {_ in
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
        viewController.present(alert, animated: true, completion: nil)
    }
    func showAlert(message: String) {
        if message == "success" {
            popup = UIAlertController(title: "Success",
                                      message: "Fun Fact uploaded successfully!",
                                      preferredStyle: .alert)
        }
        if message == "fail" {
            popup = UIAlertController(title: "Error",
                                      message: "Error while uploading Fun Fact",
                                      preferredStyle: .alert)
        }

        self.present(popup, animated: true, completion: nil)
        Timer.scheduledTimer(timeInterval: 2.0,
                             target: self,
                             selector: #selector(self.dismissAlert),
                             userInfo: nil,
                             repeats: false)
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
}

extension String {
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
fileprivate func convertFromUIImagePickerControllerInfoKeyDictionary(
    _ input: [UIImagePickerController.InfoKey: Any]) -> [String: Any] {
	return Dictionary(uniqueKeysWithValues: input.map {key, value in (key.rawValue, value)})
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKey(
    _ input: UIImagePickerController.InfoKey) -> String {
	return input.rawValue
}

extension AddNewFactViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return autocompleteHashtags.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? HashtagCell
        let index = indexPath.row as Int
        let name = "#\(autocompleteHashtags[index].nameHighlighted ?? "")"
        let count = "\(autocompleteHashtags[index].count ?? 0) posts"
        cell?.hashtag?.highlightedText = name
        cell?.count?.text = count
        return cell!
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedCell = tableView.cellForRow(at: indexPath)! as! HashtagCell // swiftlint:disable:this force_cast
        let tempStr = self.funFactDescription.text.components(separatedBy: "#").dropLast().joined(separator: "#")

        self.funFactDescription.text = tempStr + selectedCell.hashtag.text!
        autocompleteTableView.isHidden = true
    }
    func searchAutocompleteEntriesWithSubstring(substring: String) {
        autocompleteHashtags.removeAll(keepingCapacity: true)
        algoliaManager.getHashtags(searchText: substring) { (hashtags) in
            self.autocompleteHashtags = hashtags
            self.autocompleteTableView.reloadData()
        }
    }
}
