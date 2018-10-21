//
//  ChangeCityViewController.swift
//  WeatherApp
//
//  Created by Angela Yu on 23/08/2015.
//  Copyright (c) 2015 London App Brewery. All rights reserved.
//

import UIKit
import RAMReel


//Write the protocol declaration here:

var dataSource: SimplePrefixQueryDataSource!
var ramReel: RAMReel<RAMCell, RAMTextField, SimplePrefixQueryDataSource>!


protocol ChangeCityDelegate {
    func userEnteredANewCityName(city: String)
}

class ChangeCityViewController: UIViewController {
    
    //Declare the delegate variable here:
    var delegate : ChangeCityDelegate?
    @IBOutlet weak var cityButton: UIButton!
    @IBOutlet weak var weatherButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    @IBAction func getCityPressed(_ sender: Any) {
        dataSource = SimplePrefixQueryDataSource(data)
        
        print("Search Page Reached")
        ramReel = RAMReel(frame: view.bounds, dataSource: dataSource, placeholder: "Start by typing…", attemptToDodgeKeyboard: true) {
            print("Plain:", $0)
            
            let cityName = $0
            self.delegate?.userEnteredANewCityName(city: cityName)
            //self.dismiss(animated: true, completion: nil)
            self.performSegue(withIdentifier: "gotCity", sender: self)
        }
        
//        ramReel.hooks.append {
//            let r = Array($0.reversed())
//            let j = String(r)
//            print("Reversed:", j)
//        }
        
        view.addSubview(ramReel.view)
        cityButton.removeFromSuperview()
        weatherButton.removeFromSuperview()
        
        ramReel.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    }
    
    //This is the pre-linked IBOutlets to the text field:
    //@IBOutlet weak var changeCityTextField: UITextField!
    
    func textFieldDidBeginEditing(textField: UITextField) {
        //NEW CODE
        
        
    }
    
//    override func viewDidLayoutSubviews() {
//        super.viewDidLayoutSubviews()
//        ramReel.prepareForViewing()
//    }

    
    //This is the IBAction that gets called when the user taps on the "Get Weather" button:
    @IBAction func getWeatherPressed(_ sender: AnyObject) {
        
//        //1 Get the city name the user entered in the text field
//        let cityName = changeCityTextField.text!
//
//        //2 If we have a delegate set, call the method userEnteredANewCityName
//        delegate?.userEnteredANewCityName(city: cityName)
//
//        //3 dismiss the Change City View Controller to go back to the WeatherViewController
//        self.dismiss(animated: true, completion: nil)
        
    }
    
    //This is the IBAction that gets called when the user taps the back button. It dismisses the ChangeCityViewController.
    @IBAction func backButtonPressed(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
    
    fileprivate let data: [String] = {
        do {
            guard let dataPath = Bundle.main.path(forResource: "Countries", ofType: "txt") else {
                return []
            }
            
            let data = try WordReader(filepath: dataPath)
            return data.words
        }
        catch let error {
            print(error)
            print("ERROR READING CITIES")
            return []
        }
    }()
}
