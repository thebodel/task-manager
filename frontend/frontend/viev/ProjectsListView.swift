//
//  ProjectsListView.swift
//  frontend
//
//  Created by Bohdan on 03/04/2026.
//


import SwiftUI

struct ProjectsListView: View {
    @State private var projects: [Project] = []
    @State private var isLoading = false
    @State private var errorMessage: String?

    var body: some View {
        NavigationStack {
            Group {
                if isLoading {
                    ProgressView("Loading projects...")
                } else if let errorMessage {
                    VStack(spacing: 12) {
                        Text("Error")
                            .font(.title2)
                            .bold()

                        Text(errorMessage)
                            .multilineTextAlignment(.center)

                        Button("Retry") {
                            Task {
                                await loadProjects()
                            }
                        }
                    }
                    .padding()
                } else if projects.isEmpty {
                    Text("No projects yet")
                        .foregroundStyle(.secondary)
                } else {
                    List(projects) { project in
                        NavigationLink(destination: TasksListView(project: project)) {
                            VStack(alignment: .leading, spacing: 6) {
                                Text(project.title)
                                    .font(.headline)

                                if let description = project.description,
                                   !description.isEmpty {
                                    Text(description)
                                        .font(.subheadline)
                                        .foregroundStyle(.secondary)
                                }
                            }
                            .padding(.vertical, 4)
                            .contextMenu {
                                Button {
                                    print("Edit project \(project.id)")
                                } label: {
                                    Label("Edit", systemImage: "pencil")
                                }

                                Button(role: .destructive) {
                                    print("Delete project \(project.id)")
                                    Task {
                                        do {
                                            try await APIService.shared.deleteProject(projectId: project.id)
                                            projects.removeAll { $0.id == project.id }
                                        } catch {
                                            errorMessage = error.localizedDescription
                                        }
                                    }
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                        }
                    }
                    
                }
            }
            .navigationTitle("Projects")
            .task {
                await loadProjects()
            }
        }
    }

    private func loadProjects() async {
        isLoading = true
        errorMessage = nil

        do {
            projects = try await APIService.shared.fetchProjects()
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }
}
