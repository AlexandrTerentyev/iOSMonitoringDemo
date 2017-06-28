//
//  MonitoringManager.swift
//  MonitoringDemo
//
//  Created by Aleksandr Terentev on 27.06.17.
//  Copyright © 2017 Aleksandr Terentev. All rights reserved.
//

import Foundation
import CoreLocation

class MonitoringManager: NSObject{
    fileprivate let collector = LocationCollectorAndSender()
    fileprivate let locationManager = CLLocationManager()
    
    var didUpdateLoctionsClosure: (([CLLocation])->())?
    
    var sharingCode: String?{
        get{
            return collector.sharingCode
        }
        set{
            collector.sharingCode = newValue
        }
    }
    
    override init() {
        super.init()
        
        setUpLocationManager()
    }
    
    private func setUpLocationManager(){
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.delegate = self
    }
}


// MARK: Sending
extension MonitoringManager{
    func trySendLocations(){
        collector.sendCachedLocations()
    }
}

// MARK: Location manager
extension MonitoringManager: CLLocationManagerDelegate{
    func startUpdatingLocation() {
        
        locationManager.requestWhenInUseAuthorization()
        // GPS
        locationManager.startUpdatingLocation()
        
        //Low-energy
//        locationManager.startMonitoringSignificantLocationChanges()
    }
    
    func stopUpdatingLocations(){
        locationManager.stopUpdatingLocation()
        locationManager.stopMonitoringSignificantLocationChanges()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        collector.add(locations: locations)
        didUpdateLoctionsClosure?(locations)
    }
}
