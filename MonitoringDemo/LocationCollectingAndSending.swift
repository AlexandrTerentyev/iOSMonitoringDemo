//
//  LocationCollectingAndSending.swift
//  MonitoringDemo
//
//  Created by Aleksandr Terentev on 27.06.17.
//  Copyright © 2017 Aleksandr Terentev. All rights reserved.
//

import Foundation
import CoreLocation

class LocationCollectorAndSender: NSObject{
    fileprivate var locations = [CLLocation]()

    func add(locations: [CLLocation]){
        DispatchQueue.main.async {
            self.locations.append(contentsOf: locations)
        }
    }
    
    var sharingCode: String?
}

extension LocationCollectorAndSender: StreamDelegate{
    
    func stream(_ aStream: Stream, handle eventCode: Stream.Event) {
        switch eventCode {
        case Stream.Event.openCompleted:
            if let outStream = aStream as? OutputStream{
                DispatchQueue.main.async {
                    self.sendLocationsToStream(stream: outStream)
                }
            }
            
        default:
            break
        }
    }

    
    
    func sendCachedLocations() {
        var stream: Unmanaged<CFWriteStream>?
        CFStreamCreatePairWithSocketToHost(nil, LocationsSocketIP as CFString, UInt32(LocationsSocketPort), nil, &stream)
        let outStream: OutputStream? = stream?.takeRetainedValue()
        outStream?.delegate = self
        outStream?.schedule(in: RunLoop.current, forMode: .defaultRunLoopMode)
        outStream?.open()
    }

    
    func sendLocationsToStream(stream: OutputStream){
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
            let res = data.withUnsafeBytes { stream.write($0, maxLength: data.count) }
            print("write to stream with res:", res)
        }catch let error{
            print(error.localizedDescription)
            stream.close()
            return
        }
        
        locations = []
        stream.close()
    }
}

