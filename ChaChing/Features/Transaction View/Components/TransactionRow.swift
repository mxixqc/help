//
//  TransactionRow.swift
//  ChaChing
//
//  Created by Johann Fong on 23/5/23.
//

import SwiftUI

struct TransactionRow: View {
    
    var transaction: Transaction
    
    let dateFormatter = DateFormatter()
    
        
    var body: some View {
        HStack(spacing: 8) {
            Text(dateFormatter.string(from:transaction.dateTime))
            Text(transaction.payee)
            Spacer()
            Text(String(transaction.amount))
                .foregroundColor(.green)
        }
        .frame(height: 50)
    }
}

//struct TransactionRow_Previews: PreviewProvider {
////    let transactionMock = Transaction(id: UUID(), timestamp: "ASD", payeeName: "ASD", amount: "123")
//
//    static var previews: some View {
//        TransactionRow(transaction: Transaction(id: UUID(), timestamp: "ASD", payeeName: "ASD", amount: "123"))
//    }
//}


