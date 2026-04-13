//
//  ProjectsListView.swift
//  frontend
//
//  Created by Bohdan on 03/04/2026.
//


import SwiftUI

struct ProjectsListView: View {
    @Environment(\.dismiss) private var dismiss

    let userId:Int
    @State private var projects: [Project] = []
    @State private var isLoading = false
    @State private var errorMessage: String?

    @State private var isCreatingProject = false
    @State private var newProjectTitle = ""
    @State private var newProjectDescription = ""

    var body: some View {
        VStack {
                }
        .navigationBarBackButtonHidden(true)
                .toolbar {
                    ToolbarItem(placement: .navigation) {
                        Button {
                            dismiss()
                        } label: {
                            Image(systemName: "rectangle.portrait.and.arrow.forward")
                        }
                    }
                }
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
                                    await loadProjects(userId: userId)
                                }
                            }
                        }
                        .padding()
                    } else if projects.isEmpty {
                        Text("No projects yet")
                            .foregroundStyle(.secondary)
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
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
                                        Button(){
                                            
                                        }
                                        label: {
                                            Label("Edit", systemImage: "pencil")
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
                        Color.black.opacity(0.4)
                            .ignoresSafeArea()
                            .onTapGesture {
                                closeCreateProjectWindow()
                            }

                        VStack(alignment: .leading, spacing: 16) {
                            TextField("New Task", text: $newProjectTitle)
                                .textFieldStyle(.plain)
                                .font(.system(size: 28, weight: .semibold))
                                .padding(.horizontal, 18)
                                .padding(.top, 18)

                            TextField("Notes", text: $newProjectDescription, axis: .vertical)
                                .textFieldStyle(.plain)
                                .font(.system(.title3, weight: .medium))
                                .foregroundStyle(.secondary)
                                .padding(.horizontal, 18)
                                .padding(.top, 10)
                                .padding(.bottom, 10)
                            

                            HStack {
                                Button("Cancel") {
                                    closeCreateProjectWindow()
                                }

                                Spacer()

                                Button("Save") {
                                    Task {
                                        await createProject(
                                            projectTitle: newProjectTitle,
                                            projectDesctiphion: newProjectDescription,
                                            userId: userId
                                        )
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
                await loadProjects(userId: userId)
            }
        }
    }

    private func loadProjects(userId: Int) async {
        isLoading = true
        errorMessage = nil

        do {
            projects = try await APIService.shared.fetchProjects(userId: userId)
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
            let taskIds = try await APIService.shared.fetchTasks(projectId: project.id).map(\.id)
            for id in taskIds {
                try await APIService.shared.deleteTask(projectId: project.id, taskId: id)
            }
            try await APIService.shared.deleteProject(projectId: project.id, userId: userId)
            withAnimation(.easeInOut(duration: 0.2)) {
                projects.removeAll { $0.id == project.id }
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    private func createProject(projectTitle: String,projectDesctiphion: String,userId:Int) async {
        do {
            try await APIService.shared.createProject(
                projectTitle: projectTitle,
                projectDesctiphion: projectDesctiphion,
                userId: userId
            )
            await loadProjects(userId: userId)
            closeCreateProjectWindow()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

#Preview {
    ProjectsListView(userId: 50)
        .frame(width: 500,height: 200)
}
