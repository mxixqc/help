//
//  MakeTransactionResponse.swift
//  ChaChing
//
//  Created by Shaan Walia on 24/5/23.
//

import Foundation

struct MakeTransactionResponse: Codable{
    let id: String
    let name: String
    let balance: String
    let phoneNumber: String
}
