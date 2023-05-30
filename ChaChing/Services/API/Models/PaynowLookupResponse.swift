//
//  PaynowLookupResponse.swift
//  ChaChing
//
//  Created by Shaan Walia on 23/5/23.
//

import Foundation

struct PaynowLookupResponse: Decodable {
    var name: String?
    var phoneNumber: String?
    var jwtToken: String?
}
