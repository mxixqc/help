//
//  APIService.swift
//  ChaChing
//
//  Created by Shaan Walia on 23/5/23.
//

import Foundation
import Combine
import os

class APIService {
    static var shared = APIService()
    
    private var baseURL: String = Config.baseURL
    private var username: String?
    private var phoneNumber: String?
    private let urlSession = URLSession.shared
    private let decoder = JSONDecoder()
    private let encoder = JSONEncoder()
    
    enum HTTPMethod: String {
        case get = "GET"
        case post = "POST"
    }
    
    private func saveAccessToken(_ token: String){
        Config.accessToken = token
    }
    
    func paynowLookup(phoneNumber: String) async throws -> Result<PaynowLookupResponse, ErrorDetails> {
        let request = createRequest(
            method: .post,
            endpoint: Paths.paynowLookup,
            body: try! encoder.encode(PaynowLookupRequest(phoneNumber: phoneNumber))
        )
        let result: Result<PaynowLookupResponse, ErrorDetails> = try await fetch(request)
        switch result{
        case .success(let lookupResponse):
            saveAccessToken(lookupResponse.jwtToken!)
        default:
            break
        }
        
        return result
    }


    func login(username: String) async throws -> Result<Credentials, ErrorDetails> {
        self.username = username
        let request = createRequest(method: .post, endpoint: Paths.login + "/\(username)")
        let result: Result<Credentials, ErrorDetails> = try await fetch(request)
        
        switch result {
        case .success(let credentials):
            saveAccessToken(credentials.accessToken)
        default:
            break
        }
        return result
    }
    
    private func createRequest(
        method: HTTPMethod = .get,
        endpoint: String,
        queryItems: [URLQueryItem]? = nil,
        body: Data? = nil
    ) -> URLRequest {
        var urlComponents = URLComponents(string: baseURL + endpoint)!
        if let queryItems = queryItems {
            urlComponents.queryItems = queryItems
        }
        
        var request = URLRequest(url: urlComponents.url!)
        request.httpMethod = method.rawValue
        if let body = body {
            request.httpBody = body
        }
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        if let token = Config.accessToken {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        return request
    }
    
    private func fetch<T>(_ request: URLRequest) async throws -> Result<T, ErrorDetails> where T: Decodable {
        Log.api("Fetching: \(String(describing: request.url?.absoluteString ?? ""))")
        Log.api("Fetching http Body: \(String(decoding: request.httpBody ?? Data(), as: UTF8.self))")
        let (data, urlResponse) = try await urlSession.data(for: request)
        
        guard let httpResponse = urlResponse as? HTTPURLResponse,
            httpResponse.statusCode == 200
        else {
            Log.api("Response Data: \(String(decoding: data, as: UTF8.self))")
            let errorDetails = try decoder.decode(ErrorDetails.self, from: data)
            guard let errorMessage = errorDetails.message else {
                return .failure(.init(message: "unknown error"))
            }
            return .failure(.init(message: errorMessage))
        }
        
        Log.api("Status Code: \(httpResponse.statusCode)")
        Log.api("Response Data: \(String(decoding: data, as: UTF8.self))")
        let responseObject = try decoder.decode(T.self, from: data)
        return .success(responseObject)
    }
    
    func getTransactions() async throws -> Result<[Transaction], ErrorDetails> {
        var request = createRequest(endpoint: Paths.transaction)
        return try await fetch(request)
    }
    
//    func login(username: String) async throws -> Bool {
//        let request = createRequest(method: .post, endpoint: Paths.login + "/\(username)")
//        let result: Result<Credentials, ErrorDetails> = try await fetch(request)
//
//        switch result {
//        case .success(let response):
//            saveAccessToken(response.accessToken)
//        case .failure(let errorDetails):
//            print(errorDetails)
//            return false
//        }
//
//        return true
//    }
    
    
    func makeTransaction(amount: Int, addressToken: String) async throws -> Result<MakeTransactionResponse, ErrorDetails> {
        var request = createRequest(method: .post, endpoint: Paths.transaction)
        let json: [String: Any] = [
            "token": addressToken,
            "value": amount
        ]
        request.httpBody = try? JSONSerialization.data(withJSONObject: json)
        return try await fetch(request)
    }
    
}
