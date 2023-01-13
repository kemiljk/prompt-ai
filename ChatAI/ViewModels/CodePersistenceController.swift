//
//  PersistenceController.swift
//  Prompt
//
//  Created by Karl Koch on 12/01/2023.
//

import CoreData

struct CodePersistenceController {
    static let shared = CodePersistenceController()
    let container: NSPersistentContainer
    
    init() {
        container = NSPersistentContainer(name: "CodeDataModel")
        container.loadPersistentStores(completionHandler: { (storeDescription, error ) in
            if let error = error as NSError? {
                print(error)
            }
        })
    }
}
