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

class LocalNotificationManager: UIViewController,  UNUserNotificationCenterDelegate {
    
    //speech syntehsizer
    var speechSynthesizer = AVSpeechSynthesizer()
    var speechUtterance: AVSpeechUtterance = AVSpeechUtterance()

    
    let appDelegate = UIApplication.shared.delegate as? AppDelegate

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    var notifications = [Notification]()
    
    struct Notification {
        var id:String
        var title:String
        var datetime:DateComponents
        var location:CLLocationCoordinate2D
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
    
    private func scheduleNotifications()
    {
        for notification in notifications
        {
            let content      = UNMutableNotificationContent()
            content.title    = notification.title
            content.sound    = .default
            
            let trigger = UNCalendarNotificationTrigger(dateMatching: notification.datetime, repeats: false)
            
            let request = UNNotificationRequest(identifier: notification.id, content: content, trigger: trigger)
            
            UNUserNotificationCenter.current().add(request) { error in
                
                guard error == nil else { return }
                
                print("Notification scheduled! --- ID = \(notification.id)")
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

}


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
