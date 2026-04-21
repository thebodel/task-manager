//
//  TasksListView.swift
//  frontend
//
//  Created by Bohdan on 04/04/2026.
//


import SwiftUI

struct TasksListView: View {
    @Environment(\.dismiss) private var dismiss
    
    enum Priority: String, CaseIterable, Identifiable {
        case low = "Low"
        case medium = "Medium"
        case high = "High"
        
        var id: String { rawValue }
    }
    enum Status: String, CaseIterable, Identifiable {
        case todo = "todo"
        case inProgress = "in_progress"
        case complete = "complete"
        
        var id: String { rawValue }

        var title: String {
            switch self {
            case .todo:
                return "To Do"
            case .inProgress:
                return "In Progress"
            case .complete:
                return "Complete"
            }
        }
    }
    
    
    let project: Project

    @State private var tasks: [TaskItem] = []
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var isCreatingTask = false
    @State private var isUpdateingTask = false
    @State private var selectedTaskId: Int?
    
    @State private var newTask = CreateTaskItem(
        title: "",
        description: "",
        status: "",
        priority: "",
        deadline: Date(),
        projectId: 0
    )
    
    @State private var showPicker_status = false
    @State private var showPicker_priority = false

    private static let deadlineParsers: [ISO8601DateFormatter] = {
        let withFractionalSeconds = ISO8601DateFormatter()
        withFractionalSeconds.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

        let standard = ISO8601DateFormatter()
        standard.formatOptions = [.withInternetDateTime]

        return [withFractionalSeconds, standard]
    }()


    var body: some View {
        VStack {
                }
        .navigationBarBackButtonHidden(true)
                .toolbar {
                    ToolbarItem(placement: .navigation) {
                        Button {
                            dismiss()
                        } label: {
                            Image(systemName: "arrow.uturn.backward")
                        }
                    }
                }
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
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
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
                                    print("Edit task \(project.id) \(task.id)")
                                    newTask = CreateTaskItem(
                                        title: task.title,
                                        description: task.description ?? "",
                                        status: task.status,
                                        priority: task.priority,
                                        deadline: deadline(from: task.deadline),
                                        projectId: task.projectId
                                    )
                                    selectedTaskId = task.id
                                    isUpdateingTask=true
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
#if os(macOS)
                .toolbarBackgroundVisibility(.hidden, for: .windowToolbar)
#endif
            }
            if isUpdateingTask, let selectedTaskId {
                CreateTask(
                    newTask: $newTask,
                    saveOrUpdate: .constant(1),
                    isPresented: $isUpdateingTask,
                    taskId: selectedTaskId,
                    onClose: {
                        Task {
                            await loadTasks()
                        }
                    }
                )
            }
            
            if isCreatingTask {
                ZStack {
                    Color.black.opacity(0.35)
                        .ignoresSafeArea()
                        .onTapGesture {
                            closeCreateTaskWindow()
                        }

                    VStack(alignment: .leading, spacing: 0) {
                        TextField("New Task", text: $newTask.title)
                            .textFieldStyle(.plain)
                            .font(.system(size: 28, weight: .semibold))
                            .padding(.horizontal, 18)
                            .padding(.top, 18)
                        
                        TextField("Notes", text: $newTask.description, axis: .vertical)
                            .textFieldStyle(.plain)
                            .font(.system(.title3, weight: .medium))
                            .foregroundStyle(.secondary)
                            .padding(.horizontal, 18)
                            .padding(.top, 10)
                            .padding(.bottom, 10)
                        
                        
                        HStack{
                            Button {
                                showPicker_status.toggle()
                            } label: {
                                HStack(spacing: 1) {
                                    Image(systemName: "list.bullet.clipboard.fill")
                                        .foregroundStyle(.secondary)
                                        .frame(width: 24)
                                    
                                    Text("Status")
                                        .foregroundStyle(.secondary)
                                        .font(.system(size: 14, weight: .regular))
                                    
                                    Spacer()
                                    
                                    Text(Status(rawValue: newTask.status)?.title ?? "")
                                        .foregroundStyle(.secondary)
                                        .font(.system(size: 14, weight: .regular))
                                  
                                    Image(systemName: "chevron.up.chevron.down")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                        .padding(.horizontal,10)
                                }
                                .contentShape(Rectangle())
                             }
                            .buttonStyle(.plain)
                            .popover(isPresented: $showPicker_status) {
                                 VStack(alignment: .leading, spacing: 0) {
                                    ForEach(Status.allCases) { option in
                                        Button {
                                            newTask.status = option.rawValue
                                            showPicker_status = false
                                        } label: {
                                            HStack {
                                                if newTask.status == option.rawValue {
                                                    Image(systemName: "checkmark")
                                                        .font(.callout)
                                                        .fontWeight(.semibold)
                                                        .foregroundStyle(.primary)
                                                        .frame(width: 20)
                                                } else {
                                                    Color.clear.frame(width: 20)
                                                }

                                                Text(option.title)
                                                    .foregroundStyle(.primary)
                                                    .frame(maxWidth: .infinity, alignment: .leading)
                                            }
                                            .padding(.horizontal, 16)
                                            .padding(.vertical, 10)
                                            .contentShape(Rectangle())
                                        }
                                        .buttonStyle(.plain)
                                    }
                                }
                                .padding(.vertical, 6)
                                .frame(minWidth: 220)
                            }
        
                    }.padding(.horizontal, 14)
                     .padding(.vertical, 14)
                    
                        
                        HStack{
                            Button {
                                showPicker_priority.toggle()
                            } label: {
                                HStack(spacing: 1) {
                                    Image(systemName: "bell.fill")
                                        .foregroundStyle(.secondary)
                                        .frame(width: 24)
                                    
                                    Text("Priority")
                                        .foregroundStyle(.secondary)
                                        .font(.system(size: 14, weight: .regular))
                                    
                                    Spacer()
                                    
                                    Text(newTask.priority.prefix(1).uppercased() + newTask.priority.dropFirst())
                                        .foregroundStyle(.secondary)
                                        .font(.system(size: 14, weight: .regular))
                                  
                                    Image(systemName: "chevron.up.chevron.down")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                        .padding(.horizontal,10)
                                }
                                .contentShape(Rectangle())
                             }
                            .buttonStyle(.plain)
                            .popover(isPresented: $showPicker_priority) {
                                 VStack(alignment: .leading, spacing: 0) {
                                    ForEach(Priority.allCases) { option in
                                        Button {
                                            newTask.priority = option.rawValue.lowercased()
                                            showPicker_priority = false
                                        } label: {
                                            HStack {
                                                if newTask.priority == option.rawValue.lowercased(){
                                                    Image(systemName: "checkmark")
                                                        .font(.callout)
                                                        .fontWeight(.semibold)
                                                        .foregroundStyle(.primary)
                                                        .frame(width: 20)
                                                } else {
                                                    Color.clear.frame(width: 20)
                                                }

                                                Text(option.rawValue)
                                                    .foregroundStyle(.primary)
                                                    .frame(maxWidth: .infinity, alignment: .leading)
                                            }
                                            .padding(.horizontal, 16)
                                            .padding(.vertical, 10)
                                            .contentShape(Rectangle())
                                        }
                                        .buttonStyle(.plain)
                                    }
                                }
                                .padding(.vertical, 6)
                                .frame(minWidth: 220)
                            }
        
                    }.padding(.horizontal, 14)
                     .padding(.vertical, 14)
                    
                        HStack {
                            DatePicker("Deadline", selection: Binding(
                                get: { newTask.deadline ?? Date() },
                                set: { newTask.deadline = $0 }
                            ), displayedComponents: [.date])
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
                                Task{
                                   await createTask()
                                }
                            }
                            .buttonStyle(.borderedProminent)
                            .disabled(newTask.title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || newTask.status.isEmpty || newTask.priority.isEmpty)
                        }
                        .padding(18)
                    }
                    .frame(width: 350)
                    .background(
                        RoundedRectangle(cornerRadius: 22, style: .continuous)
                            .fill(modalBackgroundColor.opacity(0.96))
                    )

                    .shadow(color: .black.opacity(0.06), radius: 18, y: 8)
                    .transition(.scale(scale: 0.96).combined(with: .opacity))
                }
            }
        }
    }

    private var modalBackgroundColor: Color {
#if os(macOS)
        Color(nsColor: .windowBackgroundColor)
#else
        Color(uiColor: .systemBackground)
#endif
    }

    private func closeCreateTaskWindow() {
        withAnimation(.easeInOut(duration: 0.25)) {
            isCreatingTask = false
        }
        newTask = CreateTaskItem(
            title: "",
            description: "",
            status: "",
            priority: "",
            deadline: Date(),
            projectId: project.id
        )
    }

    private func deadline(from value: String?) -> Date? {
        guard let value, !value.isEmpty else {
            return nil
        }

        for parser in Self.deadlineParsers {
            if let date = parser.date(from: value) {
                return date
            }
        }

        return nil
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
    private func createTask() async {
        do {
            var form = newTask
            form.projectId = project.id
            try await APIService.shared.createTask(form)
            await loadTasks()
            closeCreateTaskWindow()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
