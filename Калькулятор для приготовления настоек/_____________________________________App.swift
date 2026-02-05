//
//  _____________________________________App.swift
//  Калькулятор для приготовления настоек
//
//  Created by Anton Samatov on 05.02.26.
//

import SwiftUI
import CoreData

@main
struct _____________________________________App: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
