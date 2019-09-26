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
import IQKeyboardManagerSwift
import Geofirestore
import CropViewController

class AddNewFactViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate, AlgoliaSearchManagerDelegate, FirestoreManagerDelegate, GeoFirestoreManagerDelegate, CropViewControllerDelegate {
    
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
    @IBOutlet weak var staticImage: UIImageView!
    @IBOutlet weak var chooseImageLabel: UILabel!
    @IBOutlet weak var funFactTitleTextField: UITextField!
    @IBOutlet weak var funFactTitleBtn: UIButton!
    @IBOutlet weak var tagsTextField: UITextField!
    @IBOutlet weak var tagsBtn: UIButton!
    
    var algoliaManager = AlgoliaSearchManager()
    var firestore = FirestoreManager()
    var geoFirestore = GeoFirestoreManager()
    var address: String?
    var landmarkName: String?
    var landmarkID: String?
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
    var mode = Mode.add
    var funFactID = ""
    var landmarkTypeText = ""
    var imageCaptionText = ""
    var funFactTitleText = ""
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
    let imageCaptionPlaceholder = "Enter image caption here. Credits for images go here. (Optional)"
    let funFactDescPlaceholder = "Enter the fun fact details. Maximum 400 characters. Please keep the facts relevant and precise."
    
    var croppingStyle = CropViewCroppingStyle.default
    var image: UIImage?
    var croppedRect = CGRect.zero
    var croppedAngle = 0
    var documentsUrl: URL {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    }
    
    enum Tags: Int {
        case address
        case name
        case type
        case caption
        case image
        case title
        case description
        case tags
        case source
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        if #available(iOS 13.0, *) {
            let navBar = UINavigationBarAppearance()
            navBar.backgroundColor = Colors.systemGreenColor
            navBar.titleTextAttributes = Attributes.navTitleAttribute
            navBar.largeTitleTextAttributes = Attributes.navTitleAttribute
            self.navigationController?.navigationBar.standardAppearance = navBar
            self.navigationController?.navigationBar.scrollEdgeAppearance = navBar
        } else {
            // Fallback on earlier versions
        }
        
        switch mode {
        case .edit:
            navigationItem.title = "Edit Fun Fact"
        case .add, .addNew:
            navigationItem.title = "Add New Fun Fact"
            staticImage.image = UIImage.fontAwesomeIcon(name: .images,
                                                          style: .solidp,
                                                          textColor: .darkGray,
                                                          size: CGSize(width: staticImage.frame.width,
                                                                       height: staticImage.frame.height),
                                                          backgroundColor: .clear)
            landmarkImage.image = UIImage()
            addDashedBorder()
        }
        darkModeSupport()
        algoliaManager.delegate = self
        funFactDescription.keyboardDistanceFromTextField = 200
        tagsTextField.keyboardDistanceFromTextField = 200
        tagsTextField.keyboardType = .twitter
        funFactDescription.keyboardType = .default
        sourceTextField.keyboardType = .URL
        
        autocompleteTableView.translatesAutoresizingMaskIntoConstraints = false
        autocompleteTableView.delegate = self
        autocompleteTableView.dataSource = self
        autocompleteTableView.isScrollEnabled = true
        autocompleteTableView.isHidden = true
        autocompleteTableView.layer.borderWidth = 0.5
        autocompleteTableView.layer.borderColor = UIColor.lightGray.cgColor
        autocompleteTableView.layer.cornerRadius = 5
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
        
        funFactTitleBtn.titleLabel?.font = UIFont.fontAwesome(ofSize: 25, style: .solid)
        funFactTitleBtn.setTitle(String.fontAwesomeIcon(name: .sign), for: .normal)
        
        tagsBtn.titleLabel?.font = UIFont.fontAwesome(ofSize: 25, style: .solid)
        tagsBtn.setTitle(String.fontAwesomeIcon(name: .tags), for: .normal)
        
        tagsTextField.tag = Tags.tags.rawValue
        imageCaption.tag = Tags.caption.rawValue
        funFactDescription.tag = Tags.description.rawValue
        addressTextField?.tag = Tags.address.rawValue
        landmarkNameTextField?.tag = Tags.name.rawValue
        landmarkType.tag = Tags.type.rawValue
        funFactTitleTextField.tag = Tags.title.rawValue
        sourceTextField.tag = Tags.source.rawValue
        landmarkImage.tag = Tags.image.rawValue
        
        pickerData = Constants.landmarkTypes
        landmarkType.delegate = self
        landmarkType.dataSource = self
        funFactDescription.delegate = self
        imageCaption.delegate  = self
        tagsTextField.delegate = self
        addressTextField?.delegate = self
        landmarkNameTextField?.delegate = self
        funFactTitleTextField.delegate = self
        sourceTextField.delegate = self

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

        let mytapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(viewAddressScreen))
        mytapGestureRecognizer.numberOfTapsRequired = 1
        addressTextField?.addGestureRecognizer(mytapGestureRecognizer)
        addressTextField?.isUserInteractionEnabled = true
        
        landmarkImage.layer.cornerRadius = 5

        let imagePickerTapGesture = UITapGestureRecognizer(target: self, action: #selector(viewImagePicker))
        imagePickerTapGesture.numberOfTapsRequired = 1
        landmarkImage?.addGestureRecognizer(imagePickerTapGesture)
        landmarkImage?.isUserInteractionEnabled = true

        imageCaption.layer.borderWidth = 0
        imageCaption.layer.borderColor = UIColor.darkGray.cgColor
        imageCaption.layer.cornerRadius = 5

        imageCaption.text = imageCaptionPlaceholder
        imageCaption.textColor = UIColor.lightGray

        funFactDescription.text = funFactDescPlaceholder
        funFactDescription.textColor = UIColor.lightGray

        funFactDescription.layer.borderWidth = 0
        funFactDescription.layer.borderColor = UIColor.darkGray.cgColor
        funFactDescription.layer.cornerRadius = 5

        sourceTextField.layer.borderWidth = 0
        sourceTextField.layer.borderColor = UIColor.darkGray.cgColor
        sourceTextField.layer.cornerRadius = 5

        submitButton.backgroundColor = Colors.systemGreenColor
        submitButton.accessibilityIdentifier = "submit"
        submitButton.widthAnchor.constraint(equalToConstant: self.view.frame.width - 20).isActive = true
        
    }
    func darkModeSupport() {
        if traitCollection.userInterfaceStyle == .light {
            scrollView.backgroundColor = .white
            contentView.backgroundColor = .white
            addressBtn.setTitleColor(.black, for: .normal)
            landmarkNameBtn.setTitleColor(.black, for: .normal)
            funFactTitleBtn.setTitleColor(.black, for: .normal)
            tagsBtn.setTitleColor(.black, for: .normal)
            sourceBtn.setTitleColor(.black, for: .normal)
            imageCaption.backgroundColor = .white
            funFactDescription.backgroundColor = .white
        } else {
            if #available(iOS 13.0, *) {
                scrollView.backgroundColor = .secondarySystemBackground
                contentView.backgroundColor = .secondarySystemBackground
                imageCaption.backgroundColor = .secondarySystemBackground
                funFactDescription.backgroundColor = .secondarySystemBackground
                addressBtn.setTitleColor(.white, for: .normal)
                landmarkNameBtn.setTitleColor(.white, for: .normal)
                funFactTitleBtn.setTitleColor(.white, for: .normal)
                tagsBtn.setTitleColor(.white, for: .normal)
                sourceBtn.setTitleColor(.white, for: .normal)
            } else {
                scrollView.backgroundColor = .black
                contentView.backgroundColor = .black
                imageCaption.backgroundColor = .black
                funFactDescription.backgroundColor = .black
                addressBtn.setTitleColor(.white, for: .normal)
                landmarkNameBtn.setTitleColor(.white, for: .normal)
                funFactTitleBtn.setTitleColor(.white, for: .normal)
                tagsBtn.setTitleColor(.white, for: .normal)
                sourceBtn.setTitleColor(.white, for: .normal)
            }
        }
    }
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        darkModeSupport()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        // Hide the navigation bar on the this view controller
        navigationController?.isNavigationBarHidden = true
        navigationController?.isNavigationBarHidden = false
        self.tabBarController?.tabBar.isHidden = true
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        // Show the navigation bar on other view controllers
        self.tabBarController?.tabBar.isHidden = false
        navigationController?.navigationBar.prefersLargeTitles = false
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        addressTextField?.text = address
        landmarkNameTextField?.text = landmarkName

        if address == landmarkName && (address != "" && address != nil) {
            algoliaManager.getLandmarkName(from: address ?? "", zipCode: zipcode ?? "") { (name, error) in
                if let error = error {
                    print ("Error getting landmark name from address \(error)")
                } else {
                    self.landmarkNameTextField?.text = name
                    self.addressTextField?.text = self.address
                }
            }
        }
        switch mode {
        case .edit:
            staticImage.isHidden = true
            chooseImageLabel.isHidden = true
            firestore.getLandmark(for: landmarkID ?? "") { (landmark, error) in
                if let error = error {
                    print ("Error getting landmark object \(error)")
                }
                else {
                    self.landmark = landmark!
                    self.landmarkType.selectRow(self.pickerData.firstIndex(of: self.landmark.type)!,
                                                inComponent: 0,
                                                animated: true)
                    self.addressTextField?.text = self.landmark.address.replacingOccurrences(of: " ", with: "") == "" ? self.landmark.name : self.landmark.address
                    self.landmarkNameTextField?.text = self.landmark.name
                    self.firestore.downloadFunFact(for: self.funFactID, completionHandler: { (funFact, error) in
                        if let error = error {
                            print ("Error getting fun fact \(error)")
                        } else {
                            var hashtags = ""
                            if !(funFact?.tags.isEmpty)! {
                                hashtags = "#" + (funFact?.tags.joined(separator: " #"))!
                            }
                            self.funFactDescription.text = funFact?.description
                            self.imageCaption.text = funFact?.imageCaption
                            self.sourceTextField.text = funFact?.source
                            self.funFactTitleTextField.text = funFact?.funFactTitle
                            self.tagsTextField.text = hashtags
                            self.funFactDescription.textColor = self.traitCollection.userInterfaceStyle == .light ? .black : .white
                            self.imageCaption.textColor = self.traitCollection.userInterfaceStyle == .light ? .black : .white
                            self.setupImage()
                        }
                    })
                }
            }
        case .addNew:
            firestore.getLandmark(for: landmarkID ?? "") { (landmark, error) in
                if let error = error {
                    print ("Error getting landmark object \(error)")
                }
                else {
                    self.landmark = landmark!
                    self.landmarkType.selectRow(self.pickerData.firstIndex(of: self.landmark.type)!,
                                                inComponent: 0,
                                                animated: true)
                    self.addressTextField?.text = self.landmark.address.replacingOccurrences(of: " ", with: "") == "" ? self.landmark.name : self.landmark.address
                    self.landmarkNameTextField?.text = self.landmark.name
                }
            }
        case .add:
            loadSavedFields()
            return
        }
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
            UserDefaults.standard.set(self.address, forKey: "address")
            UserDefaults.standard.set(self.landmarkName, forKey: "name")
            UserDefaults.standard.set(self.country, forKey: "country")
            UserDefaults.standard.set(self.city, forKey: "city")
            UserDefaults.standard.set(self.state, forKey: "state")
            UserDefaults.standard.set(self.zipcode, forKey: "zipcode")
            UserDefaults.standard.set(self.coordinate.latitude, forKey: "latitude")
            UserDefaults.standard.set(self.coordinate.longitude, forKey: "longitude")
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
            imag.allowsEditing = false
            self.present(imag, animated: true, completion: nil)
        }
    }

    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        // Local variable inserted by Swift 4.2 migrator.
        let info = convertFromUIImagePickerControllerInfoKeyDictionary(info)
        
        guard let image = (info[convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.originalImage)] as? UIImage) else { return }
        let cropController = CropViewController(croppingStyle: croppingStyle, image: image)
        cropController.delegate = self
        
        self.image = image
        landmarkImage.contentMode = .scaleAspectFill
        
        staticImage.isHidden = true
        chooseImageLabel.isHidden = true
        
        picker.dismiss(animated: true, completion: {
            if #available(iOS 13.0, *) {
                cropController.modalPresentationStyle = .fullScreen
            }
            self.present(cropController, animated: true, completion: nil)
        })
    }

    func cropViewController(_ cropViewController: CropViewController, didCropToImage image: UIImage, withRect cropRect: CGRect, angle: Int) {
        self.croppedRect = cropRect
        self.croppedAngle = angle
        updateImageViewWithImage(image, fromCropViewController: cropViewController)
    }
    
    func cropViewController(_ cropViewController: CropViewController, didCropToCircularImage image: UIImage, withRect cropRect: CGRect, angle: Int) {
        self.croppedRect = cropRect
        self.croppedAngle = angle
        updateImageViewWithImage(image, fromCropViewController: cropViewController)
    }
    
    func cropViewController(_ cropViewController: CropViewController, didFinishCancelled cancelled: Bool) {
        //This code fails on iOS13.
        //cropViewController.dismiss(animated: true)

        let viewController = cropViewController.children.first!
        viewController.modalTransitionStyle = .coverVertical
        viewController.presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
    func updateImageViewWithImage(_ image: UIImage, fromCropViewController cropViewController: CropViewController) {
        if mode == .edit {
            landmarkImage.image = UIImage()
        }
        landmarkImage.image = image
        if let file = save(image: image) {
            print ("Saved \(file)")
        }
        
        self.navigationItem.rightBarButtonItem?.isEnabled = true
        
        if cropViewController.croppingStyle != .circular {
            landmarkImage.isHidden = true
            cropViewController.dismissAnimatedFrom(self, withCroppedImage: image,
                                                   toView: landmarkImage,
                                                   toFrame: CGRect.zero,
                                                   setup: { },
                                                   completion: { self.landmarkImage.isHidden = false })
        }
        else {
            self.landmarkImage.isHidden = false
            cropViewController.dismiss(animated: true, completion: nil)
        }
    }
    
    @objc func cancelAction(_ sender: Any) {
        let alertController = UIAlertController(title: "Cancel",
                                                message: "Are you sure you want to cancel? All information will be lost.",
                                                preferredStyle: .alert)
        let okayAction = UIAlertAction(title: "Ok", style: .default, handler: { (_) in
            self.removeSavedFields()
            self.navigationController?.popViewController(animated: true)
        })
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(okayAction)
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true, completion: nil)
    }
    @IBAction func addFunFact(_ sender: Any) {
        if self.validatePage() {
            return
        }
        if AppDataSingleton.appDataSharedInstance.userProfile.roles.contains(UserRole.admin) ||
            AppDataSingleton.appDataSharedInstance.userProfile.roles.contains(UserRole.editor) {
            verificationFlag = "Y"
        }
        let alertController = UIAlertController(title: "Submission",
                                                message: "Are you sure you want to submit?",
                                                preferredStyle: .alert)
        
        let okayAction = UIAlertAction(title: "Ok", style: .default, handler: { (_) in
            let db = Firestore.firestore()
            
            var tempLandmarkID = ""
            tempLandmarkID = (self.landmarkID == "" || self.landmarkID == nil) ?
                db.collection("landmarks").document().documentID : self.landmarkID ?? ""
            self.city = (self.city == "" || self.city == nil) ? self.landmark.city : self.city
            self.address = (self.address == "" || self.address == nil) ? self.landmark.address : self.address
            self.landmarkName = (self.landmarkName == "" || self.landmarkName == nil) ? self.landmark.name : self.landmarkName
            if self.mode == .edit || self.mode == .add {
                self.landmarkName = self.landmarkNameTextField?.text
            }
            self.type = (self.type == "" || self.type == nil) ? self.landmark.type : self.type
            self.state = (self.state == "" || self.state == nil) ? self.landmark.state : self.state
            self.zipcode = (self.zipcode == "" || self.zipcode == nil) ? self.landmark.zipcode : self.zipcode
            self.country = (self.country == "" || self.country == nil) ? self.landmark.country : self.country
            self.numOfFunFacts = (self.mode != .edit) ? self.numOfFunFacts: self.landmark.numOfFunFacts
            self.landLikes = (self.mode != .edit) ? self.landLikes: self.landmark.likes
            self.landDislikes = (self.mode != .edit) ? self.landDislikes: self.landmark.dislikes
            self.coordinate = (self.coordinate.latitude == 0) ?
                CLLocationCoordinate2D(latitude: self.landmark.coordinates.latitude,
                                       longitude: self.landmark.coordinates.longitude) : self.coordinate
            
            self.algoliaManager.getLandmarkID(from: self.address ?? "", zipCode: self.zipcode ?? "") { (id, numOfFunFacts, likes, dislikes, error) in
                if let error = error {
                    print ("Algolia error getting landmark ID \(error)")
                } else {
                    if id != "" {
                        tempLandmarkID = id!
                        self.numOfFunFacts = numOfFunFacts!
                        self.likes = likes!
                        self.dislikes = dislikes!
                    }
                    //Upload Landmark details - merge if landmark already exists
                    let ffID = (self.mode != .edit) ? db.collection("funFacts").document().documentID : self.funFactID
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
                            // Upload GeoFirestore related data
                            self.geoFirestore
                                .addGeoFirestoreData(for: tempLandmarkID,
                                                     coordinates: GeoPoint(latitude: self.coordinate.latitude as Double,
                                                                           longitude: self.coordinate.longitude as Double),
                                                     completion: { (error) in
                                                        if let error = error {
                                                            print ("Error writing Geofirestore document: \(error)")
                                                        } else {
                                                            print("GeoFirestore data successfully written!")
                                                        }
                                })
                            //Upload fun fact details
                            var imageCaptionText = ""
                            if self.imageCaption.text != self.imageCaptionPlaceholder {
                                imageCaptionText = self.imageCaption.text
                            }
                            var hashtags = self.tagsTextField.text?.replacingOccurrences(of: " ", with: "").components(separatedBy: "#") ?? []
                            hashtags.remove(at: 0)
                            let funFact = FunFact(landmarkId: tempLandmarkID,
                                                  landmarkName: self.landmarkName ?? "",
                                                  id: ffID,
                                                  description: self.funFactDescription.text,
                                                  funFactTitle: self.funFactTitleTextField.text ?? "",
                                                  likes: self.likes,
                                                  dislikes: self.dislikes,
                                                  verificationFlag: self.verificationFlag,
                                                  image: ffID,
                                                  imageCaption: imageCaptionText,
                                                  disputeFlag: self.disputeFlag,
                                                  submittedBy: Auth.auth().currentUser?.uid ?? "",
                                                  dateSubmitted: Timestamp(date: Date()),
                                                  source: self.sourceTextField.text ?? "",
                                                  tags: hashtags,
                                                  approvalCount: self.approvalCount,
                                                  rejectionCount: self.rejectionCount,
                                                  approvalUsers: self.approvalUsers,
                                                  rejectionUsers: self.rejectionUsers,
                                                  rejectionReason: self.rejectionReason)
                            self.firestore.addFunFact(funFact: funFact, completion: { (error) in
                                if let error = error {
                                    print ("Error writing document: \(error)")
                                    let alert = Utils.showAlert(status: .failure, message: ErrorMessages.funFactUploadError)
                                    self.present(alert, animated: true) {
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
                                            guard self?.presentedViewController == alert else { return }
                                            self?.dismiss(animated: true, completion: nil)
                                        }
                                    }
                                } else {
                                    print("Document successfully written!")
                                    
                                    self.firestore.addHashtags(funFactID: ffID, hashtags: hashtags)
                                    self.firestore.addUserSubmitted(funFact: funFact, userID: Auth.auth().currentUser?.uid ?? "")
                                    self.firestore.uploadImage(imageName: ffID + ".jpeg",
                                                               image: self.landmarkImage.image ?? UIImage(),
                                                               type: ImageType.funFact,
                                                               completion: { (url, error) in
                                                                if let error = error {
                                                                    print ("Error uploading image \(error)")
                                                                } else {
                                                                    print ("Image uploaded successfully")
                                                                    if CacheManager.shared.checkIfImageExists(imageName: ffID + ".jpeg") {
                                                                        CacheManager.shared.replaceImage(imageName: ffID + ".jpeg", image: self.landmarkImage.image ?? UIImage())
                                                                    }
                                                                }
                                    })
                                    self.removeSavedFields()
                                    let alert = Utils.showAlert(status: .success, message: ErrorMessages.funFactUploadSuccess)
                                    self.present(alert, animated: true) {
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
                                            guard self?.presentedViewController == alert else { return }
                                            self?.dismiss(animated: true, completion: nil)
                                            self!.navigationController?.popViewController(animated: true)
                                        }
                                    }
                                }
                            })
                        }
                    })
                }
            }
        })
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(okayAction)
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true, completion: nil)
        return
    }
    func validatePage() -> Bool {
        var errors = false
        let title = "Error"
        var message = ""
        if (addressTextField?.text?.isEmpty)! {
            errors = true
            message += "Please enter a street address"
            Utils.alertWithTitle(title: title,
                                 message: message,
                                 viewController: self,
                                 toFocus: self.addressTextField!,
                                 type: .textfield)
        }
        if (landmarkNameTextField?.text?.isEmpty)! {
            errors = true
            message += "Please enter a landmark name"
            Utils.alertWithTitle(title: title,
                                 message: message,
                                 viewController: self,
                                 toFocus: self.landmarkNameTextField!,
                                 type: .textfield)
        }
        if funFactDescription?.text == funFactDescPlaceholder {
            errors = true
            message += "Please enter a fun fact description"
            Utils.alertWithTitle(title: title,
                                 message: message,
                                 viewController: self,
                                 toFocus: self.funFactDescription!,
                                 type: .textview)
        }
        if (sourceTextField?.text?.isEmpty)! || !(sourceTextField.text?.isValidURL)! {
            errors = true
            message += "Please enter a valid source URL"
            Utils.alertWithTitle(title: title,
                                 message: message,
                                 viewController: self,
                                 toFocus: self.sourceTextField!,
                                 type: .textfield)
        }
        if !staticImage.isHidden  {
            errors = true
            message += "Please select an image for your fun fact"
            Utils.alertWithTitle(title: title,
                                 message: message,
                                 viewController: self,
                                 toFocus: self.landmarkImage!,
                                 type: .imageview)
        }
        if ((type ?? "").isEmpty || type == "--- Select landmark type ---") && mode != .edit {
            errors = true
            message += "Please enter a valid landmark type"
            Utils.alertWithTitle(title: title,
                                 message: message,
                                 viewController: self,
                                 toFocus: self.landmarkType!,
                                 type: .pickerview)
        }
        if (type == "--- Select landmark type ---") && mode == .edit {
            errors = true
            message += "Please enter a valid landmark type"
            Utils.alertWithTitle(title: title,
                                 message: message,
                                 viewController: self,
                                 toFocus: self.landmarkType!,
                                 type: .pickerview)
        }

        if funFactDescription.text.count > 400 {
            errors = true
            message += "Please make sure that the fun fact description is limited to 400 characters"
            Utils.alertWithTitle(title: title,
                                 message: message,
                                 viewController: self,
                                 toFocus: self.funFactDescription!,
                                 type: .textview)
        }
        return errors
    }
    func alertWithTitle(title: String!, message: String, viewController: UIViewController, toFocus: Any, type: AlertType) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK",
                                   style: UIAlertAction.Style.cancel,
                                   handler: {_ in
            switch(type) {
            case .textfield:
                (toFocus as! UITextField).becomeFirstResponder()
            case .textview:
                (toFocus as! UITextView).becomeFirstResponder()
            case .imageview:
                (toFocus as! UIImageView).becomeFirstResponder()
            case .pickerview:
                (toFocus as! UIPickerView).becomeFirstResponder()
            default:
                print("default")
            }
    
        })
        alert.addAction(action)
        viewController.present(alert, animated: true, completion: nil)
    }
    
    @objc func dismissAlert() {
        popup.dismiss(animated: true)
        navigationController?.popViewController(animated: true)
    }
    func setupImage() {
        if self.image != nil {
            return
        }
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
            gsReference.downloadURL { (url, error) in
                if let error = error {
                    print ("Error getting URL \(error)")
                } else {
                    self.landmarkImage.layer.cornerRadius = 5
                    self.landmarkImage.sd_setImage(with: url, placeholderImage: UIImage())
                }
            }
        }
    }
    
    func removeSavedFields() {
        delete(fileName: "tempImage")
        UserDefaults.standard.removeObject(forKey: "address")
        UserDefaults.standard.removeObject(forKey: "name")
        UserDefaults.standard.removeObject(forKey: "type")
        UserDefaults.standard.removeObject(forKey: "caption")
        UserDefaults.standard.removeObject(forKey: "description")
        UserDefaults.standard.removeObject(forKey: "title")
        UserDefaults.standard.removeObject(forKey: "source")
        UserDefaults.standard.removeObject(forKey: "tags")
        UserDefaults.standard.removeObject(forKey: "country")
        UserDefaults.standard.removeObject(forKey: "city")
        UserDefaults.standard.removeObject(forKey: "state")
        UserDefaults.standard.removeObject(forKey: "zipcode")
        UserDefaults.standard.removeObject(forKey: "latitude")
        UserDefaults.standard.removeObject(forKey: "longitude")
    }
    func loadSavedFields() {
        if UserDefaults.standard.object(forKey: "address") != nil {
            address = UserDefaults.standard.string(forKey: "address")
            addressTextField?.text = UserDefaults.standard.string(forKey: "address")
        }
        if UserDefaults.standard.object(forKey: "country") != nil {
            country = UserDefaults.standard.string(forKey: "country")
        }
        if UserDefaults.standard.object(forKey: "city") != nil {
            city = UserDefaults.standard.string(forKey: "city")
        }
        if UserDefaults.standard.object(forKey: "state") != nil {
            state = UserDefaults.standard.string(forKey: "state")
        }
        if UserDefaults.standard.object(forKey: "zipcode") != nil {
            zipcode = UserDefaults.standard.string(forKey: "zipcode")
        }
        if UserDefaults.standard.object(forKey: "latitude") != nil &&  UserDefaults.standard.object(forKey: "longitude") != nil {
            coordinate = CLLocationCoordinate2D(latitude: UserDefaults.standard.object(forKey: "latitude") as! CLLocationDegrees,
                                                longitude: UserDefaults.standard.object(forKey: "longitude") as! CLLocationDegrees)
        }
        if UserDefaults.standard.object(forKey: "name") != nil {
            landmarkNameTextField?.text = UserDefaults.standard.string(forKey: "name")
            landmarkName = UserDefaults.standard.string(forKey: "name")
        }
        if UserDefaults.standard.object(forKey: "caption") != nil {
            imageCaption?.textColor = traitCollection.userInterfaceStyle == .light ? .black : .white
            imageCaption?.text = UserDefaults.standard.string(forKey: "caption")
        }
        if UserDefaults.standard.object(forKey: "description") != nil {
            funFactDescription?.textColor = .black
            funFactDescription?.text = UserDefaults.standard.string(forKey: "description")
        }
        if UserDefaults.standard.object(forKey: "title") != nil {
            funFactTitleTextField?.text = UserDefaults.standard.string(forKey: "title")
        }
        if UserDefaults.standard.object(forKey: "tags") != nil {
            tagsTextField?.text = UserDefaults.standard.string(forKey: "tags")
        }
        if UserDefaults.standard.object(forKey: "source") != nil {
            sourceTextField?.text = UserDefaults.standard.string(forKey: "source")
        }
        if let image = load(fileName: "tempImage") {
            landmarkImage.image = image
            landmarkImage.layer.cornerRadius = 5
            staticImage.isHidden = true
            chooseImageLabel.isHidden = true
        }
        if UserDefaults.standard.object(forKey: "type") != nil {
            landmarkType.selectRow(self.pickerData.firstIndex(of: UserDefaults.standard.string(forKey: "type")!)!,
                                   inComponent: 0,
                                   animated: true)
            type = UserDefaults.standard.string(forKey: "type")
        }
    }
    
    func addDashedBorder() {
        let color = UIColor.gray.cgColor
        let shapeLayer:CAShapeLayer = CAShapeLayer()
        let frameSize = landmarkImage.frame.size
        let shapeRect = CGRect(x: 0, y: 0, width: frameSize.width, height: frameSize.height)
        
        shapeLayer.bounds = shapeRect
        shapeLayer.position = CGPoint(x: frameSize.width/2, y: frameSize.height/2)
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.strokeColor = color
        shapeLayer.lineWidth = 2
        shapeLayer.lineJoin = CAShapeLayerLineJoin.round
        shapeLayer.lineDashPattern = [6,3]
        shapeLayer.path = UIBezierPath(roundedRect: shapeRect, cornerRadius: 5).cgPath
        
        landmarkImage.layer.addSublayer(shapeLayer)
    }
    func save(image: UIImage) -> String? {
        let fileName = "tempImage"
        let fileURL = documentsUrl.appendingPathComponent(fileName)
        if let imageData = image.jpegData(compressionQuality: 1.0) {
            try? imageData.write(to: fileURL, options: .atomic)
            return fileName // ----> Save fileName
        }
        print("Error saving image")
        return nil
    }
    func load(fileName: String) -> UIImage? {
        let fileURL = documentsUrl.appendingPathComponent(fileName)
        do {
            let imageData = try Data(contentsOf: fileURL)
            return UIImage(data: imageData)
        } catch {
            print("Error loading image : \(error)")
        }
        return nil
    }
    func delete(fileName: String) {
        let fileURL = documentsUrl.appendingPathComponent(fileName)
        try? FileManager.default.removeItem(at: fileURL)
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
        let selectedCell = tableView.cellForRow(at: indexPath)! as! HashtagCell
        let tempStr = tagsTextField.text?
            .components(separatedBy: " ")
            .filter { !$0.isEmpty }
            .joined(separator: " ")
            .components(separatedBy: " ")
            .dropLast()
            .joined(separator: " ")
        
        tagsTextField.text = tempStr! + selectedCell.hashtag.text!
        autocompleteTableView.isHidden = true
        tagsTextField.text = tagsTextField.text! + " "
    }
    func searchAutocompleteEntriesWithSubstring(substring: String) {
        autocompleteHashtags.removeAll(keepingCapacity: true)
        algoliaManager.getHashtags(searchText: substring) { (hashtags) in
            self.autocompleteHashtags = hashtags
            self.autocompleteTableView.reloadData()
        }
    }
}
