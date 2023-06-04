//
//  CustomFilterView.swift
//  ToDoAppSimple
//
//  Created by Gagan Vishal  on 2023/06/04.
//

import SwiftUI

struct CustomFilterView<Content: View>: View {
    var content: (ToDo) -> Content
    @FetchRequest private var result: FetchedResults<ToDo>
    // MARK: - init
    init(displayPendingTask: Bool, filterDate: Date, content: @escaping (ToDo) -> Content) {
        
        let calender = Calendar.current
        let startDay = calender.startOfDay(for: filterDate)
        let endDate = calender.date(
            bySettingHour: 23,
            minute: 59,
            second: 59,
            of: filterDate
        )
        
        let predicate = NSPredicate(format: "date >= %@ AND date <= %@ AND isCompleted != %@", (startDay as NSDate), (endDate! as NSDate), NSNumber(booleanLiteral: displayPendingTask))
        
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
    }
    
    var body: some View {
        Group {
            if result.isEmpty {
                Text("No Tasks found!")
                    .font(.caption)
                    .foregroundColor(.gray)
                    .listRowSeparator(.hidden)
            } else {
                ForEach(result) {
                    content($0)
                }
            }
        }
    }
}

