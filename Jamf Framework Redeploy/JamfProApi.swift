//
//  JamfProApi.swift
//  Jamf Framework Redeploy
//
//  Created by Richard Mallion on 10/01/2023.
//

import Foundation

struct JamfProAPI {
    
    var username: String
    var password: String
    
    var base64Credentials: String {
        return "\(username):\(password)"
            .data(using: String.Encoding.utf8)!
            .base64EncodedString()
    }
    
    func getToken(jssURL: String, base64Credentials: String) async -> (JamfAuth?,Int?) {
        guard var jamfAuthEndpoint = URLComponents(string: jssURL) else {
            return (nil, nil)
        }
        
        jamfAuthEndpoint.path="/api/v1/auth/token"

        guard let url = jamfAuthEndpoint.url else {
            return (nil, nil)
        }

        var authRequest = URLRequest(url: url)
        authRequest.httpMethod = "POST"
        authRequest.setValue("Basic \(base64Credentials)", forHTTPHeaderField: "Authorization")
        
        guard let (data, response) = try? await URLSession.shared.data(for: authRequest)
        else {
            return (nil, nil)
        }
        
        let httpResponse = response as? HTTPURLResponse
        
        do {
            let jssToken = try JSONDecoder().decode(JamfAuth.self, from: data)
            return (jssToken, httpResponse?.statusCode)
        } catch _ {
            return (nil, httpResponse?.statusCode)
        }
    }
    
    func getComputerID(jssURL: String, base64Credentials: String, serialNumber: String) async -> (Int?,Int?) {
        guard var jamfcomputerEndpoint = URLComponents(string: jssURL) else {
            return (nil, nil)
        }
        
        jamfcomputerEndpoint.path="/JSSResource/computers/serialnumber/\(serialNumber)"

        guard let url = jamfcomputerEndpoint.url else {
            return (nil, nil)
        }

        
        var computerRequest = URLRequest(url: url)
        computerRequest.httpMethod = "GET"
        computerRequest.setValue("Basic \(base64Credentials)", forHTTPHeaderField: "Authorization")
        computerRequest.setValue("application/json", forHTTPHeaderField: "Accept")
        
        guard let (data, response) = try? await URLSession.shared.data(for: computerRequest)
        else {
            return (nil, nil)
        }
        let httpResponse = response as? HTTPURLResponse
        do {
            let computer = try JSONDecoder().decode(Computer.self, from: data)
            return (computer.computer.general.id, httpResponse?.statusCode)
        } catch _ {
            return (nil, httpResponse?.statusCode)
        }
    }
    

    func redeployJamfFramework(jssURL: String, authToken: String, computerID: Int) async -> Int? {
        guard var jamfRedeployEndpoint = URLComponents(string: jssURL) else {
            return nil
        }
        
        jamfRedeployEndpoint.path="/api/v1/jamf-management-framework/redeploy/\(computerID)"
        
        guard let url = jamfRedeployEndpoint.url else {
            return nil
        }
        
        var redeployRequest = URLRequest(url: url)
        redeployRequest.httpMethod = "POST"
        redeployRequest.setValue("Bearer \(authToken)", forHTTPHeaderField: "Authorization")
        redeployRequest.setValue("application/json", forHTTPHeaderField: "Accept")
        
        guard let (_, response) = try? await URLSession.shared.data(for: redeployRequest)
        else {
            return nil
        }
        
        let httpResponse = response as? HTTPURLResponse
        return httpResponse?.statusCode
    }
}

// MARK: - Jamf Pro Auth Model
struct JamfAuth: Decodable {
    let token: String
    let expires: String
}

struct Computer: Codable {
    let computer: ComputerDetail
}

// MARK: - Computer Model
struct ComputerDetail: Codable {
    let general: General

    enum CodingKeys: String, CodingKey {
        case general
    }
}

struct General: Codable {
    let id: Int
    enum CodingKeys: String, CodingKey {
        case id
    }
}

