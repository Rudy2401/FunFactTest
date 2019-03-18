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
        navigationController?.title = "Rejecting A Fact"
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
                    var message = ""
                    if status == .success {
                        message = ErrorMessages.rejectionSuccess
                    } else {
                        message = ErrorMessages.rejectionError
                    }
                    let alert = Utils.showAlert(status: status, message: message)
                    self.present(alert, animated: true) {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
                            guard self?.presentedViewController == alert else { return }
                            self?.dismiss(animated: true, completion: nil)
                        }
                    }
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
    
    @objc func dismissAlert() {
        popup.dismiss(animated: true)
        navigationController?.popViewController(animated: true)
    }
}
