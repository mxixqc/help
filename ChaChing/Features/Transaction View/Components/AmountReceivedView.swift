//
//  SwiftUIView.swift
//  ChaChing
//
//  Created by Esther Wee on 22/5/23.
//

import Foundation
import SwiftUI

//extension String {
//    func toDate(dateFormat: String) -> Date? {
//        let dateFormatter = DateFormatter()
//        dateFormatter.dateFormat = dateFormat
//
//        let date: Date? = dateFormatter.date(from: self)
//        return date
//    }
//
//}

//let recentTransaction : Transaction? = transactions.first
//
//let recentTransaction :Transaction? = transactions.first
//
//let recentDate = recentTransaction?.dateTime ?? nil
//let dateStr = recentDate.toDate(dateFormat: "yyyy-MM-dd'T'HH:mm:ss.SSSSSS") ?? Date()
//let recentAmount = recentTransaction?.amount ?? 0






struct SwiftUIView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            AmountRecievedView(recentTransaction: Transaction(payer: "Jin Daat", payee: "Economic Rice", amount: 10.00, dateTime: Date()))
        }
    }
}
