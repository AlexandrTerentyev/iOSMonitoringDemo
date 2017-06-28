//
//  LocationCollectingAndSending.swift
//  MonitoringDemo
//
//  Created by Aleksandr Terentev on 27.06.17.
//  Copyright © 2017 Aleksandr Terentev. All rights reserved.
//

import Foundation
import CoreLocation
import SocketRocket

class LocationCollectorAndSender: NSObject{
    fileprivate var locations = [CLLocation]()
    
    func add(locations: [CLLocation]){
        DispatchQueue.main.async {
            self.locations.append(contentsOf: locations)
        }
    }
    
    var sharingCode: String?
}

extension LocationCollectorAndSender: SRWebSocketDelegate{
    func webSocket(_ webSocket: SRWebSocket!, didReceiveMessage message: Any!) {
        debugPrint("Socket didreceive message")
    }
    
    func webSocket(_ webSocket: SRWebSocket!, didFailWithError error: Error!) {
        debugPrint("Socket did fail with error:", error)
    }
    
    func sendCachedLocations() {
        let socket = SRWebSocket(url: URL(string: LocationsSocketURL))
        socket?.open()
    }

    func webSocketDidOpen(_ webSocket: SRWebSocket!) {
        DispatchQueue.main.async {
            self.sendCachedLocations()
        }
    }
    
    func sendLocationsToSocket(socket: SRWebSocket){
        guard let sharingCode = sharingCode else {
            debugPrint("No sharing code")
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
            socket.send(data)
        }catch let error{
            debugPrint(error.localizedDescription)
            socket.close()
            return
        }
        
        locations = []
        socket.close()
    }
}

