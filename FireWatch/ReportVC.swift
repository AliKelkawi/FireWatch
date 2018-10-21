//
//  ReportVC.swift
//  FireWatch
//
//  Created by Abdalwahab on 10/19/18.
//  Copyright © 2018 Ali Kelkawi. All rights reserved.
//

//1- make the button store the image since we want to maybe change the image

import UIKit
import ImagePicker
import MapKit
import Firebase
import VisualRecognition
import SVProgressHUD
import SCLAlertView

class ReportVC: UIViewController {
    
    var cords : CLLocationCoordinate2D!
    
    //selected images
    var selectedImage = UIImage()
    
    @IBOutlet var cameraBtn: UIButton!
    @IBOutlet var submitBtn: UIButton!
    
    let apiKey = "d8C5S2nPSa-IRMgIVH_MD5bHLuWbqH8rSO9b-a25NyU9"
    let version = "2018-10-20"
    
    var classificationResults : [String] = []
    
    //database
    let ref = Database.database().reference()
    
    @IBAction func submitPressed(_ sender: Any) {
        SVProgressHUD.show()
        
        let visualRecognition = VisualRecognition(version: version, apiKey: apiKey)
        
        visualRecognition.classify(image: selectedImage) { (classifiedImages) in
            let classes = classifiedImages.images.first!.classifiers.first!.classes
            
            self.classificationResults = []
            for i in 0..<classes.count {
                self.classificationResults.append(classes[i].className)
            }
            
            print("Classification Results: \(self.classificationResults)")
        
            SVProgressHUD.dismiss()
            if self.classificationResults.count != 0 {
                if self.classificationResults.contains("wildfire") || self.classificationResults.contains("Wildfire") || self.classificationResults.contains("Fire") || self.classificationResults.contains("fire") || self.classificationResults.contains("flame") || self.classificationResults.contains("Flame") {
                        DispatchQueue.main.async {
                            self.navigationItem.title = "Wildfire detected"
                            let alertViewResponder: SCLAlertViewResponder = SCLAlertView().showSuccess("Success", subTitle: "Fire successfully reported. Thank you!")
                            alertViewResponder.setDismissBlock {
                                self.navigationController?.popViewController(animated: true)
                            }
                            
                            MapVC.fireCount += 1
                            let id = MapVC.fireCount
                            
                            self.ref.child("FireLocations").child("Location\(id)").child("Longitude").setValue(self.cords.longitude)
                            self.ref.child("FireLocations").child("Location\(id)").child("Latitude").setValue(self.cords.latitude)
                            
                            //ADD THIS CODE. uploading selected image
                            let storageRef = Storage.storage().reference()
                            let data = self.selectedImage.pngData()!
                            
                            let imageRef = storageRef.child("images/Location\(id).png")
                            _ = imageRef.putData(data, metadata: nil, completion: { (metadata,error ) in
                                
                                if (error != nil) {
                                    print(error as Any)
                                    return
                                }
                            })
                        }
                    
                } else {
                    DispatchQueue.main.async {
                        self.navigationItem.title = "Wildfire not detected"
                        let alertViewResponder: SCLAlertViewResponder = SCLAlertView().showError("Error", subTitle: "No fire detected. Please upload a better image.")
                    }
                }
                
            } else {
                print("There was an error picking the image")
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        cameraBtn.imageView?.contentMode = .scaleAspectFit
        self.title = "Report Fire"
//        loadDataForMapRegionAndBikes()
    }
    
    @IBAction func submit() {
        ref.child("FireLocations").child("Location1").child("Longitude").setValue(cords.longitude)
        ref.child("FireLocations").child("Location1").child("Latitude").setValue(cords.latitude)
    }
    
//    func submit2(long: CLLocationDegrees, lat: CLLocationDegrees, id: Int) {
//        ref.child("FireLocations").child("Location\(id)").child("Longitude").setValue(long)
//        ref.child("FireLocations").child("Location\(id)").child("Latitude").setValue(lat)
//    }
    
//    private func loadDataForMapRegionAndBikes() {
//        guard let plistURL = Bundle.main.url(forResource: "Data", withExtension: "plist") else {
//            fatalError("Failed to resolve URL for `Data.plist` in bundle.")
//        }
//
//        do {
//            let plistData = try Data(contentsOf: plistURL)
//            let decoder = PropertyListDecoder()
//            let decodedData = try decoder.decode(MapData.self, from: plistData)
////            map.region = decodedData.region
//            decodedData.region
//
//            var id = 1
//            for hello in decodedData.cycles {
//                submit2(long: hello.coordinate.longitude, lat: hello.coordinate.latitude, id: id)
//                id += 1
//            }
//        } catch {
//            fatalError("Failed to load provided data, error: \(error.localizedDescription)")
//        }
//    }
}

//MARK: - Photo selecting
extension ReportVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate, ImagePickerDelegate {
    
    @IBAction func selectPhotos() {
        let imagePickerController = ImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.imageLimit = 1
        present(imagePickerController, animated: true, completion: nil)
    }
    
    func wrapperDidPress(_ imagePicker: ImagePickerController, images: [UIImage]) {
        
    }
    
    func cancelButtonDidPress(_ imagePicker: ImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func doneButtonDidPress(_ imagePicker: ImagePickerController, images: [UIImage]) {
        
        selectedImage = images[0]
        
        cameraBtn.setImage(selectedImage, for: .normal)
        cameraBtn.imageView?.clipsToBounds = true
        cameraBtn.imageView?.contentMode = .scaleAspectFill
        cameraBtn.isEnabled = true
        
        submitBtn.alpha = 1
        submitBtn.isEnabled = true
        
        dismiss(animated: true, completion: nil)
    }
}

extension ReportVC {
    
}
