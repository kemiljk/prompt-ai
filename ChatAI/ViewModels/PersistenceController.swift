//
//  PersistenceController.swift
//  Prompt
//
//  Created by Karl Koch on 12/01/2023.
//

import CoreData

struct PersistenceController {
    static let shared = PersistenceController()
    let container: NSPersistentContainer
    
    init() {
        container = NSPersistentContainer(name: "Message")
        container.loadPersistentStores(completionHandler: { (storeDescription, error ) in
            if let error = error as NSError? {
                print(error)
            }
        })
    }
}
