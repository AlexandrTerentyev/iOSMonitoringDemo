//
//  ViewController.swift
//  MonitoringDemo
//
//  Created by Aleksandr Terentev on 27.06.17.
//  Copyright © 2017 Aleksandr Terentev. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var sharingCodeField: UITextField!
    
    let monitoringManager = MonitoringManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        monitoringManager.sharingCode = sharingCodeField.text
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

extension ViewController: UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        monitoringManager.sharingCode = textField.text
        
        return true
    }
}

