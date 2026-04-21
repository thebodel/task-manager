//
//  createTaskUI.swift
//  frontend
//
//  Created by Bohdan on 16/04/2026.
//

import SwiftUI

struct CreateTask: View {
    @Binding var newTask: CreateTaskItem
    @Binding var saveOrUpdate: Int
    @Binding var isPresented: Bool
    let taskId: Int
    let onClose: () -> Void
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
    
    @State private var errorMessage: String?

    @State private var showPicker_status = false
    @State private var showPicker_priority = false 
    var body: some View{
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
                        Task {
                            if saveOrUpdate == 0 {
                                print("save")
                            } else {
                                let updatedTask = TaskUpdate(
                                    title: newTask.title,
                                    description: newTask.description,
                                    status: newTask.status,
                                    priority: newTask.priority,
                                    deadline: newTask.deadline
                                )

                                await updateTask(
                                    updatedTask,
                                    projectId: newTask.projectId,
                                    taskId: taskId
                                )
                                print("update")
                            }
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
    
    private func closeCreateTaskWindow() {
        withAnimation(.easeInOut(duration: 0.25)) {
            isPresented = false
        }
        onClose()
        newTask = CreateTaskItem(
            title: "",
            description: "",
            status: "",
            priority: "",
            deadline: Date(),
            projectId: 0 // change
        )
    }
    
    private func updateTask(_ updateTask: TaskUpdate, projectId: Int, taskId: Int) async {
        do {
            try await APIService.shared.updateTask(updateTask: updateTask, project_id: projectId, task_id: taskId)
            closeCreateTaskWindow()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    private var modalBackgroundColor: Color {
#if os(macOS)
        Color(nsColor: .windowBackgroundColor)
#else
        Color(uiColor: .systemBackground)
#endif
    }  
    
}
#Preview {
    CreateTask(newTask: .constant(CreateTaskItem(
        title: "vvwv",
        description: "",
        status: "todo",
        priority: "",
        deadline: Date(),
        projectId: 0
    )),saveOrUpdate: .constant(0),isPresented: .constant(false), taskId: 0, onClose: {})
}
