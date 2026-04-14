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
   // https://task-manager-d6iv.onrender.com

    private let baseURL = "http://127.0.0.1:8000"

    struct APIError: LocalizedError {
        let statusCode: Int
        let message: String

        var errorDescription: String? {
            "HTTP \(statusCode): \(message)"
        }
    }

    func fetchProjects(userId: Int) async throws -> [Project] {
        guard let url = URL(string: "\(baseURL)/projects?user_id=\(userId)") else {
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
    
    
    func deleteProject(projectId: Int, userId: Int) async throws {
        guard let url = URL(string: "\(baseURL)/projects/\(projectId)?user_id=\(userId)") else {
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
    
    func createProject(projectTitle: String,projectDesctiphion: String,userId: Int) async throws {
        guard let url = URL(string: "\(baseURL)/projects") else {
                throw URLError(.badURL)
            }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body = ProjectCreate(
            title: projectTitle,
            description: projectDesctiphion,
            user_id: userId
        )

        request.httpBody = try JSONEncoder().encode(body)

        let (_, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              200..<300 ~= httpResponse.statusCode else {
            throw URLError(.badServerResponse)
        }
    }
    
    func updateProject(updateProject: ProjectUpdate,user_id: Int,project_id: Int) async throws{
        guard let url = URL(string: "\(baseURL)/projects/\(project_id)?user_id=\(user_id)")else {
                throw URLError(.badURL)
            }
        var request = URLRequest(url: url)
        
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(updateProject)

        let (_, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              200..<300 ~= httpResponse.statusCode else {
            throw URLError(.badServerResponse)
        }

    }
    
    func createTask(_ form: CreateTaskItem) async throws {
        guard let url = URL(string: "\(baseURL)/tasks") else {
                throw URLError(.badURL)
            }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        request.httpBody = try encoder.encode(form)
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }

        guard 200..<300 ~= httpResponse.statusCode else {
            let message = String(data: data, encoding: .utf8) ?? "Unknown server error"
            throw APIError(statusCode: httpResponse.statusCode, message: message)
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
    
    func createUser(form: UserCreate) async throws -> LoginResponse {
        guard let url = URL(string: "\(baseURL)/users") else {
                throw URLError(.badURL)
            }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(form)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }
        if !(200..<300).contains(httpResponse.statusCode) {
            if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let detail = json["detail"] as? String {
                throw NSError(
                    domain: "",
                    code: httpResponse.statusCode,
                    userInfo: [NSLocalizedDescriptionKey: detail]
                )
            } else {
                throw URLError(.badServerResponse)
            }
        }
        return try JSONDecoder().decode(LoginResponse.self, from: data)
    }
    func loginUser(form: UserCreate) async throws -> LoginResponse {
        guard let url = URL(string: "\(baseURL)/login") else {
                throw URLError(.badURL)
            }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(form)

        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }
        
        if !(200..<300).contains(httpResponse.statusCode) {
            if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let detail = json["detail"] as? String {
                throw NSError(
                    domain: "",
                    code: httpResponse.statusCode,
                    userInfo: [NSLocalizedDescriptionKey: detail]
                )
            } else {
                throw URLError(.badServerResponse)
            }
        }
        
        return try JSONDecoder().decode(LoginResponse.self, from: data)
    }
}
