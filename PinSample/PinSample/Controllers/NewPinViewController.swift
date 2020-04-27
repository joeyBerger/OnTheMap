//
//  NewPinViewController.swift
//  PinSample
//
//  Created by Joey Berger on 4/11/20.
//  Copyright © 2020 Udacity. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class NewPinViewController: UIViewController, MKMapViewDelegate, UITextViewDelegate {
    
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var inputField: UITextView!
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    let defaultTextViewStr_noLoc = "Enter Location..."
    let defaultTextViewStr_validLoc = "Enter A URL..."
    var validLoc = false
    var mapString = ""
    var chosenCoordinate: CLLocationCoordinate2D?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        inputField.delegate = self
        self.view.backgroundColor = UIColor(red: 203/255, green: 235/255, blue: 254/255, alpha: 1.0)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(false)
        self.submitButton.setTitle("ENTER", for: .normal)
        inputField.textColor = UIColor.lightGray
        validLoc = false
        setActivityIndicatorEnabled(false)
        setInputObjectsEnabled(true)
    }
    
    @IBAction func handleCancelButton(_ sender: Any) {
        navigateToTabController()
    }
    
    func navigateToTabController() {
        if let tabViewController = storyboard?.instantiateViewController(withIdentifier: "UITabbarController") as? UITabBarController {
            tabViewController.modalPresentationStyle = .fullScreen
            present(tabViewController, animated: false, completion: nil)
        }
    }
    
    func setActivityIndicatorEnabled(_ enabled: Bool) {
        activityIndicator.isHidden = !enabled
        if enabled {
            activityIndicator.startAnimating()
            return
        }
        activityIndicator.stopAnimating()
    }
    
    func displayAlert(_ type: String) {
        var title = "", message = ""
        if (type == "invalidLoc") {
            title = "Could Not Find Location"
            message = "Please enter a valid location and try again"
        } else if (type == "postError") {
            title = "Error in Posting New Pin"
            message = "Please try again"
        }
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func handleSubmitButton(_ sender: Any) {
        
        if (inputField.text == defaultTextViewStr_noLoc || inputField.text == defaultTextViewStr_validLoc) {return}
        
        setActivityIndicatorEnabled(true)
        setInputObjectsEnabled(false)
        
        if (validLoc) {
            let newPinInfo = NewPinInfo(mapString: mapString, mediaURL: inputField.text, latitude: chosenCoordinate!.latitude, longitude: chosenCoordinate!.longitude)
            UdacityClient.postLocation(newPinInfo) {success, error in
                self.setActivityIndicatorEnabled(false)
                if error != nil || !success {
                    self.displayAlert("postError")
                    self.setInputObjectsEnabled(true)
                    self.validLoc = false
                    self.submitButton.setTitle("ENTER", for: .normal)
                    self.inputField.text = self.defaultTextViewStr_noLoc
                    self.inputField.textColor = UIColor.lightGray
                    return
                }
                self.navigateToTabController()
            }
            return
        }
        
        if let address = inputField.text {
            getCoordinateFrom(address: address) { coordinate, error in
                guard let coordinate = coordinate, error == nil else {
                    DispatchQueue.main.async {
                        self.displayAlert("invalidLoc")
                        self.setActivityIndicatorEnabled(false)
                    }
                    return
                }
                DispatchQueue.main.async {
                    let annotation = MKPointAnnotation()
                    annotation.coordinate = coordinate
                    let viewRegion = MKCoordinateRegion(center: coordinate, latitudinalMeters: 200, longitudinalMeters: 200)
                    self.mapView.setRegion(viewRegion, animated: true)
                    self.mapView.addAnnotations([annotation])
                    self.submitButton.setTitle("SUBMIT", for: .normal)
                    self.validLoc = true
                    self.mapString = self.inputField.text
                    self.inputField.text = self.defaultTextViewStr_validLoc
                    self.inputField.textColor = UIColor.lightGray
                    self.setActivityIndicatorEnabled(false)
                    self.chosenCoordinate = coordinate
                    self.setInputObjectsEnabled(true)
                }
            }
        }
    }
    
    func getCoordinateFrom(address: String, completion: @escaping(_ coordinate: CLLocationCoordinate2D?, _ error: Error?) -> () ) {
        CLGeocoder().geocodeAddressString(address) { completion($0?.first?.location?.coordinate, $1) }
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if (inputField.text == defaultTextViewStr_noLoc || inputField.text == defaultTextViewStr_validLoc) {
            inputField.text = ""
            inputField.textColor = UIColor.black
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            if inputField.text == "" {
                inputField.text = validLoc ? defaultTextViewStr_validLoc : defaultTextViewStr_noLoc
                inputField.textColor = UIColor.lightGray
            }
            textView.resignFirstResponder()
        }
        return true
    }
    
    func setTextViewEnabled(_ enabled: Bool) {
        inputField.isUserInteractionEnabled = enabled
    }
    
    func setSubmitButtonEnabled(_ enabled: Bool) {
        submitButton.isEnabled = enabled
    }
    
    func setInputObjectsEnabled(_ enabled: Bool) {
        setTextViewEnabled(enabled)
        setSubmitButtonEnabled(enabled)
    }
}
