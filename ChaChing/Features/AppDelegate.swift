//
//  AppDelegate.swift
//  ChaChing
//
//  Created by Johann Fong on 29/5/23.
//

import Foundation
import UserNotifications
import Combine
//import UIKit

class InAppNotificationManager: NSObject, UNUserNotificationCenterDelegate {
    static let shared = InAppNotificationManager()
//    var event = PassthroughSubject<Event, Never>()
    
    
    func setupNotifications() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { (_, _) in
        }
        UNUserNotificationCenter.current().delegate = self
        EventService.shared.listenForEvents { message in
            DispatchQueue.main.async {
                print("transaction made \(message)")
            }
        }
    }
    
}
