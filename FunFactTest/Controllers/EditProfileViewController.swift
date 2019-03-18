//
//  EditProfileViewController.swift
//  FunFactTest
//
//  Created by Rushi Dolas on 2/25/19.
//  Copyright © 2019 Rushi Dolas. All rights reserved.
//

import UIKit
import FirebaseAuth

class EditProfileViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate, FirestoreManagerDelegate {
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        firestore.delegate = self
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        
        if let customFont = UIFont(name: "AvenirNext-Bold", size: 30.0) {
            navigationController?.navigationBar.largeTitleTextAttributes = [
                NSAttributedString.Key.foregroundColor: UIColor.black,
                NSAttributedString.Key.font: customFont
            ]
        }
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
        submitButton.layer.backgroundColor = Colors.seagreenColor.cgColor
        
        let imagePickerTapGesture = UITapGestureRecognizer(target: self, action: #selector(viewImagePicker))
        imagePickerTapGesture.numberOfTapsRequired = 1
        profileImageView.addGestureRecognizer(imagePickerTapGesture)
        profileImageView.isUserInteractionEnabled = true
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
                    profileImageView.image = UIImage(data: data!)
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
        let title = NSAttributedString(string: data, attributes: [NSAttributedString.Key.font: UIFont(name: "Avenir Next", size: 14)!])
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
                                                                                }
                                                                            }
                                                                            
                                                                            self.firestore.downloadUserProfile(Auth.auth().currentUser?.uid ?? "", completionHandler: { (userProfile) in
                                                                                AppDataSingleton.appDataSharedInstance.userProfile = userProfile
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
            imag.allowsEditing = true
            self.present(imag, animated: true, completion: nil)
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        // Local variable inserted by Swift 4.2 migrator.
        let info = convertFromUIImagePickerControllerInfoKeyDictionary(info)
        
        guard let selectedImage = info[convertFromUIImagePickerControllerInfoKey(
            UIImagePickerController.InfoKey.editedImage)]
            as? UIImage else { return }
        self.selectedImage = selectedImage
        self.dismiss(animated: true, completion: nil)
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
