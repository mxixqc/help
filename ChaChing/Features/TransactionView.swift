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
    @ObservedObject var refreshAmount = RefreshAmount()
    
    @State var name: Transaction = Transaction(payer: "Jin Daat", payee: "Economic Rice", amount: 10.00, dateTime: Date())
    
    let sections: [TransactionsPerDay]
    
    init() {
//        @ObservedObject var refreshAmount: RefreshAmount
//        var lol  = "897"
//        self.refreshAmount.amount = lol
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        dateFormatter.dateFormat = "dd MMMM yyyy"
        
        let mockDate: Date = dateFormatter.date(from: "23 May 2023") ?? Date()
//        let recentDate: Date = Date()
        

        let allTransactions: [Transaction] = [
            .init(payer: "Johann", payee: "Economic Rice", amount: 10.00, dateTime: mockDate),
            .init(payer: "Shaan", payee: "Economic Rice", amount: 10.00, dateTime: mockDate),
            .init(payer: "Esther", payee: "Economic Rice", amount: 10.00, dateTime: mockDate),
            .init(payer: "Jin Daat", payee: "Economic Rice", amount: 10.00, dateTime: mockDate),
            .init(payer: "Jin Daat", payee: "Economic Rice", amount: 10.00, dateTime: mockDate),
            .init(payer: "Test", payee: "Rice", amount: 10.00, dateTime: Date()),
            .init(payer: "Jin Daat", payee: "Economic Rice", amount: 10.00, dateTime: Date()),
            .init(payer: "Jin Daat", payee: "Economic Rice", amount: 10.00, dateTime: Date()),
            
        ].sorted { $0.dateTime < $1.dateTime }
        
        let grouped = Dictionary(grouping: allTransactions) { (transaction: Transaction) -> String in
            dateFormatter.string(from: transaction.dateTime)
        }

        self.sections = grouped.map { transactionsPerDay -> TransactionsPerDay in
            TransactionsPerDay(title: transactionsPerDay.key, transactions: transactionsPerDay.value, date: transactionsPerDay.value[0].dateTime)
        }.sorted { $0.date > $1.date }
    }
    
    var body: some View {
        
        ZStack{
            VStack {
                SearchingCustomer(show: $isShowingRadar)
                ReceivedPayment(show: $isShowingContent)
                                     .onAppear {
                                         refreshAmount.amount = "78.00"
                                         self.isShowingRadar.toggle()
                                         Timer.scheduledTimer(withTimeInterval: 5, repeats: false) { timer in
                                             withAnimation(.easeInOut(duration: 0.5)) {
                                                 self.isShowingContent.toggle()
                                                 self.isShowingRadar.toggle()
//                                                 refreshAmount.amount = "78.00"
                                                 
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
                    setup()
                }
                .padding()
        
    }
        
    func setup(){
        Task {
            let result = try await APIService.shared.login(username: "Shafiq")
            switch result {
            case .success:
                startAdvertising()
            case .failure:
                print("failure")
            }
        }
    }
        
    
    func startAdvertising() {
        Task {
            let response = try await APIService.shared.getAddress()
            MultipeerAdvertiserSession.shared.startAdvertisingPeer(peerID: response.addressToken)
            InAppNotificationManager.shared.setupNotifications()
            print("tftftfuyfv")
            self.isShowingContent = true
            
        }
    }
}

struct AmountRecievedView: View {
    var amount: String = ""
    var body: some View {
        VStack{
            Text("Most Recent, Received 23 Oct 2023, 4:09:00 PM")
                .font(.system(size: 12))
                .foregroundColor(.gray)
                .lineLimit(1)
                .padding([.top, .horizontal], 25)
            
            HStack(alignment: .bottom) {
                Text(amount)
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
            Text(dateFormatter.string(from:transaction.dateTime))
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
