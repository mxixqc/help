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
    var dateTime: String
    
    public func getDate() -> String{
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSS"
        inputFormatter.timeZone = TimeZone(abbreviation: "GMT")

        
        let outputFormatter = DateFormatter()
        outputFormatter.dateFormat = "dd MMM yy, h:mm:ssa"
        outputFormatter.timeZone = TimeZone(abbreviation: "GMT")

        
        if let date = inputFormatter.date(from: self.dateTime){
            let calendar = Calendar.current

            let updatedDate = calendar.date(byAdding: .hour, value: 8 , to: date)
            if let updatedDate = updatedDate {
                let formattedDate = outputFormatter.string(from: updatedDate)
                return formattedDate
            }
        }
        return ""
    }
    
    public func getStringAmount() -> String{
        return String(format: "%.2f", self.amount)
    }
    
    
}
