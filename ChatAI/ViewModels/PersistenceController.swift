//
//  PersistenceController.swift
//  Prompt
//
//  Created by Karl Koch on 12/01/2023.
//

import CoreData
import WidgetKit

class PersistenceController {
    static let shared = PersistenceController()
    let container: NSPersistentCloudKitContainer
    
    private init() {
        container = NSPersistentCloudKitContainer(name: "MessageDataModel")
        container.loadPersistentStores(completionHandler: { (storeDescription, error ) in
            if let error = error as NSError? {
                print(error)
            }
            WidgetCenter.shared.reloadAllTimelines()
        })
        
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        try? container.viewContext.setQueryGenerationFrom(.current)
    }
}

