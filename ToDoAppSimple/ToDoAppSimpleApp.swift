//
//  ToDoAppSimpleApp.swift
//  ToDoAppSimple
//
//  Created by Gagan Vishal  on 2023/06/03.
//

import SwiftUI

@main
struct ToDoAppSimpleApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
