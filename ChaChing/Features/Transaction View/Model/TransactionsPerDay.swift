//
//  TransactionDay.swift
//  ChaChing
//
//  Created by GOAT on 25/5/23.
//

import Foundation

struct TransactionsPerDay: Identifiable {
    let id = UUID()
    let title: String
    let transactions: [Transaction]
    let date: Date
}
