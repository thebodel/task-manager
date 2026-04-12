//
//  user.swift
//  frontend
//
//  Created by Bohdan on 10/04/2026.
//
import Foundation

struct UserCreate: Codable {
    var login: String
    var password: String

}
struct LoginResponse: Codable {
    let userId: Int

    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
    }
}
