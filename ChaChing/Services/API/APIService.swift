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

    func login(username: String) async throws -> Result<Credentials, ErrorDetails> {
        self.username = username
        let request = createRequest(method: .post, endpoint: Paths.login + "/\(username)")
        let result: Result<Credentials, ErrorDetails> = try await fetch(request: request)
        
        switch result {
        case .success(let credentials):
            Config.accessToken = credentials.accessToken
        default:
            break
        }
        return result
    }
    
    private func save(token: String) {
        Config.accessToken = token
    }
    
    func login2(username: String) async throws -> Bool {
        self.username = username
        let request = createRequest(method: .post, endpoint: Paths.login + "/\(username)")
        let credentials: Credentials = try await fetch2(request: request)
        save(token: credentials.accessToken)
        return true
    }
    
    func getAddress() async throws -> Address {
        let request = createRequest(endpoint: Paths.address)
        return try await fetch2(request: request)
    }
    
    struct GetPayeeRequest: Codable {
        let token: String
    }
    
    func getPayee(address: String) async throws -> PayeeResponse {
        let request = createRequest(
            method: .post,
            endpoint: Paths.payee,
            body: try! encoder.encode(GetPayeeRequest(token: address))
        )
        return try await fetch2(request: request)
    }
    
    private func pay(_ amount: Decimal, to address: String) async throws -> PayResponse {
        let request = createRequest(
            method: .post,
            endpoint: Paths.transaction,
            body: try! encoder.encode(PayRequest(token: address, value: amount))
        )
        return try await fetch2(request: request)
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
    
    
    private func fetch2<T>(request: URLRequest) async throws -> T where T: Decodable {
        Log.api("Fetching: \(String(describing: request.url?.absoluteString ?? ""))")
        Log.api("Fetching http Body: \(String(decoding: request.httpBody ?? Data(), as: UTF8.self))")
        let (data, urlResponse) = try await urlSession.data(for: request)
        guard
            let httpResponse = urlResponse as? HTTPURLResponse,
            httpResponse.statusCode == 200
        else {
            Log.api("Bad Response: \(urlResponse)")
            throw URLError(.badServerResponse)
        }
        Log.api("Status Code: \(httpResponse.statusCode)")
        Log.api("Response Data: \(String(decoding: data, as: UTF8.self))")
        return try decoder.decode(T.self, from: data)
    }
    
    private func fetch<T>(request: URLRequest) async throws -> Result<T, ErrorDetails> where T: Decodable {
        Log.api("Fetching: \(String(describing: request.url?.absoluteString ?? ""))")
        Log.api("Fetching http Body: \(String(decoding: request.httpBody ?? Data(), as: UTF8.self))")
        let (data, urlResponse) = try await urlSession.data(for: request)
        
        guard
            let httpResponse = urlResponse as? HTTPURLResponse,
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

}
