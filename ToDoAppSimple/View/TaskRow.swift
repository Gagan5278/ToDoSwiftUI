//
//  TaskRow.swift
//  ToDoAppSimple
//
//  Created by Gagan Vishal  on 2023/06/04.
//

import SwiftUI

struct TaskRow:  View {
    let task: ToDo
    let isPendingTask: Bool
    @Environment(\.self) private var env
    @FocusState private var showKeyboard: Bool
    var body: some View {
        HStack {
            Button {
                task.isCompleted.toggle()
                saveContext()
            } label: {
                Image(
                    systemName:
                        isPendingTask ?  "circle" : "checkmark.circle.fill"
                )
                .font(.title)
                .foregroundColor(.blue)
            }
            .buttonStyle(.plain) // Only allows tap on Button not on whole view
            VStack(alignment: .leading) {
                TextField("Task Title", text: .init(get: {
                    return task.title ?? ""
                }, set: { title in
                    task.title = title
                }))
                .focused($showKeyboard)
                .onSubmit {
                    if (task.title ?? "").isEmpty {
                        env.managedObjectContext.delete(task)
                    }
                    saveContext()
                }
                .foregroundColor(isPendingTask ? .primary : .gray)
                .strikethrough(!isPendingTask, pattern: .dash, color: .gray)
                DatePicker("Selected Date", selection: .init(get: {
                    return task.date ?? .init()
                }, set: { date in
                    task.date = date
                    saveContext()
                }), displayedComponents: [.hourAndMinute])
                .labelsHidden()
            }
        }
        .onAppear {
            if (task.title ?? "").isEmpty {
                showKeyboard = true
            }
        }
        /// In case user move to background without entering any data
        .onChange(of: env.scenePhase) { newValue in
            if newValue == .active {
                if (task.title ?? "").isEmpty {
                    env.managedObjectContext.delete(task)
                }
                saveContext()
            }
        }
        /// Swipe To delete
        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
            Button {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    env.managedObjectContext.delete(task)
                    saveContext()
                }
            } label: {
                Image(systemName: "trash.fill")
            }
        }
    }
    
    private func saveContext() {
        do {
            try env.managedObjectContext.save()
        } catch {
            print(error.localizedDescription)
        }
    }
}
