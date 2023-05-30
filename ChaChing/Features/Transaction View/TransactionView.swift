//
//  ContentView.swift
//  ChaChing
//
//  Created by GOAT on 22/5/23.
//

import SwiftUI
import Lottie

struct TransactionView: View {
    @Environment(\.dismiss) var dismiss
    @State private var showingSheet = true
    
    // TODO: Change Shafiq
    
    func login(){
//        Task{
//            do{
//                let result = try await APIService.shared.login(username: "Shafiq")
//                switch result {
//                case .success(let response):
//                    print(response)
//                case .failure(let errorDetails):
//                    print(errorDetails)
//                }
//
//            }
//        }
    }
    
    
    
    func fetchData(){
        Task{
            do{
                let result = try await APIService.shared.getTransactions()
                switch result {
                case .success(let response):
                    response.forEach{ transaction in
                        print(transaction)
                    }
                    for transaction in response {
                        print(transaction)
                    }
                case .failure(let errorDetails):
                    print(errorDetails)
                }
                
            }
        }
    }
    

    
    var transactions: [Transaction] = [
        .init(timestamp: "8:24:12 PM", payeeName: "Jin Daat", amount: "88.88"),
        .init(timestamp: "8:24:12 PM", payeeName: "Jin Daat", amount: "88.88"),
        .init(timestamp: "8:24:12 PM", payeeName: "Jin Daat", amount: "88.88"),
        .init(timestamp: "8:24:12 PM", payeeName: "Jin Daat", amount: "88.88"),
        .init(timestamp: "8:24:12 PM", payeeName: "Jin Daat", amount: "88.88")
    ]
    
    var body: some View {
        
//        Button(action: {
//            login()
//        }){
//            Text("Login")
//        }
//
//        Button(action: {
//            fetchData()
//        }){
//            Text("Print ")
//        }
        VStack {

            LottieView(lottieFile: "6567-scanning-nearby")
                .frame(width: 200, height: 200)
            AmountRecievedView()
            
            
                .padding(.bottom, 8)
            
//                List{
//                }

            }.sheet(isPresented: $showingSheet){
                TransactionList()
                    .presentationDetents([.fraction(0.45), .large])
//                    .presentationBackgroundInteraction(
//                        .enabled(upThrough: .large)
//                    )
                    .interactiveDismissDisabled(false)
            }
            .padding()
        
            .onAppear{
                fetchData()
            }
        
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        TransactionView()
    }
}
