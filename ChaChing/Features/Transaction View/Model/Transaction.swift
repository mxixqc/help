//
//  Transaction.swift
//  ChaChing
//
//  Created by Esther Wee on 23/5/23.
//

import Foundation

struct Transaction: Codable, Identifiable{
    var id: UUID = UUID()
    var payer: String
    var payee: String
    var amount: Double
    var dateTime: Date
}
