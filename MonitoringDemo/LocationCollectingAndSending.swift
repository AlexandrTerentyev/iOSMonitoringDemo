//
//  LocationCollectingAndSending.swift
//  MonitoringDemo
//
//  Created by Aleksandr Terentev on 27.06.17.
//  Copyright © 2017 Aleksandr Terentev. All rights reserved.
//

import Foundation
import CoreLocation
import Starscream

class LocationCollectorAndSender{
    fileprivate var locations = [CLLocation]()
    
    func add(locations: [CLLocation]){
        DispatchQueue.main.async {
            self.locations.append(contentsOf: locations)
        }
    }
    
    var sharingCode: String?
}

extension LocationCollectorAndSender: WebSocketDelegate{
    func websocketDidConnect(socket: WebSocket) {
        DispatchQueue.main.async {
            self.sendCachedLocations()
        }
    }
    
    func websocketDidDisconnect(socket: WebSocket, error: NSError?) {
        print("Socket did close with error:", error)
    }
    
    func websocketDidReceiveData(socket: WebSocket, data: Data) {
        
    }
    
    func websocketDidReceiveMessage(socket: WebSocket, text: String) {
        
    }
    
    func sendCachedLocations() {
        let socket = WebSocket(url: URL(string: LocationsSocketURL)!)
        socket.delegate = self
        socket.connect()
    }

    
    func sendLocationsToSocket(socket: WebSocket){
        guard let sharingCode = sharingCode else {
            print("No sharing code")
            return
        }
        
        let jsonPoints = locations.map { (location: CLLocation) -> [String: Any] in
            return [
                "lat": location.coordinate.latitude,
                "lon": location.coordinate.longitude,
                "acc": location.horizontalAccuracy,
                "time": location.timestamp.timeIntervalSince1970
            ]
        }
        
        let json: [String: Any] = [
            "sharingCode": sharingCode,
            "locations": jsonPoints
        ]
        
        do{
            let data = try JSONSerialization.data(withJSONObject: json, options: .init(rawValue: 0))
            socket.write(data: data)
        }catch let error{
            print(error.localizedDescription)
            socket.disconnect()
            return
        }
        
        locations = []
        socket.disconnect()
    }
}

