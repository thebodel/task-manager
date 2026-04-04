//
//  TasksListView.swift
//  frontend
//
//  Created by Bohdan on 04/04/2026.
//


import SwiftUI

struct TasksListView: View {
    let project: Project

    @State private var tasks: [TaskItem] = []
    @State private var isLoading = false
    @State private var errorMessage: String?

    var body: some View {
        Group {
            if isLoading {
                ProgressView("Loading tasks...")
            } else if let errorMessage {
                VStack(spacing: 12) {
                    Text("Error")
                        .font(.title2)
                        .bold()

                    Text(errorMessage)
                        .multilineTextAlignment(.center)

                    Button("Retry") {
                        Task {
                            await loadTasks()
                        }
                    }
                }
                .padding()
            } else if tasks.isEmpty {
                Text("No tasks in this project")
                    .foregroundStyle(.secondary)
            } else {
                List(tasks) { task in
                    VStack(alignment: .leading, spacing: 6) {
                        Text(task.title)
                            .font(.headline)

                        if let description = task.description,
                           !description.isEmpty {
                            Text(description)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }

                        HStack {
                            Text("Status: \(task.status)")
                            Text("Priority: \(task.priority)")
                        }
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    }
                    .padding(.vertical, 4)
                    .contextMenu {
                        Button {
                            print("Edit task \(project.id)\(task.id)")
                        } label: {
                            Label("Edit", systemImage: "pencil")
                        }

                        Button(role: .destructive) {
                            print("Delete task \(task.id) in  \(project.id)")
                            Task {
                                do {
                                    try await APIService.shared.deleteTask(projectId: project.id, taskId: task.id)
                                    tasks.removeAll { $0.id == task.id }
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
        .navigationTitle(project.title)
        .task {
            await loadTasks()
        }
    }

    private func loadTasks() async {
        isLoading = true
        errorMessage = nil

        do {
            tasks = try await APIService.shared.fetchTasks(projectId: project.id)
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }
}
