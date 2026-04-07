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
    @State private var isCreatingTask = false
    
    struct newTask {
          var newTaskTitle = ""
          var newTaskDescription = ""
          var newTaskStatus = ""
          var newTaskPriority = ""
          var newTaskDeadline = Date()
    }
    @State private var new_Task = newTask()

    var body: some View {
        ZStack {
            NavigationStack {
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
                                        await deleteTask(task)
                                    }
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                        }
                    }
                }
                .blur(radius: isCreatingTask ? 4 : 0)
                .navigationTitle(project.title)
                .toolbar {
                    ToolbarItem(placement: .primaryAction) {
                        Button {
                            withAnimation(.easeInOut(duration: 0.25)) {
                                isCreatingTask = true
                            }
                        } label: {
                            Image(systemName: "plus")
                        }
                    }
                }
                .task {
                    await loadTasks()
                }
                .toolbarBackgroundVisibility(.hidden, for: .windowToolbar)
            }
            
            if isCreatingTask {
                ZStack {
                    Color.black.opacity(0.35)
                        .ignoresSafeArea()
                        .onTapGesture {
                            closeCreateTaskWindow()
                        }

                    VStack(alignment: .leading, spacing: 0) {
                        TextField("New Task", text: $new_Task.newTaskTitle)
                            .textFieldStyle(.plain)
                            .font(.system(size: 28, weight: .semibold))
                            .padding(.horizontal, 18)
                            .padding(.top, 18)
                        
                        TextField("Notes", text: $new_Task.newTaskDescription, axis: .vertical)
                            .textFieldStyle(.plain)
                            .font(.system(.title3, weight: .medium))
                            .foregroundStyle(.secondary)
                            .padding(.horizontal, 18)
                            .padding(.top, 10)
                            .padding(.bottom, 10)
                        
                        
                        HStack {
                            Text("Status")
                                .foregroundStyle(.secondary)
                                .font(.system(size: 14, weight: .regular))
                                .padding(.horizontal, 18)
                            Spacer()
                            
                            Picker("", selection: $new_Task.newTaskStatus) {
                                Text("To do").tag("toDo")
                                Text("In progres").tag("inProgres")
                                Text("Complete").tag("complete")
                            }
                            .labelsHidden()
                            .pickerStyle(.menu)
                            .font(.system(size: 14, weight: .regular))
                            .padding(.horizontal, 10)
                            .padding(.vertical, 8)
                        }
                         .padding(.vertical, 5)
                        
                        HStack {
                            Text("Priority")
                                .foregroundStyle(.secondary)
                                .font(.system(size: 14, weight: .regular))
                                .padding(.horizontal, 18)
                            Spacer()

                            Picker("Priority", selection: $new_Task.newTaskPriority) {
                                Text("Low").tag("low")
                                Text("Medium    ").tag("medium")
                                Text("High").tag("high")
                            }
                            .labelsHidden()
                            .pickerStyle(.menu)
                            .font(.system(size: 14, weight: .regular))
                            .padding(.horizontal, 10)
                            .padding(.vertical, 8)
                            
                        }
                         .padding(.vertical, 5)

                        HStack {
                            DatePicker("Deadline", selection: $new_Task.newTaskDeadline, displayedComponents: [.date])
                                .datePickerStyle(.automatic)
                                .foregroundStyle(.secondary)
                                .font(.system(size: 14,weight: .regular))
                            
                        }
                        .padding(.horizontal, 18)
                        .padding(.vertical, 14)
                        
                        HStack {
                            Button("Cancel") {
                                closeCreateTaskWindow()
                            }

                            Spacer()

                            Button("Save") {
                                print("save task")
                            }
                            .buttonStyle(.borderedProminent)
                            .disabled(new_Task.newTaskTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty||new_Task.newTaskStatus.isEmpty||new_Task.newTaskPriority.isEmpty)
                        }
                        .padding(18)
                    }
                    .frame(width: 350)
                    .background(
                        RoundedRectangle(cornerRadius: 22, style: .continuous)
                            .fill(Color.white.opacity(0.88))
                    )
                    .shadow(color: .black.opacity(0.12), radius: 30, y: 12)
                    .transition(.scale(scale: 0.96).combined(with: .opacity))
                }
            }
        }
    }

    private func closeCreateTaskWindow() {
        withAnimation(.easeInOut(duration: 0.25)) {
            isCreatingTask = false
        }

        new_Task.newTaskStatus = ""
        new_Task.newTaskPriority = ""
        new_Task.newTaskDeadline = Date()
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

    private func deleteTask(_ task: TaskItem) async {
        do {
            try await APIService.shared.deleteTask(projectId: project.id, taskId: task.id)
            tasks.removeAll { $0.id == task.id }
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
