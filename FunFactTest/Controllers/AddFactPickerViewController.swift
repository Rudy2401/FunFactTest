//
//  AddFactPickerViewController.swift
//  FunFactTest
//
//  Created by Rushi Dolas on 2/25/19.
//  Copyright © 2019 Rushi Dolas. All rights reserved.
//

import UIKit

extension AddNewFactViewController: UIPickerViewDataSource, UIPickerViewDelegate {
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
                                       attributes: [NSAttributedString.Key.font: UIFont(name: Fonts.regularFont,
                                                                                        size: 14)!])
        label?.attributedText = title
        label?.textAlignment = .center
        return label!
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        type = pickerData[row]
    }
}
