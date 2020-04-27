import UIKit
import MapKit

class ViewController: UIViewController, MKMapViewDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    
    var locations: [[String:Any]] = [[:]]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor(red: 203/255, green: 235/255, blue: 254/255, alpha: 1.0)
        UdacityClient.getStudentData() { StudentResults, error in
            if let studentResults = StudentResults {
                self.setupPinsWithData(responseObject: studentResults)
                StudentInfo.studentInfo = studentResults.studentInfo.sorted(by: {$0.updatedAt > $1.updatedAt})
                return
            }
            self.displayAlert()
            print("error occurred with student data")
        }
    }
   
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView

        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.pinColor = .red
            pinView!.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        }
        else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }

    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == view.rightCalloutAccessoryView {
            let app = UIApplication.shared
            if let toOpen = view.annotation?.subtitle! {
                app.openURL(URL(string: toOpen)!)
            }
        }
    }
    
    @IBAction func handleNewPin(_ sender: Any) {
        let controller = self.storyboard?.instantiateViewController(withIdentifier: "NewPinViewController") as! OnTheMap.NewPinViewController
        controller.modalPresentationStyle = .fullScreen
        present(controller, animated: false, completion: nil)
    }
    
    @IBAction func handleLogout(_ sender: Any) {
        UdacityClient.deleteSession()
        let controller = self.storyboard?.instantiateViewController(withIdentifier: "LoginViewController") as! OnTheMap.LoginViewController
        controller.modalPresentationStyle = .fullScreen
        present(controller, animated: false, completion: nil)
    }
    
    func setupPinsWithData(responseObject: StudentResults) {
        var annotations = [MKPointAnnotation]()
        for info in responseObject.studentInfo {
           let lat = CLLocationDegrees(info.latitude)
           let long = CLLocationDegrees(info.longitude)
           let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
           let first = info.firstName
           let last = info.lastName
           let mediaURL = info.mediaURL
           
           let annotation = MKPointAnnotation()
           annotation.coordinate = coordinate
           annotation.title = "\(first) \(last)"
           annotation.subtitle = mediaURL
           annotations.append(annotation)
        }
        self.mapView.addAnnotations(annotations)
    }
    
    @objc func handleError() {
        let n: Any = 0
        handleLogout(n)
    }
    
    func displayAlert() {
        let alert = UIAlertController(title: "Error Retrieving Users", message: "Please logout and try again", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: {error in self.handleError()}))
        self.present(alert, animated: true, completion: nil)
    }
}
