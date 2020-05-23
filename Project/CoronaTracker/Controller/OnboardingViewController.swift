//
//  OnboardingViewController.swift
//  CoronaTracker
//
//  Created by Aaryan Kothari on 22/05/20.
//  Copyright © 2020 Aaryan Kothari. All rights reserved.
//

import UIKit

class OnboardingViewController: UIViewController {
    // Dissmiss onboarding screen
    @IBAction func continueClicked(_ sender: Any) {
        self.dismiss(animated:true)
        UserDefaults.standard.setValue(false, forKey: "onboarding")
    }
}
