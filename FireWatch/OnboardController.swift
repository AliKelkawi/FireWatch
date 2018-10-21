////
////  ViewController.swift
////  FireWatch
////
////  Created by mac on 10/18/18.
////  Copyright © 2018 Ali Kelkawi. All rights reserved.
////
//
//import UIKit
//
//class OnboardController: UIViewController {
//    
//    lazy var onboardingPages: [OnboardPage] = {
//        let pageOne = OnboardPage(title: "Welcome to Habitat",
//                                  imageName: "Onboarding1",
//                                  description: "Habitat is an easy to use productivity app designed to keep you motivated.")
//        
//        let pageTwo = OnboardPage(title: "Habit Entries",
//                                  imageName: "Onboarding2",
//                                  description: "For each of your habits an entry is created for every day you need to complete it.")
//        
//        let locationPage = OnboardPage(title: "Notifications",
//                                       imageName: "Onboarding4",
//                                       description: "Turn on notifications to get reminders and keep up with your goals.",
//                                       advanceButtonTitle: "Decide Later",
//                                       actionButtonTitle: "Enable Notifications",
//                                       action: { [weak self] completion in
//                                        self?.showAlert(completion)
//        })
//        
//        let cameraPage = OnboardPage(title: "Notifications",
//                                     imageName: "Onboarding4",
//                                     description: "Turn on notifications to get reminders and keep up with your goals.",
//                                     advanceButtonTitle: "Decide Later",
//                                     actionButtonTitle: "Enable Notifications",
//                                     action: { [weak self] completion in
//                                        self?.showAlert(completion)
//        })
//        
//        let notificationPage = OnboardPage(title: "Notifications",
//                                           imageName: "Onboarding4",
//                                           description: "Turn on notifications to get reminders and keep up with your goals.",
//                                           advanceButtonTitle: "Decide Later",
//                                           actionButtonTitle: "Enable Notifications",
//                                           action: { [weak self] completion in
//                                            self?.showAlert(completion)
//        })
//        
//        let pageFive = OnboardPage(title: "All Ready",
//                                   imageName: "Onboarding5",
//                                   description: "You are all set up and ready to use Habitat. Begin by adding your first habit.",
//                                   advanceButtonTitle: "Done")
//        
//        return [pageOne, pageTwo, locationPage, cameraPage, notificationPage, pageFive]
//    }()
//    
//    override func viewDidAppear(_ animated: Bool) {
//        super.viewDidAppear(true)
//        
//        if UserDefaults.standard.value(forKey: "firstIn") == nil {
//            showOnboardingTapped()
//        }
//    }
//    
//    func showOnboardingTapped() {
//        //save first time use log
//        UserDefaults.standard.set(true, forKey: "firstIn")
//        
//        let onboardingVC = OnboardViewController(pageItems: onboardingPages)
//        onboardingVC.modalPresentationStyle = .formSheet
//        onboardingVC.presentFrom(self, animated: false)
//    }
//    
//    private func showAlert(_ completion: @escaping (_ success: Bool, _ error: Error?) -> Void) {
//        let alert = UIAlertController(title: "Allow Notifications?",
//                                      message: "Habitat wants to send you notifications",
//                                      preferredStyle: .alert)
//        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
//            completion(true, nil)
//        })
//        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel) { _ in
//            completion(false, nil)
//        })
//        presentedViewController?.present(alert, animated: true)
//    }
//}
//
