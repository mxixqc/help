//
//  EventService.swift
//  ChaChing
//
//  Created by Johann Fong on 29/5/23.
//

import EventSource
import Foundation

class EventService {
    static let shared = EventService()
    
    var eventSource: EventSource!
    let serverURL = URL(string: "\(Config.baseURL)/api/v1/notifications")!
    var onPaymentRecieved: ((_ message: String) -> Void)?
//    var onPaymentRecieved: true

    func listenForEvents(onPaymentRecieved: @escaping ((_ message: String) -> Void)) {
        print("creating SSE")
        self.onPaymentRecieved = onPaymentRecieved
        guard let token = Config.accessToken else {
            Log.events("No bearer token, Unable to create SSE connection")
            return
        }
        
        eventSource = EventSource(url: serverURL, headers: ["Authorization": "Bearer \(token)"])
        eventSource.addEventListener("transaction") { id, event, data in
            guard let onPaymentRecieved = self.onPaymentRecieved else {
                Log.events("No onPaymentRecieved function")
                return
            }
            guard let message = data else {
                Log.events("No message")
                return
            }
            onPaymentRecieved(message)
        }
        eventSource.onOpen {
            Log.events("CONNECTED")
        }
        eventSource.onComplete { statusCode, reconnect, error in
            Log.events("DISCONNECTED - statusCode: \(String(describing: statusCode)) reconnect: \(String(describing: reconnect)) error: \(String(describing: error))")
        }
        eventSource.connect()
        return
    }
}
