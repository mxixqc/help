//
//  ReceivedPayment.swift
//  ChaChing
//
//  Created by Johann Fong on 29/5/23.
//

import SwiftUI

struct ReceivedPayment: View {
    @Binding var show: Bool
    var body: some View {
        if show {
//            Color.black.opacity(show ? 0.3 : 0).edgesIgnoringSafeArea(.all)
            LottieView(lottieFile: "98628-money-gift")
                .frame(width: 200, height: 200)
                .padding()

            
            
        }
    }
}
