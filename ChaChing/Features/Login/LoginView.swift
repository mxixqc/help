//
//  LoginView.swift
//  ChaChing
//
//  Created by Shaan Walia on 25/5/23.
//

import SwiftUI


struct LoginView: View {


    @State private var phoneNumber: String = "91234567"
    @State private var isSignedIn: Bool = false
    @State private var failedSignIn: Bool = false
    @State private var buttonColor = Color.blue
    @State private var requestInProgress = false
    @State private var allTransactions: [Transaction] = []
    
    private func getTransactionData(){
        Task{
            do {
                let result = try await APIService.shared.getTransactions()
                switch result {
                case .success(let success):
                    allTransactions = success
                case .failure(let failure):
                    print(failure)
                    print("Didn't retrieve data")
                }

            }
        }
    }
    
    private func signIn(){
        requestInProgress = true
        Task{
            do{
                let result = try await APIService.shared.paynowLookup(phoneNumber: phoneNumber)
                switch result {
                case .success(let response):
                    isSignedIn = true
                    print(response)
                    requestInProgress = false
                    getTransactionData()
                    print("Logged in Successfully!")
                case .failure(let errorDetails):
                    print("Unable to Log In")
                    requestInProgress = false

                }

            }
        }
    }
    
    struct LoginButton: View{
        var requestInProgress: Bool
        var signIn: () -> Void
        var body: some View{
            if requestInProgress{
                ProgressView()
            } else{
                Button("Sign In", action: signIn)
            }

        }
    }
    
    var body: some View {
        NavigationView{
            VStack{
                
                TextField(
                    
                    "Please enter your phone number",
                    text: $phoneNumber
                    
                )
                .padding([.leading])
                .keyboardType(.numberPad)
                
                LoginButton(
                    requestInProgress: requestInProgress,
                    signIn: signIn
                )
                    
                NavigationLink(destination: TransactionView(), isActive: $isSignedIn){
                    EmptyView()
                }
                .hidden()
            }

        }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
