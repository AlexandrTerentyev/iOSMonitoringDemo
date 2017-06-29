//
//  ViewController.swift
//  MonitoringDemo
//
//  Created by Aleksandr Terentev on 27.06.17.
//  Copyright © 2017 Aleksandr Terentev. All rights reserved.
//

import UIKit
import MapKit

class ViewController: UIViewController {

    var cameraDistance: CLLocationDistance = 1000
    
    @IBOutlet weak var sharingCodeField: UITextField!
    
    
    @IBOutlet weak var mapView: MKMapView!
    var currentLocationAnnotation: MKPointAnnotation?
    
    let monitoringManager = MonitoringManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        monitoringManager.sharingCode = sharingCodeField.text
        
        mapView.delegate = self
        
        monitoringManager.didUpdateLoctionsClosure = {[weak self] locations in
            self?.updateCurrentLocationInMap(location: locations.last)
        }
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func onStartMonitoringTapped(_ sender: Any) {
        monitoringManager.startUpdatingLocation()
    }

    @IBAction func onStopMonitoringTapped(_ sender: Any) {
        monitoringManager.stopUpdatingLocations()
    }
   
    
    @IBAction func onSendCachedLocations(_ sender: Any) {
        monitoringManager.trySendLocations()
    }
}

//Work with map
extension ViewController: MKMapViewDelegate{
    
    func updateCurrentLocationInMap(location: CLLocation?){
        guard let location = location else {return}
        
        if currentLocationAnnotation == nil{
            currentLocationAnnotation = MKPointAnnotation()
            mapView.addAnnotation(currentLocationAnnotation!)
            mapView.camera = MKMapCamera(lookingAtCenter: location.coordinate, fromDistance: cameraDistance, pitch: 0, heading: 0)
        }
        
        currentLocationAnnotation?.coordinate = location.coordinate

        mapView.setCamera(MKMapCamera(lookingAtCenter: location.coordinate, fromDistance: cameraDistance, pitch: 0, heading: 0), animated: true)
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let annotationView = MKAnnotationView()
        annotationView.image = #imageLiteral(resourceName: "markerIcon")
        return annotationView
    }
}

extension ViewController: UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        monitoringManager.sharingCode = textField.text
        
        return true
    }
}

