//
//  EditProfileViewController.swift
//  FunFactTest
//
//  Created by Rushi Dolas on 2/25/19.
//  Copyright © 2019 Rushi Dolas. All rights reserved.
//

import UIKit
import FirebaseAuth
import CropViewController

class EditProfileViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate, FirestoreManagerDelegate, CropViewControllerDelegate {
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var fullNameButton: UIButton!
    @IBOutlet weak var fullNameTextField: UITextField!
    @IBOutlet weak var userNameButton: UIButton!
    @IBOutlet weak var userNameTextField: UITextField!
    @IBOutlet weak var cityButton: UIButton!
    @IBOutlet weak var cityTextField: UITextField!
    @IBOutlet weak var countryButton: UIButton!
    @IBOutlet weak var countryTextField: UITextField!
    @IBOutlet weak var submitButton: CustomButton!
    @IBOutlet weak var countryPicker: UIPickerView!
    @IBOutlet weak var doneButton: UIButton!
    
    var fullName: String?
    var userName: String?
    var photoURL: String?
    var city: String?
    var country: String?
    var countries: [String] = {
        var arrayOfCountries: [String] = ["United States"]
        for code in NSLocale.isoCountryCodes as [String] {
            let id = NSLocale.localeIdentifier(fromComponents: [NSLocale.Key.countryCode.rawValue: code])
            let name = NSLocale(localeIdentifier: "en_US").displayName(forKey: NSLocale.Key.identifier, value: id) ?? "Country not found for code: \(code)"
            arrayOfCountries.append(name)
        }
        return arrayOfCountries
    }()
    var firestore = FirestoreManager()
    var popup = UIAlertController()
    var selectedImage: UIImage?
    var croppingStyle = CropViewCroppingStyle.circular
    var image: UIImage?
    var croppedRect = CGRect.zero
    var croppedAngle = 0
    
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
        darkModeSupport()
        firestore.delegate = self
        navigationItem.title = "Edit Profile"
        
        countryPicker.delegate = self
        countryPicker.dataSource = self
        countryPicker.isHidden = true
        doneButton.isHidden = true
        
        profileImageView.layer.cornerRadius = profileImageView.frame.height/2
        profileImageView.layer.borderWidth = 0.5
        profileImageView.layer.borderColor = UIColor.gray.cgColor
        
        fullNameButton.titleLabel?.font = UIFont.fontAwesome(ofSize: 25, style: .solid)
        fullNameButton.setTitle(String.fontAwesomeIcon(name: .idCard), for: .normal)
        
        userNameButton.titleLabel?.font = UIFont.fontAwesome(ofSize: 25, style: .solid)
        userNameButton.setTitle(String.fontAwesomeIcon(name: .userCircle), for: .normal)
        
        cityButton.titleLabel?.font = UIFont.fontAwesome(ofSize: 25, style: .solid)
        cityButton.setTitle(String.fontAwesomeIcon(name: .city), for: .normal)
        
        countryButton.titleLabel?.font = UIFont.fontAwesome(ofSize: 25, style: .solid)
        countryButton.setTitle(String.fontAwesomeIcon(name: .globeAmericas), for: .normal)

        let mytapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(showCountryPicker))
        mytapGestureRecognizer.numberOfTapsRequired = 1
        countryTextField.addGestureRecognizer(mytapGestureRecognizer)
        
        submitButton.cornerRadius = 25
        submitButton.layer.backgroundColor = Colors.systemGreenColor.cgColor
        
        let imagePickerTapGesture = UITapGestureRecognizer(target: self, action: #selector(viewImagePicker))
        imagePickerTapGesture.numberOfTapsRequired = 1
        profileImageView.addGestureRecognizer(imagePickerTapGesture)
        profileImageView.isUserInteractionEnabled = true
    }
    func darkModeSupport () {
        if traitCollection.userInterfaceStyle == .light {
            view.backgroundColor = .white
            fullNameButton.setTitleColor(.black, for: .normal)
            userNameButton.setTitleColor(.black, for: .normal)
            cityButton.setTitleColor(.black, for: .normal)
            countryButton.setTitleColor(.black, for: .normal)
        } else {
            fullNameButton.setTitleColor(.white, for: .normal)
            userNameButton.setTitleColor(.white, for: .normal)
            cityButton.setTitleColor(.white, for: .normal)
            countryButton.setTitleColor(.white, for: .normal)
            if #available(iOS 13.0, *) {
                view.backgroundColor = .secondarySystemBackground
            } else {
                view.backgroundColor = .black
            }
        }
    }
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        darkModeSupport()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fullNameTextField.text = fullName
        userNameTextField.text = userName
        cityTextField.text = city
        countryTextField.text = country
        
        if selectedImage != nil {
            profileImageView.image = selectedImage
        } else {
            let photoUrl = URL(string: photoURL ?? "")
            if photoUrl == URL(string: "") {
                profileImageView.image = UIImage
                    .fontAwesomeIcon(
                        name: .user,
                        style: .solid,
                        textColor: .black,
                        size: CGSize(width: 100, height: 100))
            }
            else {
                let data = try? Data(contentsOf: photoUrl!)
                if data == nil {
                    profileImageView.image = UIImage
                        .fontAwesomeIcon(name: .user,
                                         style: .solid,
                                         textColor: .darkGray,
                                         size: CGSize(width: 100, height: 100))
                } else {
                    if self.image == nil {
                        profileImageView.image = UIImage(data: data!)
                    }
                }
            }
        }
    }
    func documentsDidUpdate() {
        
    }
    
    @objc func showCountryPicker(recognizer: UITapGestureRecognizer) {
        countryPicker.isHidden = false
        doneButton.isHidden = false
        UIView.animate(withDuration: 0.5, animations: {
            self.submitButton.transform = CGAffineTransform(translationX: 0, y: 140)
        }, completion: nil)
    }
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return countries.count
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return countries[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        countryTextField.text = countries[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        var label = view as! UILabel?
        if label == nil {
            label = UILabel()
        }
        
        let data = countries[row]
        let title = NSAttributedString(string: data, attributes: [NSAttributedString.Key.font: UIFont(name: Fonts.regularFont, size: 14)!])
        label?.attributedText = title
        label?.textAlignment = .center
        return label!
    }
    
    @IBAction func hideCountryPicker(_ sender: Any) {
        countryPicker.isHidden = true
        doneButton.isHidden = true
        UIView.animate(withDuration: 0.5, animations: {
            self.submitButton.transform = CGAffineTransform(translationX: 0, y: 0)
        }, completion: nil)
    }
    
    @IBAction func submitAction(_ sender: Any) {
        self.firestore.uploadImage(imageName: "\(Auth.auth().currentUser?.uid ?? "").jpeg",
                                   image: self.profileImageView.image ?? UIImage(),
                                   type: ImageType.profile,
                                   completion: { (url, error) in
                                    if let error = error {
                                        print ("Error uploading image \(error)")
                                    } else {
                                        self.photoURL = url?.absoluteString
                                        self.firestore.updateUserProfile(fullName: self.fullNameTextField.text ?? "",
                                                                    userName: self.userNameTextField.text ?? "",
                                                                    city: self.cityTextField.text ?? "",
                                                                    country: self.countryTextField.text ?? "",
                                                                    photoURL: self.photoURL ?? "") { (error) in
                                                                        if let error = error {
                                                                            print ("Error updating user profile \(error)")
                                                                            let alert = Utils.showAlert(status: .failure, message: ErrorMessages.updateUserError)
                                                                            self.present(alert, animated: true) {
                                                                                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
                                                                                    guard self?.presentedViewController == alert else { return }
                                                                                    self?.dismiss(animated: true, completion: nil)
                                                                                }
                                                                            }
                                                                        } else {
                                                                            let alert = Utils.showAlert(status: .success, message: ErrorMessages.updateUserSuccess)
                                                                            self.present(alert, animated: true) {
                                                                                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
                                                                                    guard self?.presentedViewController == alert else { return }
                                                                                    self?.dismiss(animated: true, completion: nil)
                                                                                    self?.navigationController?.popViewController(animated: true)
                                                                                }
                                                                            }
                                                                            
                                                                            self.firestore.downloadUserProfile(Auth.auth().currentUser?.uid ?? "", completionHandler: { (userProfile, error) in
                                                                                if let error = error {
                                                                                    print ("Error getting user profile \(error)")
                                                                                } else {
                                                                                    AppDataSingleton.appDataSharedInstance.userProfile = userProfile!
                                                                                }
                                                                            })
                                                                        }
                                        }
                                    }
        })
        
    }
    @objc func dismissAlert() {
        popup.dismiss(animated: true)
        navigationController?.popViewController(animated: true)
    }
}
extension EditProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    @objc func viewImagePicker(recognizer: UITapGestureRecognizer) {
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            let imag = UIImagePickerController()
            imag.delegate = self
            imag.sourceType = .photoLibrary
            //imag.mediaTypes = [kUTTypeImage];
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
        
        picker.dismiss(animated: true, completion: {
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
    
    func updateImageViewWithImage(_ image: UIImage, fromCropViewController cropViewController: CropViewController) {
        profileImageView.image = image
        self.navigationItem.rightBarButtonItem?.isEnabled = true
        
        if cropViewController.croppingStyle != .circular {
            profileImageView.isHidden = true
            
            cropViewController.dismissAnimatedFrom(self, withCroppedImage: image,
                                                   toView: profileImageView,
                                                   toFrame: CGRect.zero,
                                                   setup: { },
                                                   completion: { self.profileImageView.isHidden = false })
        }
        else {
            self.profileImageView.isHidden = false
            cropViewController.dismiss(animated: true, completion: nil)
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
}
