//
//  APIService.swift
//  frontend
//
//  Created by Bohdan on 03/04/2026.
//


import Foundation

final class APIService {
    static let shared = APIService()

    private init() {}

    private let baseURL = "http://127.0.0.1:8000"

    func fetchProjects() async throws -> [Project] {
        guard let url = URL(string: "\(baseURL)/projects/") else {
            throw URLError(.badURL)
        }

        let (data, response) = try await URLSession.shared.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse,
              200..<300 ~= httpResponse.statusCode else {
            throw URLError(.badServerResponse)
        }

        let decoder = JSONDecoder()
        return try decoder.decode([Project].self, from: data)
    }
    
    func deleteProject(projectId: Int) async throws {
        guard let url = URL(string: "\(baseURL)/projects/\(projectId)") else {
            throw URLError(.badURL)
        }

        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"

        let (_, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse,
              200..<300 ~= httpResponse.statusCode else {
            throw URLError(.badServerResponse)
        }
    }
    
    func createProject(projectTitle: String,projectDesctiphion: String) async throws {
        guard let url = URL(string: "\(baseURL)/projects") else {
                throw URLError(.badURL)
            }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body = ProjectCreate(
            title: projectTitle,
            description: projectDesctiphion
        )

        request.httpBody = try JSONEncoder().encode(body)

        let (_, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              200..<300 ~= httpResponse.statusCode else {
            throw URLError(.badServerResponse)
        }
    }
    
    func fetchTasks(projectId: Int) async throws -> [TaskItem] {
        guard let url = URL(string: "\(baseURL)/projects/\(projectId)/tasks") else {
            throw URLError(.badURL)
        }

        let (data, response) = try await URLSession.shared.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse,
              200..<300 ~= httpResponse.statusCode else {
            throw URLError(.badServerResponse)
        }

        let decoder = JSONDecoder()
        return try decoder.decode([TaskItem].self, from: data)
    }
    
    func deleteTask(projectId: Int,taskId: Int) async throws {
        guard let url = URL(string: "\(baseURL)/projects/\(projectId)/tasks/\(taskId)") else {
            throw URLError(.badURL)
        }

        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"

        let (_, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse,
              200..<300 ~= httpResponse.statusCode else {
            throw URLError(.badServerResponse)
        }
    }
}
