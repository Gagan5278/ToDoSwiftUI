//
//  Home.swift
//  ToDoAppSimple
//
//  Created by Gagan Vishal  on 2023/06/03.
//

import SwiftUI

struct Home: View {
    @State private var filterDate: Date = .init()
    @State private var isPendingExpandedGroup: Bool = false
    @State private var isCompletedExpandedGroup: Bool = false
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \ToDo.date, ascending: true)],
        animation: .default)
    private var items: FetchedResults<ToDo>

    var body: some View {
        List {
//            ForEach(items) { item in
//                Text(item.title ?? "sd" )
//            }
            DatePicker(selection: $filterDate, displayedComponents: .date) {
                Text("Hi")
            }
            .labelsHidden()
            .datePickerStyle(.graphical)
            
            DisclosureGroup(isExpanded: $isPendingExpandedGroup) {
                CustomFilterView(displayPendingTask: true, filterDate: filterDate) { task in
                    TaskRow(
                        task: task,
                        isPendingTask: true
                    )
                }
            } label: {
                Text("Pending Tasks")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            DisclosureGroup(isExpanded: $isCompletedExpandedGroup) {
                CustomFilterView(displayPendingTask: false, filterDate: filterDate) { task in
                    TaskRow(
                        task: task,
                        isPendingTask: false
                    )
                }
                
            } label: {
                Text("Completed Tasks")
                    .font(.caption)
                    .foregroundColor(.gray)
                
            }
        }
        .toolbar {
            ToolbarItem(placement: .bottomBar) {
                Button {
                    do {
                        let task = ToDo(context: viewContext)
                        task.id = .init()
                        task.title = ""
                        task.date = filterDate
                        task.isCompleted = false
                        
                        try viewContext.save()
                        isPendingExpandedGroup = true

                    } catch {
                        print("ERROR OCCUERED")
                        print(error.localizedDescription)
                    }
                    
                } label: {
                    HStack(spacing: 10) {
                        Image(systemName: "plus.app.fill")
                        Text("Add New Item")
                    }
                }
                .frame(
                    maxWidth: .infinity,
                    alignment: .leading
                )
            }
        }
    }
}

struct Home_Previews: PreviewProvider {
    static var previews: some View {
        Home().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}


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
            VStack {
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
                env.managedObjectContext.delete(task)
                saveContext()
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

