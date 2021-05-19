//
//  CoreData.swift
//  Special Order Keeper
//
//  Created by Kevin Green on 12/7/18.
//  Copyright © 2018 com.kevinGreen. All rights reserved.
//

import CoreData
import UIKit


private let entityName = "SpecialOrder"
private let managedContext = AppDelegate.getAppDelegate().persistentContainer.viewContext


/// Querys core data for an entity containing the name parameter.
///
/// - Parameters:
///   - name: The name of the entitie in which to query for.
///   - Returns: Returns true if an entity already exists with the same name, case sensitive; false otherwise.
func entityExists(for name: String) -> Bool {
    var queryExists = false
    guard let entityDescription = NSEntityDescription.entity(forEntityName: entityName, in: managedContext) else { return false }
    let request: NSFetchRequest<SpecialOrder> = SpecialOrder.fetchRequest()
    request.predicate = NSPredicate(format: "name == %@", name)
    request.entity = entityDescription
    do {
        let results = try managedContext.fetch(request)
        if results.count > 0 { queryExists = true }
    }
    catch {
        print("Error querying core data: \(error)")
        return queryExists
    }
    print("Query exists")
    return queryExists
}


/// Query's core data for all the entity objects.
///
/// - Parameters:
///   - sort: The sort type to sort the entities by.
///   - order: A bool indicating the order, Ascending or descending.
///   - Returns: An array of the stored entities as SpecialOrders.
func retrieveFromCoreData(sort: SortType, order: Bool) -> [SpecialOrder] {
    var _results = [SpecialOrder]()
    let sortDescriptors = NSSortDescriptor(key: sort.rawValue, ascending: order)

    if let entityDescription = NSEntityDescription.entity(forEntityName: entityName, in: managedContext) {
        let request: NSFetchRequest<SpecialOrder> = SpecialOrder.fetchRequest()
        request.sortDescriptors = [sortDescriptors]
        request.entity = entityDescription
        
        do {
            let results = try managedContext.fetch(request as! NSFetchRequest<NSFetchRequestResult>)
            if results.count > 0 {
                print("Core data retrieved")
                _results = results as! [SpecialOrder]
            } else {
                print("No core data match")
            }
        } catch let error {
            print("Error retrieving core data: \(error)")
        }
    }
    return _results
}


/// Saves core data.
///
/// - Returns: An error if one occured, otherwise nil.
func saveCoreData() -> Error? {
    do {
        try managedContext.save()
        print("Core data saved")
        return nil
    } catch let error {
        print("Error saving core data: \(error)")
        return error
    }
}


/// Deletes entity from core data.
///
/// - Parameters:
///   - entity: The entity to delete.
///   - returns: An Error object containing the error if deleting failed, nil otherwise.
func deleteFromCoreData(entity: NSManagedObject) -> Error? {
    do {
        let fetchedEntity = try managedContext.existingObject(with: entity.objectID)
        managedContext.delete(fetchedEntity)
        try managedContext.save()
        print("Entity deleted.")
    } catch let error {
        print("Error deleting entity: \(error)")
        return error
    }
    return nil
}







