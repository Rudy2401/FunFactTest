//
//  VerifyViewController.swift
//  FunFactTest
//
//  Created by Rushi Dolas on 2/11/19.
//  Copyright © 2019 Rushi Dolas. All rights reserved.
//

import UIKit
import FirebaseFirestore
import Firebase

class VerifyViewController: UIViewController, RejectionViewDelegate, FirestoreManagerDelegate {
    
    @IBOutlet weak var rejectionView: RejectionView!
    var firestore = FirestoreManager()
    var funFact = FunFact(landmarkId: "",
                          landmarkName: "",
                          id: "",
                          description: "",
                          funFactTitle: "",
                          likes: 0,
                          dislikes: 0,
                          verificationFlag: "",
                          image: "",
                          imageCaption: "",
                          disputeFlag: "",
                          submittedBy: "",
                          dateSubmitted: Timestamp(date: Date()),
                          source: "",
                          tags: [],
                          approvalCount: 0,
                          rejectionCount: 0,
                          approvalUsers: [],
                          rejectionUsers: [],
                          rejectionReason: [])
    var rejectionCount = 0
    var verFlag = ""
    var popup = UIAlertController()
    var callback: ((Status) -> ())?
    
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
        navigationItem.title = "Rejecting A Fact"
        rejectionView.delegate = self
        firestore.delegate = self
    }
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        darkModeSupport()
    }
    func darkModeSupport() {
        if #available(iOS 13.0, *) {
            self.view.backgroundColor = traitCollection.userInterfaceStyle == .light ? .white : .secondarySystemBackground
        } else {
            self.view.backgroundColor = .white
        }
    }
    func cancelButtonPressed() {
        self.navigationController?.popViewController(animated: true)
    }
    func submitButtonPressed(reason: String) {
        let alertController = UIAlertController(title: "Verification",
                                                message: "Are you sure you want to reject this fact?",
                                                preferredStyle: .alert)
        
        let okayAction = UIAlertAction(title: "Ok", style: .default, handler: { (_) in
            let rejCount = self.rejectionCount + 1
            if rejCount == 3 {
                self.verFlag = "R"
            }
            self.firestore.updateRejectionFlag(
                for: self.funFact.id,
                verFlag: self.verFlag,
                rejCount: rejCount,
                reason: reason,
                completion: { (status) in
                    var message = ""
                    if status == .success {
                        message = ErrorMessages.rejectionSuccess
                    } else {
                        message = ErrorMessages.rejectionError
                    }
                    let alert = Utils.showAlert(status: status, message: message)
                    self.firestore.addFunFactRejectedToUser(
                        funFact: self.funFact,
                        user: Auth.auth().currentUser?.uid ?? "") { (error) in
                            if let error = error {
                                print ("Error updating user \(error)")
                            } else {
                                self.firestore.downloadUserProfile(Auth.auth().currentUser?.uid ?? "", completionHandler: { (userProfile, error) in
                                    if let error = error {
                                        print ("Error getting user \(error)")
                                    } else {
                                        self.callback!(status)
                                        AppDataSingleton.appDataSharedInstance.userProfile = userProfile!
                                    }
                                })
                                self.present(alert, animated: true) {
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
                                        guard self?.presentedViewController == alert else { return }
                                        self?.dismiss(animated: true, completion: nil)
                                        self?.navigationController?.popViewController(animated: true)
                                    }
                                }
                            }
                    }
                    
            })
            
        })
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(okayAction)
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true, completion: nil)
        
    }
    func documentsDidUpdate() {
        
    }
    
    @objc func dismissAlert() {
        popup.dismiss(animated: true)
        navigationController?.popViewController(animated: true)
    }
}
