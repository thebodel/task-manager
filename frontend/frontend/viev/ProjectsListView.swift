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

    @State private var isCreatingProject = false
    @State private var newProjectTitle = ""
    @State private var newProjectDescription = ""

    var body: some View {
        NavigationStack {
            ZStack {
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
                        List {
                            ForEach(projects) { project in
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
                                        Button(role: .destructive) {
                                            Task {
                                                await deleteProject(project)
                                            }
                                        } label: {
                                            Label("Delete", systemImage: "trash")
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                .blur(radius: isCreatingProject ? 4 : 0)

                if isCreatingProject {
                    ZStack {
                        Color.black.opacity(0.2)
                            .ignoresSafeArea()
                            .onTapGesture {
                                closeCreateProjectWindow()
                            }

                        VStack(alignment: .leading, spacing: 16) {
                            Text("New Project")
                                .font(.title3)
                                .fontWeight(.semibold)

                            TextField("Project title", text: $newProjectTitle)
                                .textFieldStyle(.roundedBorder)

                            TextField("Description", text: $newProjectDescription)
                                .textFieldStyle(.roundedBorder)

                            HStack {
                                Button("Cancel") {
                                    closeCreateProjectWindow()
                                }

                                Spacer()

                                Button("Save") {
                                    Task {
                                        //await saveProjectInline()
                                    }
                                }
                                .buttonStyle(.borderedProminent)
                                .disabled(newProjectTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                            }
                        }
                        .padding(20)
                        .frame(width: 360)
                        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
                        .shadow(color: .black.opacity(0.05), radius: 24, y: 12)
                        .transition(.scale(scale: 0.92).combined(with: .opacity))
                    }
                }
            }
            .navigationTitle("Projects")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        withAnimation(.easeInOut(duration: 0.25)) {
                            isCreatingProject = true
                        }
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
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

    private func closeCreateProjectWindow() {
        withAnimation(.easeInOut(duration: 0.25)) {
            isCreatingProject = false
        }

        newProjectTitle = ""
        newProjectDescription = ""
    }

    private func deleteProject(_ project: Project) async {
        do {
            try await APIService.shared.deleteProject(projectId: project.id)
            withAnimation(.easeInOut(duration: 0.2)) {
                projects.removeAll { $0.id == project.id }
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
