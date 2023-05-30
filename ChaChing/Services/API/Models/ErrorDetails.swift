//
//  ErrorDetails.swift
//  ChaChing
//
//  Created by Shaan Walia on 23/5/23.
//

import Foundation
struct ErrorDetails: Decodable, Error {
    var errorCode: String?
    var message: String?
}
