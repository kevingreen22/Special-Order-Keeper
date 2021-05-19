//
//  String Constants.swift
//  Special Order Keeper
//
//  Created by Kevin Green on 12/7/18.
//  Copyright © 2018 com.kevinGreen. All rights reserved.
//

import Foundation
import UIKit

// MARK: - Protocols
protocol CellDelegate {
    func deleteEntity(from cell: Cell)
}



// MARK: - Enums

/// Sort descriptors for displaying sorted sets of special orders.
///
/// - client: Sort by client names.
/// - company: Sort by company names.
/// - datePlaced: Sort by the date jewelry order was placed by the client.
/// - dateCalled: Sort by the date the client was called back to notify them their jewelry is in stock.
public enum SortType: String {
    case client = "clientName"
    case company = "company"
    case datePlaced = "date"
    case dateCalled = "dateCalled"
}


enum CoreDataKeys: String {
    case clientName = "clientName"
    case phoneNumber = "phoneNumber"
    case depositAmount = "depositAmount"
    case company = "company"
    case jewelryDescription = "jewelryDescription"
    case date = "date"
    case dateOrdered = "dateOrdered"
    case dateCalled = "dateCalled"
    case refImage = "refImage"
}



// MARK: - Extentions
extension Date {
    
    /// Formats a date object to a string representations. With the specific options set.
    ///
    /// - Returns: A string representation of a date with the specifics.
    func myDateFormatted() -> String {
        let dfs = DateFormatter()
        dfs.dateStyle = .medium
        dfs.timeStyle = .none
        return dfs.string(from: self)
    }
    
}

extension UIView {
    
    /// Adds a shadow layer.
    func addShadow() {
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOpacity = 1
        self.layer.shadowOffset = CGSize.zero
        self.layer.shadowRadius = 10
        self.layer.shadowPath = UIBezierPath(rect: self.bounds).cgPath
        self.layer.shouldRasterize = false
    }
    
}



// MARK: - Segue static strings
struct Segues {
    static let addSpecialOrderSegue = "Add Special Order Segue"
    static let displaySpecialOrderSegue = "Display Special Order Segue"
}



