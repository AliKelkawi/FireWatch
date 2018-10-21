//
//  ReportFire.swift
//  FireWatch
//
//  Created by Abdalwahab on 10/18/18.
//  Copyright © 2018 Ali Kelkawi. All rights reserved.
//

import UIKit
import MapKit
import Firebase
import SideMenu
import SVProgressHUD
import CoreLocation
import UserNotifications

class MapVC: UIViewController, CLLocationManagerDelegate {
    
    static var fireCount = 0
    
    //map objects
    @IBOutlet var map: MKMapView!
    var reportLocation : MKPointAnnotation = MKPointAnnotation()
    var reportPinAdded = false
    
    //buttons
    @IBOutlet var reportBtn: UIButton!
    @IBOutlet var checkBtn: UIButton!
    @IBOutlet var cancelBtn: UIButton!
    private var userTrackingBtn: MKUserTrackingButton!
    
    //pin card
    @IBOutlet var cardTopConstraint: NSLayoutConstraint!
    @IBOutlet var pinImage: UIImageView!
    
    private let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //navigationController?.setNavigationBarHidden(true, animated: false)
        
        userTrackingBtn = MKUserTrackingButton(mapView: map)
        userTrackingBtn.frame.origin = CGPoint(x: view.frame.width - 50, y: view.frame.height - 50)
        userTrackingBtn.layer.backgroundColor = UIColor.white.cgColor
        userTrackingBtn.layer.cornerRadius = 5
        userTrackingBtn.isHidden = true // Unhides when location authorization is given.
        view.addSubview(userTrackingBtn)
        
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) {(accepted, error) in
            if !accepted {
                print("Notification access denied.")
            }
        }
        
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
        
//        loadDataForMapRegionAndBikes()
        extract()
        
        let addPinGesture = UILongPressGestureRecognizer.init(target: self, action: #selector(addPin))
        map.addGestureRecognizer(addPinGesture)
        map.visibleMapRect = MKMapRect.world
        
        fireTimer() //start checking for nearby fires
        
        // Define the menus
        SideMenuManager.default.menuLeftNavigationController = storyboard!.instantiateViewController(withIdentifier: "LeftMenuNavigationController") as! UISideMenuNavigationController
        
        // Enable gestures. The left and/or right menus must be set up above for these to work.
        // Note that these continue to work on the Navigation Controller independent of the View Controller it displays!
        SideMenuManager.default.menuAddPanGestureToPresent(toView: self.navigationController!.navigationBar)
        SideMenuManager.default.menuAddScreenEdgePanGesturesToPresent(toView: self.navigationController!.view, forMenu: .left)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        //navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let report = segue.destination as? ReportVC {
            report.cords = reportLocation.coordinate
        }
    }
    
    private func extract() {
        let ref = Database.database().reference()
        let query = ref.queryOrdered(byChild: "FireLocations")
        query.observeSingleEvent(of: .value, with: { (fireSnapshot) in
            
            for child in fireSnapshot.children.allObjects as! [DataSnapshot]{
                MapVC.fireCount = child.children.allObjects.count
                
                for i in 2...child.children.allObjects.count {
                    let long = child.childSnapshot(forPath: "Location\(i)/Longitude").value as! Double
                    let lat = child.childSnapshot(forPath: "Location\(i)/Latitude").value as! Double
                    
                    let cycle = Cycle()
                    cycle.coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
                    cycle.id = "Location\(i)"
                    
                    self.map.addAnnotation(cycle)
                }
            }
            
            print(self.map.annotations.count)
        })
    }
    
    @IBAction func closeCard() {
        UIView.animate(withDuration: 0.4) {
            self.cardTopConstraint.constant = 0
            self.view.layoutIfNeeded()
        }
    }
    ////////////////
}

//MARK: - Checking locations
extension MapVC {
    @IBAction func checkLocation() {
        let radius = 100000.0 // meters
        
        for annotation in map.annotations {
            //calculate from the current location of the user and every fire location
            let fireLocation = CLLocation(latitude: annotation.coordinate.latitude, longitude: annotation.coordinate.longitude)
            let pinnedLocation = CLLocation(latitude: reportLocation.coordinate.latitude, longitude: reportLocation.coordinate.longitude)
            
            //the distance is measured in meters
            let distance = fireLocation.distance(from: pinnedLocation)
            print("\(distance) \(annotation)")
            
            if (fireLocation.distance(from: pinnedLocation) <= radius && !(annotation is MKUserLocation)
                                        && !(annotation is MKPointAnnotation)) {
                showAlert(title: "Warning", message: "The location specified is close to a fire", parent: self)
                return
            }
        }
        
        showAlert(title: "Safe", message: "The specific location is safe", parent: self)
    }
    
    func fireTimer() {
        //it will check every 60 seconds
        Timer.scheduledTimer(timeInterval: 60, target: self, selector: #selector(checkUserLocation), userInfo: nil, repeats: true)
    }
    
    @objc func checkUserLocation() {
        let radius = 100000.0 // meters
        var mini = Double.greatestFiniteMagnitude
        var found = false
        
        for annotation in map.annotations {
            //calculate from the current location of the user and every fire location
            let fireLocation = CLLocation(latitude: annotation.coordinate.latitude, longitude: annotation.coordinate.longitude)
            
            //the distance is measured in meters
            let distance = fireLocation.distance(from: locationManager.location!)
            if (distance <= radius && !(annotation is MKUserLocation)) {
                mini = min(mini, distance) // only send the closest fire
                found = true
            }
        }
        
        if found {
            let delegate = UIApplication.shared.delegate as? AppDelegate
            delegate?.scheduleNotification(body: "Warning! you are in the vicinity of a forest fire. Distance: \(mini)", triggerDate: Date(), identifier: "hi")
        }
    }
}

//MARK: - Map functions
extension MapVC: MKMapViewDelegate {
    @objc func addPin(_ gesture: UILongPressGestureRecognizer) {
        var pointCord = CLLocationCoordinate2D()
        let touchLocation = gesture.location(in: map)
        pointCord = map.convert(touchLocation, toCoordinateFrom: map)
        
        reportLocation.coordinate = pointCord
        
        if (!reportPinAdded) {
            map.addAnnotation(reportLocation)
            reportPinAdded = true
            
            UIView.animate(withDuration: 0.1) {
                self.reportBtn.alpha = 1
                self.checkBtn.alpha = 1
                self.cancelBtn.alpha = 1
            }
        }
    }
    
    @IBAction func cancel() {
        map.removeAnnotation(reportLocation)
        reportPinAdded = false
        
        UIView.animate(withDuration: 0.1) {
            self.reportBtn.alpha = 0
            self.checkBtn.alpha = 0
            self.cancelBtn.alpha = 0
        }
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if (annotation is MKClusterAnnotation) {
            return ClusterAnnotationView(annotation: annotation, reuseIdentifier: "intensity")
        }else if annotation is MKPointAnnotation {
            return MKMarkerAnnotationView()
        }else if annotation is MKUserLocation {
            return nil
        }
        return intensityAnnotation(annotation: annotation, reuseIdentifier: intensityAnnotation.ReuseID)
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
//        if !(view is Cycle) {
//            return
//        }
        
        SVProgressHUD.show()
        UIView.animate(withDuration: 0.4) {
            self.cardTopConstraint.constant = -mapView.frame.height + 10
            self.view.layoutIfNeeded()
        }
        
        let casted = view.annotation as! Cycle
        
        let pathReference = Storage.storage().reference(withPath: "images/\(casted.id).png")
        
        // Download in memory with a maximum allowed size of 10MB (10 * 1024 * 1024 bytes)
        pathReference.getData(maxSize: 10 * 1024 * 1024) { data, error in
            if let error = error {
                print(error)
            } else {
                // Data for downloaded image is returned
                let image = UIImage(data: data!)
                self.pinImage.image = image
                SVProgressHUD.dismiss()
            }
        }
    }
}

extension MapVC {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        let locationAuthorized = status == .authorizedWhenInUse
        userTrackingBtn.isHidden = !locationAuthorized
    }
}
