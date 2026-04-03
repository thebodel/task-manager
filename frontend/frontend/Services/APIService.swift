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
        guard let url = URL(string: "\(baseURL)/projects") else {
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
}