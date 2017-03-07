//
//  ViewController.swift
//  iBeaconExample
//
//  Created by JerryWang on 2017/3/6.
//  Copyright © 2017年 Jerrywang. All rights reserved.
//

import UIKit
import CoreLocation

let uuidString = "B0702880-A295-A8AB-F734-031A98A512DE"
let identifier = "MacAsBeacon"

class ViewController: UIViewController, CLLocationManagerDelegate {

    @IBOutlet weak var beaconInformationLabel: UILabel!
    
    @IBOutlet weak var stateLabel: UILabel!
    
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.delegate = self
        
        if CLLocationManager.isMonitoringAvailable(for: CLBeaconRegion.self){
            if CLLocationManager.authorizationStatus() != CLAuthorizationStatus.authorizedAlways{
                locationManager.requestAlwaysAuthorization()
            }
        }
        
    }
    
    @IBAction func monitorIBeacon(_ sender: UIButton) {
        
        if sender.currentTitle == "搜尋"{
            registerBeaconRegionWithUUID(uuidString: uuidString, identifier: identifier, isMonitor: true)
            sender.setTitle("暫停", for: .normal)
        }else{
            sender.setTitle("搜尋", for: .normal)
            registerBeaconRegionWithUUID(uuidString: uuidString, identifier: identifier, isMonitor: false)
        }
    }
    
    func registerBeaconRegionWithUUID(uuidString: String, identifier: String, isMonitor: Bool){
        
        let region = CLBeaconRegion(proximityUUID: UUID(uuidString: uuidString)!, identifier: identifier)
        region.notifyOnEntry = true //預設就是true
        region.notifyOnExit = true //預設就是true
        
        if isMonitor{
            locationManager.startMonitoring(for: region) //建立region後，開始monitor region
        }else{
            locationManager.stopMonitoring(for: region)
            locationManager.stopRangingBeacons(in: region)
            view.backgroundColor = UIColor.white
            beaconInformationLabel.text = "Beacon狀態"
            stateLabel.text = "是否在region內?"
        }
        
    }
    
    //開始monitor region後，呼叫此delegate函數
    func locationManager(_ manager: CLLocationManager, didStartMonitoringFor region: CLRegion) {
        //To check whether the user is already inside the boundary of a region
        //delivers the results to the location manager’s delegate "didDetermineState"
        manager.requestState(for: region)
    }
    
    //The location manager calls this method whenever there is a boundary transition for a region.
    func locationManager(_ manager: CLLocationManager, didDetermineState state: CLRegionState, for region: CLRegion) {
        if state == CLRegionState.inside{
            if CLLocationManager.isRangingAvailable(){
                manager.startRangingBeacons(in: (region as! CLBeaconRegion))
                stateLabel.text = "已在region中"
            }else{
                print("不支援ranging")
            }
        }else{
            manager.stopRangingBeacons(in: (region as! CLBeaconRegion))
            view.backgroundColor = UIColor.white
        }
    }
    
    //The location manager calls this method whenever there is a boundary transition for a region.
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        
        if CLLocationManager.isRangingAvailable(){
            manager.startRangingBeacons(in: (region as! CLBeaconRegion))
        }else{
            print("不支援ranging")
        }
        stateLabel.text = "進入region"
    }
    
    //The location manager calls this method whenever there is a boundary transition for a region.
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        manager.stopRangingBeacons(in: (region as! CLBeaconRegion))
        view.backgroundColor = UIColor.white
        stateLabel.text = "離開region"
    }
    
    func locationManager(_ manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], in region: CLBeaconRegion) {
        
        if (beacons.count > 0){
            if let nearstBeacon = beacons.first{
                
                var proximity = ""
                
                switch nearstBeacon.proximity {
                case CLProximity.immediate:
                    proximity = "Very close"
                    
                case CLProximity.near:
                    proximity = "Near"
                    
                case CLProximity.far:
                    proximity = "Far"
                    
                default:
                    proximity = "unknow"
                }
                
                beaconInformationLabel.text = "Proximity: \(proximity)\n Accuracy: \(nearstBeacon.accuracy) meter \n RSSI: \(nearstBeacon.rssi)"
                view.backgroundColor = UIColor.red
            }
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error.localizedDescription)
    }
    
    
    func locationManager(_ manager: CLLocationManager, monitoringDidFailFor region: CLRegion?, withError error: Error) {
        print(error.localizedDescription)
    }
    
    
    func locationManager(_ manager: CLLocationManager, rangingBeaconsDidFailFor region: CLBeaconRegion, withError error: Error) {
        print(error.localizedDescription)
    }

}

