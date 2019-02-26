//
//  VerifyViewController.swift
//  FunFactTest
//
//  Created by Rushi Dolas on 2/11/19.
//  Copyright © 2019 Rushi Dolas. All rights reserved.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth

class VerifyViewController: UIViewController, RejectionViewDelegate, FirestoreManagerDelegate {
    
    @IBOutlet weak var rejectionView: RejectionView!
    var firestore = FirestoreManager()
    var funFactID = ""
    var rejectionCount = 0
    var verFlag = ""
    var popup = UIAlertController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        rejectionView.delegate = self
        firestore.delegate = self
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
            let funFactRef = self.firestore.db.collection("funFacts").document(self.funFactID)
            if rejCount == 3 {
                self.verFlag = "R"
            }
            self.firestore.updateRejectionFlag(
                for: self.funFactID,
                verFlag: self.verFlag,
                rejCount: rejCount,
                reason: reason,
                completion: { (status) in
                    self.showAlert(message: status)
            })
            self.firestore.addFunFactRejectedToUser(
                funFactRef: funFactRef,
                funFactID: self.funFactID,
                user: Auth.auth().currentUser?.uid ?? "")
        })
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(okayAction)
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true, completion: nil)
        
    }
    func documentsDidUpdate() {
        
    }
    
    func showAlert(message: String) {
        if message == "success" {
            popup = UIAlertController(title: "Success",
                                      message: "Successfully uploaded.",
                preferredStyle: .alert)
        }
        if message == "fail" {
            popup = UIAlertController(title: "Error",
                                      message: "Error while uploading.",
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
}
