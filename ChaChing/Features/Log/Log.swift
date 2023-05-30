//
//  Log.swift
//  ChaChing
//
//  Created by Shaan Walia on 23/5/23.
//

import Foundation
import os

struct Log {
    private static var logger = Logger()

    static func api(_ message: String) {
        logger.info("API_LOG: \(message, privacy: .public)")
    }

    static func blePeripheral(_ message: String) {
        logger.info("BLE_PERIPHERAL_LOG: \(message, privacy: .public)")
    }

    static func bleCentral(_ message: String) {
        logger.info("BLE_CENTRAL_LOG: \(message, privacy: .public)")
    }

    static func events(_ message: String) {
        logger.info("EVENT_LOG: \(message, privacy: .public)")
    }

    static func view(_ message: String) {
        logger.info("VIEW_LOG: \(message, privacy: .public)")
    }
}
