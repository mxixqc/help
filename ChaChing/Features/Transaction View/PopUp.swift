//
//  PopUp.swift
//  ChaChing
//
//  Created by GOAT on 25/5/23.
//

import SwiftUI

struct PopUpWindow: View {
    var title: String
    var message: String
    var buttonText: String
    @Binding var show: Bool
    var body: some View {
        ZStack {
            if show {
                // PopUp background color
//                Color.black.opacity(show ? 0.3 : 0).edgesIgnoringSafeArea(.all)
                // PopUp Window
                VStack(spacing: 0) {
                    Text(message)
                        .multilineTextAlignment(.center)
                        .font(Font.system(size: 16, weight: .semibold))
                        .padding(EdgeInsets(top: 20, leading: 25, bottom: 20, trailing: 25))
                        .background(Color.white)
                        .foregroundColor(Color.gray)
                    Button(action: {
                        // Dismiss the PopUp
                        withAnimation(.linear(duration: 0.3)) {
                            show = false
                        }
                    }, label: {
                        Text(buttonText)
//                            .frame(maxWidth: .infinity)
//                            .frame(height: 54, alignment: .center)
                            .foregroundColor(Color.black)
//                            .background(Color(#colorLiteral(red: 0.6196078431, green: 0.1098039216, blue: 0.2509803922, alpha: 1)))
//                            .font(Font.system(size: 23, weight: .semibold))
                    }).buttonStyle(PlainButtonStyle())
                }
//                .frame(maxWidth: 300)
//                .border(Color.white, width: 2)
//                .background(Color.gray)
            }
        }.frame(maxWidth: 300)
            .border(Color.white, width: 2)
            .background(Color.gray)
    }
}

