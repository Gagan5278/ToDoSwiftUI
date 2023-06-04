//
//  Home.swift
//  ToDoAppSimple
//
//  Created by Gagan Vishal  on 2023/06/03.
//

import SwiftUI

struct Home: View {
    @State private var filterDate: Date = .init()
    @State private var isPendingExpandedGroup: Bool = true
    @State private var isCompletedExpandedGroup: Bool = true
    @Environment(\.managedObjectContext) private var viewContext
    
    var body: some View {
        List {
            DatePicker(selection: $filterDate, displayedComponents: .date) {
                Text("Hi")
            }
            .labelsHidden()
            .datePickerStyle(.graphical)
            CustomFilterView( filterDate: $filterDate) { pendingTasks, completedTasks in
                DisclosureGroup(isExpanded: $isPendingExpandedGroup) {
                    if pendingTasks.isEmpty {
                        sectionHeader(items: pendingTasks, isPending: true)
                    } else {
                        ForEach(pendingTasks) { task in
                            TaskRow(
                                task: task,
                                isPendingTask: true
                            )
                        }
                    }
                } label: {
                    sectionHeader(items: pendingTasks, isPending: true)
                }
                
                DisclosureGroup(isExpanded: $isCompletedExpandedGroup) {
                    if completedTasks.isEmpty {
                        sectionHeader(items: completedTasks, isPending: false)
                    } else {
                        ForEach(completedTasks) { task in
                            TaskRow(
                                task: task,
                                isPendingTask: false
                            )
                        }
                    }
                } label: {
                    sectionHeader(items: completedTasks, isPending: false)
                }
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
    
    func sectionHeader(items: [ToDo], isPending: Bool) -> some View {
        let titleEmpty = isPending ? "No Pending Taks found" : "No Completed Tasks found"
        let titleFilled = isPending ? "Total Pending Tasks: \(items.count)" : "Total Completed Tasks: \(items.count)"
        let title = items.isEmpty ? titleEmpty : titleFilled
        
        return  Text(title)
            .font(.caption)
            .foregroundColor(.gray)
    }
}

struct Home_Previews: PreviewProvider {
    static var previews: some View {
        Home().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}

