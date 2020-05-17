//
//  DataController.swift
//  CoronaTracker
//
//  Created by Aaryan Kothari on 18/05/20.
//  Copyright © 2020 Aaryan Kothari. All rights reserved.
//


import Foundation
import CoreData

class DataController {
    
    lazy var persistentContainer : NSPersistentContainer = {
          return NSPersistentContainer(name: "CoronaTracker")
    }()
    
    var viewContext : NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    func load( completion:( () -> Void )? = nil ){
        persistentContainer.loadPersistentStores { (storeDescription, error) in
            guard error == nil else { fatalError(error!.localizedDescription) }
            completion?()
        }
    }
}
