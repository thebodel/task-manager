//
//  TaskItem.swift
//  frontend
//
//  Created by Bohdan on 03/04/2026.
//


import Foundation

struct TaskItem: Identifiable, Codable {
    let id: Int
    let title: String
    let description: String?
    let status: String
    let priority: String
    let deadline: String?
    let projectId: Int
    let createdAt: String
    let updatedAt: String

    enum CodingKeys: String, CodingKey {
        case id
        case title
        case description
        case status
        case priority
        case deadline
        case projectId = "project_id"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}
struct CreateTaskItem: Codable {
    var title: String
    var description: String
    var status: String
    var priority: String
    var deadline: Date?
    var projectId: Int

    enum CodingKeys: String, CodingKey {
        case title
        case description
        case status
        case priority
        case deadline
        case projectId = "project_id"
    }
}
