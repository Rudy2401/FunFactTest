//
//  NotificationFrequency.swift
//  FunFactTest
//
//  Created by Rushi Dolas on 3/25/19.
//  Copyright © 2019 Rushi Dolas. All rights reserved.
//

import UIKit

class NotificationFrequency: UIViewController {
    @IBOutlet weak var touristLabel: UILabel!
    @IBOutlet weak var touristSwitch: UISwitch!
    @IBOutlet weak var occasionalLabel: UILabel!
    @IBOutlet weak var occasionalSwitch: UISwitch!
    @IBOutlet weak var offLabel: UILabel!
    @IBOutlet weak var offSwitch: UISwitch!
    @IBOutlet weak var updateButton: CustomButton!
    @IBOutlet weak var automobileSwitch: UISwitch!
    @IBOutlet weak var walkSwitch: UISwitch!
    @IBOutlet weak var directionsOffSwitch: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "More Settings"
        updateButton.cornerRadius = 25
        updateButton.layer.backgroundColor = Colors.seagreenColor.cgColor
    }
    override func viewDidAppear(_ animated: Bool) {
        loadNotificationFrequency()
        loadDirectionSettings()
    }
    
    @IBAction func touristModeAction(_ sender: Any) {
        if !touristSwitch.isOn {
            touristSwitch.setOn(true, animated: true)
            occasionalSwitch.setOn(false, animated: true)
            offSwitch.setOn(false, animated: true)
        } else {
            touristSwitch.setOn(false, animated: true)
        }
    }
    @IBAction func occasionalAction(_ sender: Any) {
        if !occasionalSwitch.isOn {
            occasionalSwitch.setOn(true, animated: true)
            touristSwitch.setOn(false, animated: true)
            offSwitch.setOn(false, animated: true)
        } else {
            occasionalSwitch.setOn(false, animated: true)
        }
    }
    @IBAction func offAction(_ sender: Any) {
        if !offSwitch.isOn {
            offSwitch.setOn(true, animated: true)
            occasionalSwitch.setOn(false, animated: true)
            touristSwitch.setOn(false, animated: true)
        } else {
            offSwitch.setOn(false, animated: true)
        }
    }
    @IBAction func automobileAction(_ sender: Any) {
        if !automobileSwitch.isOn {
            automobileSwitch.setOn(true, animated: true)
            walkSwitch.setOn(false, animated: true)
            directionsOffSwitch.setOn(false, animated: true)
        } else {
            automobileSwitch.setOn(false, animated: true)
        }
    }
    @IBAction func walkAction(_ sender: Any) {
        if !walkSwitch.isOn {
            walkSwitch.setOn(true, animated: true)
            automobileSwitch.setOn(false, animated: true)
            directionsOffSwitch.setOn(false, animated: true)
        } else {
            walkSwitch.setOn(false, animated: true)
        }
    }
    @IBAction func directionsOffAction(_ sender: Any) {
        if !directionsOffSwitch.isOn {
            directionsOffSwitch.setOn(true, animated: true)
            walkSwitch.setOn(false, animated: true)
            automobileSwitch.setOn(false, animated: true)
        } else {
            directionsOffSwitch.setOn(false, animated: true)
        }
    }
    @IBAction func updateAction(_ sender: Any) {
        updateNotificationFrequency()
        updateDirectionSetting()
    }
    func loadNotificationFrequency() {
        switch UserDefaults.standard.integer(forKey: SettingsUserDefaults.notificationFrequency)  {
        case 0:
            offSwitch.setOn(true, animated: true)
            occasionalSwitch.setOn(false, animated: true)
            touristSwitch.setOn(false, animated: true)
        case 7:
            occasionalSwitch.setOn(true, animated: true)
            offSwitch.setOn(false, animated: true)
            touristSwitch.setOn(false, animated: true)
        case 30:
            touristSwitch.setOn(true, animated: true)
            offSwitch.setOn(false, animated: true)
            occasionalSwitch.setOn(false, animated: true)
        default:
            offSwitch.setOn(false, animated: true)
            occasionalSwitch.setOn(true, animated: true)
            touristSwitch.setOn(false, animated: true)
        }
    }
    func loadDirectionSettings() {
        switch UserDefaults.standard.string(forKey: SettingsUserDefaults.directionsSetting)  {
        case DirectionSetting.auto:
            automobileSwitch.setOn(true, animated: true)
            walkSwitch.setOn(false, animated: true)
            directionsOffSwitch.setOn(false, animated: true)
        case DirectionSetting.walk:
            walkSwitch.setOn(true, animated: true)
            automobileSwitch.setOn(false, animated: true)
            directionsOffSwitch.setOn(false, animated: true)
        case DirectionSetting.off:
            directionsOffSwitch.setOn(true, animated: true)
            walkSwitch.setOn(false, animated: true)
            automobileSwitch.setOn(false, animated: true)
        default:
            automobileSwitch.setOn(false, animated: true)
            walkSwitch.setOn(false, animated: true)
            directionsOffSwitch.setOn(false, animated: true)
        }
    }
    func updateNotificationFrequency() {
        if touristSwitch.isOn {
            UserDefaults.standard.set(30, forKey: SettingsUserDefaults.notificationFrequency)
        } else if occasionalSwitch.isOn {
            UserDefaults.standard.set(7, forKey: SettingsUserDefaults.notificationFrequency)
        } else if offSwitch.isOn {
            UserDefaults.standard.set(0, forKey: SettingsUserDefaults.notificationFrequency)
        }
        let alert = Utils.showAlert(status: .success, message: ErrorMessages.settingsSuccess)
        self.present(alert, animated: true) {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
                guard self?.presentedViewController == alert else { return }
                self?.dismiss(animated: true, completion: nil)
                self!.navigationController?.popViewController(animated: true)
            }
        }
    }
    func updateDirectionSetting() {
        if automobileSwitch.isOn {
            UserDefaults.standard.set(DirectionSetting.auto, forKey: SettingsUserDefaults.directionsSetting)
        } else if walkSwitch.isOn {
            UserDefaults.standard.set(DirectionSetting.walk, forKey: SettingsUserDefaults.directionsSetting)
        } else if directionsOffSwitch.isOn {
            UserDefaults.standard.set(DirectionSetting.off, forKey: SettingsUserDefaults.directionsSetting)
        }
        let alert = Utils.showAlert(status: .success, message: ErrorMessages.settingsSuccess)
        self.present(alert, animated: true) {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
                guard self?.presentedViewController == alert else { return }
                self?.dismiss(animated: true, completion: nil)
                self!.navigationController?.popViewController(animated: true)
            }
        }
    }
}
