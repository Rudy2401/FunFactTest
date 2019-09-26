//
//  RejectionView.swift
//  FunFactTest
//
//  Created by Rushi Dolas on 2/15/19.
//  Copyright © 2019 Rushi Dolas. All rights reserved.
//

import UIKit

protocol RejectionViewDelegate: class {
    func cancelButtonPressed()
    func submitButtonPressed(reason: String)
}

class RejectionView: UIView, UIPickerViewDelegate, UIPickerViewDataSource {
    
    @IBOutlet weak var rejectionReason: UIPickerView!
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var okButton: CustomButton!
    @IBOutlet weak var cancelButton: CustomButton!
    @IBOutlet weak var contentView: UIView!
    
    weak var delegate: RejectionViewDelegate?
    
    var pickerData = [String]()
    var reason = ""
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    @IBAction func cancelAction(_ sender: Any) {
        delegate?.cancelButtonPressed()
    }
    
    @IBAction func submitAction(_ sender: Any) {
        delegate?.submitButtonPressed(reason: reason)
    }
    
    private func commonInit() {
        Bundle.main.loadNibNamed("RejectionView", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = bounds
        contentView.autoresizingMask = [.flexibleWidth,
                                       .flexibleHeight]

        if #available(iOS 13.0, *) {
            contentView.backgroundColor = traitCollection.userInterfaceStyle == .light ? .white : .secondarySystemBackground
        } else {
            contentView.backgroundColor = traitCollection.userInterfaceStyle == .light ? .white : .darkGray
        }
        pickerData = Constants.rejectionReason
        rejectionReason.delegate = self
        rejectionReason.dataSource = self
        rejectionReason?.layer.borderWidth = 0
        rejectionReason?.layer.borderColor = UIColor.darkGray.cgColor
        rejectionReason?.layer.cornerRadius = 5
        
        okButton.layer.backgroundColor = Colors.systemGreenColor.cgColor
        okButton.frame = CGRect(x: 0, y: 0, width: contentView.frame.width/2 - 10, height: 50)
        let okButtonText = NSAttributedString(string: "Submit", attributes: Attributes.loginButtonAttribute)
        okButton.setAttributedTitle(okButtonText, for: .normal)
        let okButtonClickedText = NSAttributedString(string: "Submit", attributes: Attributes.loginButtonClickedAttribute)
        okButton.setAttributedTitle(okButtonClickedText, for: .highlighted)
        okButton.setAttributedTitle(okButtonClickedText, for: .selected)
        
        cancelButton.layer.backgroundColor = UIColor.clear.cgColor
        cancelButton.layer.borderColor = Colors.systemGreenColor.cgColor
        cancelButton.layer.borderWidth = 1.0
        cancelButton.tintColor = Colors.systemGreenColor
        cancelButton.frame = CGRect(x: 0, y: 0, width: contentView.frame.width/2 - 10, height: 50)
        let cancelButtonText = NSAttributedString(string: "Cancel", attributes: Attributes.cancelButtonAttribute)
        cancelButton.setAttributedTitle(cancelButtonText, for: .normal)
        let cancelButtonClickedText = NSAttributedString(string: "Cancel", attributes: Attributes.loginButtonClickedAttribute)
        cancelButton.setAttributedTitle(cancelButtonClickedText, for: .highlighted)
        cancelButton.setAttributedTitle(cancelButtonClickedText, for: .selected)
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
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        reason = pickerData[row]
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
                                       attributes: [NSAttributedString.Key.font: UIFont(name: Fonts.regularFont,
                                                                                        size: 14)!])
        label?.attributedText = title
        label?.textAlignment = .center
        return label!
    }
}
