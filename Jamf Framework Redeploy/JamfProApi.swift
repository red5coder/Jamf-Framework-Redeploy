//
//  JamfProApi.swift
//  Jamf Framework Redeploy
//
//  Created by Richard Mallion on 10/01/2023.
//

import Foundation

struct JamfProAPI {
    
//    var username: String
//    var password: String
//    
//    var base64Credentials: String {
//        return "\(username):\(password)"
//            .data(using: String.Encoding.utf8)!
//            .base64EncodedString()
//    }
    
    func getToken(jssURL: String, clientID: String, secret: String ) async -> (JamfOAuth?,Int?) {
        guard var jamfAuthEndpoint = URL(string: jssURL) else {
            return (nil, nil)
        }
        
        jamfAuthEndpoint.append(path: "/api/oauth/token")

        let parameters = [
            "client_id": clientID,
            "grant_type": "client_credentials",
            "client_secret": secret
        ]


//        guard let url = jamfAuthEndpoint.url else {
//            return (nil, nil)
//        }

        var authRequest = URLRequest(url: jamfAuthEndpoint)
        authRequest.httpMethod = "POST"
        authRequest.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        let postData = parameters.map { key, value in
            return "\(key)=\(value)"
        }.joined(separator: "&")
        authRequest.httpBody = postData.data(using: .utf8)

        guard let (data, response) = try? await URLSession.shared.data(for: authRequest)
        else {
            return (nil, nil)
        }
        
        let httpResponse = response as? HTTPURLResponse
        do {
            let jssToken = try JSONDecoder().decode(JamfOAuth.self, from: data)
            return (jssToken, httpResponse?.statusCode)
        } catch _ {
            return (nil, httpResponse?.statusCode)
        }
    }
    
    
    //1.0.2 Change
    func getComputerID(jssURL: String, authToken: String, serialNumber: String) async -> (Int?,Int?) {
        guard var jamfcomputerEndpoint = URLComponents(string: jssURL) else {
            return (nil, nil)
        }
        
        jamfcomputerEndpoint.path="/JSSResource/computers/serialnumber/\(serialNumber)"

        guard let url = jamfcomputerEndpoint.url else {
            return (nil, nil)
        }

        
        var computerRequest = URLRequest(url: url)
        computerRequest.httpMethod = "GET"
        computerRequest.setValue("Bearer \(authToken)", forHTTPHeaderField: "Authorization")
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
struct JamfOAuth: Decodable {
    let access_token: String
    let expires_in: Int
    enum CodingKeys: String, CodingKey {
        case access_token
        case expires_in
    }
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

