//
//  ContentView.swift
//  ChaChing
//
//  Created by GOAT on 22/5/23.
//

import SwiftUI
import Lottie

struct Peer: Identifiable, Hashable {
    var id: String
    var name: String
}

class RefreshAmount: ObservableObject {
    @Published var amount: String = "88.00"
}

struct TransactionView: View {
    @Environment(\.dismiss) var dismiss
    @State private var showingSheet = true
    @State private var showingPopUp = false
    @State private var isShowingContent = false
    @State private var isShowingRadar = true
    @AppStorage(Keys.username) private var username: String?
    @State var isLoading = true
    
    func getTransactions() {
        isLoading = true
        Task {
            do {
                let result = try await APIService.shared.getTransactions()
                switch result {
                case .success(let transactions):
                    sections = parseTransactions(transactions)
                    print(transactions)
                    isLoading = false
                case .failure(let errorDetails):
                    isLoading = false
                    print("Failed to retrieve data")
                }
            } catch {
                isLoading = false
                print("something went wrong")
            }
        }
    }
    
    func parseTransactions(_ transaction: [Transaction]) -> [TransactionsPerDay] {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        dateFormatter.dateFormat = "yyyy-MM-dd"
        var sortedTransactions = transaction.sorted { $0.getDate() > $1.getDate() }
        mostRecentTransaction = sortedTransactions.first

        
        let grouped = Dictionary(grouping: sortedTransactions) { (transaction: Transaction) ->
            // group by date
            Date? in
            return dateFormatter.date(from: String(transaction.dateTime.dropLast(16)))
        }
        
        return grouped.map { transactionsPerDay -> TransactionsPerDay in
            TransactionsPerDay(
                title: dateFormatter.string(from:transactionsPerDay.key!),
                transactions: transactionsPerDay.value,
                date: dateFormatter.date(from: String(transactionsPerDay.value[0].dateTime.dropLast(16)))!)
        }.sorted { $0.date > $1.date }
    }

    @ObservedObject var refreshAmount = RefreshAmount()
        
    let sections: [TransactionsPerDay]
        
    var body: some View {
        VStack {
            if isLoading {
                ProgressView()
            } else {
                VStack {
                ReceivedPayment(show: $isShowingContent)
                                     .onAppear {
                                         refreshAmount.amount = "78.00"
                                         self.isShowingRadar.toggle()
                                         Timer.scheduledTimer(withTimeInterval: 5, repeats: false) { timer in
                                             withAnimation(.easeInOut(duration: 0.5)) {
                                                 self.isShowingContent.toggle()
                                                 self.isShowingRadar.toggle()
                                                 
                                             }
                                         }
                                        
                                     }
                AmountRecievedView(amount: refreshAmount.amount)
            }.sheet(isPresented: $showingSheet){
                ZStack{
                    List {
                        ForEach(self.sections) { section in
                            Section(header: Text(section.title)) {
                                ForEach(section.transactions) { transaction in
                                    ZStack{
                                        TransactionRow(transaction: transaction)
                                        Button(action:
                                                {
                                            showingPopUp.toggle()
                                            self.name = transaction
                                        }, label: {
                                            Text("")
                                        })
                                        
                                    }
                                }
                            }
                        }
                    }.navigationBarTitle(Text("Events"))
                        .presentationDetents([.fraction(0.45), .large])
                        .presentationBackgroundInteraction(
                            .enabled(upThrough: .large)
                        )
                    //                    .interactiveDismissDisabled(true)
                    PopUpWindow(transactionDetails: name, show: $showingPopUp)
                }}}
            .onAppear {
                    getTransactions()
                }
                .padding()
        
        }
    }

//             }
//         }
//         .onAppear {
//             getTransactions()
//         }
//         .sheet(isPresented: $showingSheet){
//             List {
//                 ForEach(self.sections) { section in
//                     Section(header: Text(section.title)) {
//                         ForEach(section.transactions) { transaction in
//                             TransactionRow(transaction: transaction)
//                         }
//                     }
//                 }
//             }
//             .navigationBarTitle(Text("Events"))
//             .presentationDetents([.fraction(0.45), .large])
// //            .presentationBackgroundInteraction(
// //                .enabled(upThrough: .large)
// //            )
//             .interactiveDismissDisabled(false)
//         }
//         .padding()
    

    
    func startAdvertising() {
        Task {
            let response = try await APIService.shared.getAddress()
            MultipeerAdvertiserSession.shared.startAdvertisingPeer(peerID: response.addressToken)
            InAppNotificationManager.shared.setupNotifications()
            print("tftftfuyfv")
            self.isShowingContent = true
        }
    }

struct AmountRecievedView: View {
    @State var mostRecentTransaction: Transaction = .init(payer: "String", payee: "String", amount: 12.2, dateTime: "2023-05-29T07:09:13.285424")
    var body: some View {
        VStack{
            Text("Most Recent, \(mostRecentTransaction.getDate())")
                .font(.system(size: 12))
                .foregroundColor(.gray)
                .lineLimit(1)
                .padding([.top, .horizontal], 25)
            
            HStack(alignment: .bottom) {
                Text("\(mostRecentTransaction.getStringAmount())")
                    .font(.system(size: 42))
                    .foregroundColor(.green)
                
                Text("SGD")
                    .font(.system(size: 24))
                    .foregroundColor(.gray)
                    .padding(.bottom, 6)
            }
            .padding([.bottom], 20)
            .padding([.top], 5)
        }
        .background(.white)
        .cornerRadius(8)
        .shadow(radius: 8)
        Spacer()
    }
}

struct TransactionRow: View {
    var transaction: Transaction
    let dateFormatter = DateFormatter()
    
    var body: some View {
        HStack(spacing: 8) {
//            Text(dateFormatter.S)
            Text(transaction.payee)
            Spacer()
            Text(String(transaction.amount))
                .foregroundColor(.green)
        }
        .frame(height: 50)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        TransactionView()
    }
}
