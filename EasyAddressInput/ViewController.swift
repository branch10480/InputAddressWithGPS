//
//  ViewController.swift
//  EasyAddressInput
//
//  Created by ImaedaToshiharu on H28/06/15.
//  Copyright © 平成28年 ImaedaToshiharu All rights reserved.
//

import UIKit
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate {

    var lm:CLLocationManager
    var longitude: CLLocationDegrees
    var latitude: CLLocationDegrees
    
    // storyboardで関連づけるLabel
    @IBOutlet var latlonLabel: UILabel!
    @IBOutlet var addressLabel: UILabel!
    
    // CLLocationManagerDelegateを継承すると、init()が必要になる
    required init(coder aDecoder: NSCoder) {
        lm = CLLocationManager()
        longitude = CLLocationDegrees()
        latitude = CLLocationDegrees()
        super.init(coder: aDecoder)!
    }
    
    // ボタンが押された時の処理（storyboardで関連づける）
    @IBAction func btnGetLocation(sender: AnyObject) {
        // get latitude and longitude
        lm.startUpdatingLocation()
    }
    
    // 画面表示後の処理
    override func viewDidLoad() {
        super.viewDidLoad()
        
        lm = CLLocationManager()
        lm.delegate = self
        
        // セキュリティ認証のステータスを取得
        let status = CLLocationManager.authorizationStatus()
        
        // まだ認証が得られていない場合は、認証ダイアログを表示
        if status == CLAuthorizationStatus.NotDetermined {
            NSLog("didChangeAuthorizationStatus:\(status)")
            // まだ承認が得られていない場合は、認証ダイアログを表示
            self.lm.requestAlwaysAuthorization()
        }
        
        // 取得精度の設定
        lm.desiredAccuracy = kCLLocationAccuracyBest    // 最高精度
        // 取得頻度の設定（m:メートル）
        lm.distanceFilter = 1000
    }
    
    // 位置情報取得成功時
    func locationManager(manager: CLLocationManager, didUpdateToLocation newLocation: CLLocation, fromLocation oldLocation: CLLocation){
        
        longitude = newLocation.coordinate.longitude
        latitude = newLocation.coordinate.latitude
        self.latlonLabel.text = "\(longitude), \(latitude)"
        
        // get address
        CLGeocoder().reverseGeocodeLocation(manager.location!, completionHandler: {(placemarks, error)->Void in
            if error != nil {
                NSLog("Reverse geocoder failed with error\(error!.localizedDescription)")
                return
            }
            if placemarks!.count > 0 {
                let pm = placemarks![0] as CLPlacemark
                self.displayLocationInfo(pm)
                //stop updating location to save battery life
                self.lm.stopUpdatingLocation()
            } else {
                print("Problem with the data received from geocoder")
            }
        })
    }
    
    // 位置情報表示
    func displayLocationInfo(placemark: CLPlacemark) {
        var address: String = ""
        NSLog("\(placemark.addressDictionary)")
        let dic:NSDictionary = placemark.addressDictionary! as NSDictionary
        address += dic["State"] != nil ? dic["State"] as! String : ""
        address += " | "
        address += dic["City"] != nil ? dic["City"] as! String : ""
        address += " | "
        address += dic["Street"] != nil ? dic["Street"] as! String : ""
        self.addressLabel.text = address
    }
    
    // 位置情報取得失敗時
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        NSLog("Error while updating location. " + error.localizedDescription)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

