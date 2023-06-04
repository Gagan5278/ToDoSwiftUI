//
//  CustomFilterView.swift
//  ToDoAppSimple
//
//  Created by Gagan Vishal  on 2023/06/04.
//

import SwiftUI

struct CustomFilterView<Content: View>: View {
    var content: ([ToDo], [ToDo]) -> Content
    @FetchRequest private var result: FetchedResults<ToDo>
    @Binding var filterDate: Date
    // MARK: - init
    init(filterDate: Binding<Date>, @ViewBuilder content: @escaping ([ToDo], [ToDo]) -> Content) {
        let calender = Calendar.current
        let startDay = calender.startOfDay(for: filterDate.wrappedValue)
        let endDate = calender.date(
            bySettingHour: 23,
            minute: 59,
            second: 59,
            of: startDay
        )
        
        let predicate = NSPredicate(format: "date >= %@ AND date <= %@", argumentArray: [startDay, endDate!])
        
        _result = FetchRequest<ToDo>(
            entity: ToDo.entity(),
            sortDescriptors: [
                NSSortDescriptor(
                    keyPath: \ToDo.date,
                    ascending: true
                )
            ],
            predicate: predicate
        )
        self.content = content
        self._filterDate = filterDate
    }
    
    var body: some View {
        content(filterTasks().0, filterTasks().1)
            .onChange(of: filterDate) { newValue in
                // Clear old predicate
                result.nsPredicate = nil
                
                let calender = Calendar.current
                let startDay = calender.startOfDay(for: newValue)
                let endDate = calender.date(
                    bySettingHour: 23,
                    minute: 59,
                    second: 59,
                    of: startDay
                )
                
                let predicate = NSPredicate(format: "date >= %@ AND date <= %@", argumentArray: [startDay, endDate!])
                
                // assign new predicate
                result.nsPredicate = predicate
                
            }
    }
    
    private func filterTasks() -> ([ToDo], [ToDo]) {
        let pendingTasks = result.filter { !$0.isCompleted}
        let completedTasks = result.filter { $0.isCompleted}
        return (pendingTasks, completedTasks)
    }
}

