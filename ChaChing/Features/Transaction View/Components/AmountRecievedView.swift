//
//  SwiftUIView.swift
//  ChaChing
//
//  Created by GOAT on 22/5/23.
//

import SwiftUI

struct AmountRecievedView: View {
    var body: some View {
        VStack(){
            VStack{
                Text("Most Recent, Received 23 Oct 2023, 4:09:00 PM")
                .font(.system(size: 12))
                .foregroundColor(.gray)
                .lineLimit(1)
                .padding([.top, .horizontal], 25)
            
                HStack(alignment: .bottom) {
                    Text("88.81")
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
            .padding()
            Spacer()
        }
        
        
    }
}

struct AmountRecievedView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            AmountRecievedView()
        }
    }
}
