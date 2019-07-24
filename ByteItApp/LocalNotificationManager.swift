//
//  LocalNotificationManager.swift
//  ByteItApp
//
//  Created by Shardul Sapkota on 7/15/19.
//  Copyright © 2019 fluid. All rights reserved.
//

import UIKit
import CoreLocation
import UserNotifications
import AVFoundation

//class LocalNotificationManager: UIViewController,  UNUserNotificationCenterDelegate, CLLocationManagerDelegate{
class LocalNotificationManager: UIViewController,  UNUserNotificationCenterDelegate{

    //speech syntehsizer
    var speechSynthesizer = AVSpeechSynthesizer()
    var speechUtterance: AVSpeechUtterance = AVSpeechUtterance()
//    let locationManager = CLLocationManager()

    
    let appDelegate = UIApplication.shared.delegate as? AppDelegate

    override func viewDidLoad() {
        super.viewDidLoad()
//        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters // less batery ussage
//        locationManager.pausesLocationUpdatesAutomatically = false
//        locationManager.allowsBackgroundLocationUpdates = true
//        locationManager.requestAlwaysAuthorization()

        //        // Do any additional setup after loading the view.
//        locationManager.startUpdatingLocation()
    }
    
    var notifications = [Notification]()
    
    struct Notification {
        var id:String
        var title:String
        var datetime:DateComponents
        var date:Date
        var location:CLLocationCoordinate2D
        var timeBool: Bool
        var placeBool: Bool
    }
    
    func listScheduledNotifications()
    {
        UNUserNotificationCenter.current().getPendingNotificationRequests { notifications in
            
            for notification in notifications {
                print(notification)
            }
        }
    }
    
    private func requestAuthorization()
    {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            
            if granted == true && error == nil {
                self.scheduleNotifications()
            }
        }
    }
    
    func schedule()
    {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            
            switch settings.authorizationStatus {
            case .notDetermined:
                self.requestAuthorization()
            case .authorized, .provisional:
                self.scheduleNotifications()
            default:
                break // Do nothing
            }
        }
    }
    
    private func timeNotification(notification: Notification){
        
        print("Scheduling time based notification")
        
        let content      = UNMutableNotificationContent()
        content.title    = notification.id
        content.body     = notification.title
        content.sound    = .default
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: notification.datetime, repeats: false)
        
        let request = UNNotificationRequest(identifier: notification.id, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            
            guard error == nil else { return }
            
            print("Notification scheduled! --- ID = \(notification.id)")
        }
    }
    
    
   private func placeNotification(notification: Notification){
        
        print("Scheduling location based notification")
        
        let content      = UNMutableNotificationContent()
        content.title    = notification.id
        content.body     = notification.title

        let center = (notification.location)
        let region = CLCircularRegion(center: center, radius: 100, identifier: notification.id)
        region.notifyOnEntry = true
        region.notifyOnExit = true

        let triggerLoc = UNLocationNotificationTrigger(region: region, repeats: false)

        let requestLoc = UNNotificationRequest(identifier: notification.id, content: content, trigger: triggerLoc)

        UNUserNotificationCenter.current().add(requestLoc) { error in

            guard error == nil else { return }

            print("Notification scheduled! --- ID = \(notification.id)")
        }
        
    }
    
    @objc func foo(){
        print("NONSENSE")
    }
    
    private func scheduleNotifications()
    {
        for notification in notifications
        {
            
            if (notification.timeBool) && !(notification.placeBool){
                timeNotification(notification: notification)
            }
            if !(notification.timeBool) && (notification.placeBool){
                placeNotification(notification: notification)
            }
            
            if (notification.timeBool) && (notification.placeBool){
                
                print("Scheduling both timer and location based notification in \(notification.date.timeIntervalSinceNow)")
                
                DispatchQueue.main.async {
                    // timer needs a runloop?
                    let timerStart = Timer.scheduledTimer(withTimeInterval: notification.date.timeIntervalSinceNow,
                                                     repeats: false) {
                                                        timerStart in
                                                        //Put the code that be called by the timer here.
                       self.placeNotification(notification: notification)
                    }
                    
                    
                    let timerRemove = Timer.scheduledTimer(withTimeInterval: (notification.date.timeIntervalSinceNow + 60*5),
                                                     repeats: false) {
                                                        timerRemove in
                                                        //Put the code that be called by the timer here.
                                UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [notification.id])
                    }
                    
                }


                
//                RunLoop.current.add(timer, forMode: .commonModes)


//                print(notification.datetime)
//
//                let timer = Timer.scheduledTimer(withTimeInterval: notification.date.timeIntervalSinceNow, repeats: false){_ in
//                    self.placeNotification(notification: notification)
//                }
                
                
//                let timer = Timer.scheduledTimer(withTimeInterval: notification.date.timeIntervalSinceNow, repeats: false, block: {timer in self.placeNotification(notification: notification)})
//
                
//                let timer = Timer(fireAt: timeInterval as Date, interval: 0, target: self, selector: #selector(placeNotification(notification:notification)), userInfo: nil, repeats: false)
//            RunLoop.main.add(timer, forMode: .common)
            }
            
            if !(notification.timeBool) && !(notification.placeBool){
                continue
            }
            
        }
    }
}

    
    
    
        

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */


extension LocalNotificationManager {
    
//        func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void)
//        {
//            let id = response.notification.request.identifier
//            print("Received notification with ID = \(id)")
//            
//           
//            let utterance = AVSpeechUtterance(string:  response.notification.request.content.title)
//            utterance.voice = AVSpeechSynthesisVoice(language: "en-gb")
//            self.speechSynthesizer.speak(utterance)
//            
//            completionHandler()
//        }
//    
//    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void)
//        { //notification in the foreground
//            
//            let id = notification.request.identifier
//            print("Received notification with ID = \(id)")
//    
//            let utterance = AVSpeechUtterance(string:  notification.request.content.title)
//            utterance.voice = AVSpeechSynthesisVoice(language: "en-gb")
//            self.speechSynthesizer.speak(utterance)
//
//            
//            completionHandler([.sound, .alert])
//        }
//    
}
