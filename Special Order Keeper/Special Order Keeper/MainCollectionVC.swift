//
//  MainCollectionVC.swift
//  Special Order Keeper
//
//  Created by Kevin Green on 12/7/18.
//  Copyright © 2018 com.kevinGreen. All rights reserved.
//

import UIKit
import CoreData



private let cellReuseIdentifier = "Orders Cell"

class MainCollectionVC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, CellDelegate {
    
    // MARK: - Instance Variables
    
    var specialOrders: [SpecialOrder] = []
    var sort: SortType = .client
    var order: Bool = false
    
    
    
    // MARK: - Outlets
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    

    // MARK: - Actions
    
    ///  Sets the filter variable.
    ///
    /// - Parameter sender: The segment thats been tapped.
    @IBAction func sortSegmentTapped(_ sender: UISegmentedControl) {
        let segmentName = sender.titleForSegment(at: sender.selectedSegmentIndex)
        switch segmentName {
        case "Client Name":  sort = SortType.client
        case "Company": sort = SortType.company
        case "Date Placed": sort = SortType.datePlaced
        case "Date Called": sort = SortType.dateCalled
        default: sort = SortType.client
        }
        specialOrders = retrieveFromCoreData(sort: sort, order: order)
        collectionView.reloadSections(NSIndexSet(index: 0) as IndexSet)
    }
    
    /// Sets the sort variable.
    ///
    /// - Parameter sender: The segment thats been tapped.
    @IBAction func orderSegmentTapped(_ sender: UISegmentedControl) {
        let segmentName = sender.titleForSegment(at: sender.selectedSegmentIndex)
        switch segmentName {
        case "Old - New": order = false
        case "New - Old": order = true
        default: order = false
        }
        specialOrders = retrieveFromCoreData(sort: sort, order: order)
        collectionView.reloadSections(NSIndexSet(index: 0) as IndexSet)
    }
    

    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.leftBarButtonItem = editButtonItem
    }
    
    override func viewWillAppear(_ animated: Bool) {
        specialOrders = retrieveFromCoreData(sort: sort, order: order) // Get current special orders from core data and puts it into a variable.
        collectionView.reloadData()
    }

    

    // MARK: - UICollectionViewDataSource
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return specialOrders.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellReuseIdentifier, for: indexPath) as? Cell else { return UICollectionViewCell() }
        let order = specialOrders[indexPath.row]
        cell.nameLabel.text = order.clientName //.value(forKey: "clientName") as? String
        cell.descriptionLabel.text = order.jewelryDescription //.value(forKey: "jewelryDescription") as? String
        
        if let date = order.date { //.value(forKey: "date") as? Date) {
            cell.dateLabel.text = date.myDateFormatted()
        }
        
        if let date = order.dateOrdered?.myDateFormatted() { //.value(forKey: "dateOrdered") as? Date)?.myDateFormatted() {
            cell.dateOrderedLabel.text = date
            cell.dateOrderedLabel.textColor = UIColor(red:0.04, green:0.56, blue:0.04, alpha:1.0)
        } else {
            cell.dateOrderedLabel.text = "Not Ordered Yet"
            cell.dateOrderedLabel.textColor = .red
        }
        
        if let date = order.dateCalled?.myDateFormatted() { // }.value(forKey: "dateCalled") as? Date)?.myDateFormatted() {
            cell.calledBackLabel.text = date
            cell.calledBackLabel.textColor = UIColor(red:0.04, green:0.56, blue:0.04, alpha:1.0)
        } else {
            cell.calledBackLabel.text = "Not Called Back"
            cell.calledBackLabel.textColor = .red
        }
        
        if let company = order.company {
            cell.companyLabel.text = company
        } else {
            cell.companyLabel.text = ""
        }
        
        cell.deleteButton.isHidden = true
        cell.delegate = self
        
        return cell
    }
    
    
    
    // MARK: - Protocol CellDelegate
    
    /// Deletes a cell from core data and removes the cell from the collection view.
    ///
    /// - Parameter cell: The Cell to be deleted.
    func deleteEntity(from cell: Cell) {
        guard let indexPath = collectionView.indexPath(for: cell) else { return }
        let entity = specialOrders[indexPath.row]
        if let error = deleteFromCoreData(entity: entity) {
            let alert = UIAlertController(title: "Error Deleting", message: error.localizedDescription, preferredStyle: .alert)
            let ok = UIAlertAction(title: "Ok", style: .default, handler: nil)
            alert.addAction(ok)
            present(alert, animated: true, completion: nil)
        } else {
            specialOrders = retrieveFromCoreData(sort: sort, order: order)
            collectionView.deleteItems(at: [indexPath])
        }
    }
    
    
    
    // MARK: - UICollectionViewCell Editing
    
    /// For editing the collectionViewCells
    ///
    /// - Parameters:
    ///   - editing: A bool indicating the state of editing.
    //    - animated: A bool indicating whether to animate or not.
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        print("Edit/Done button pressed")
        
        // Gets the cell and index path of the visible cell in the collection view.
        guard let indexPaths = collectionView?.indexPathsForVisibleItems else { return }
        for indexPath in indexPaths.sorted() {
            if let cell = collectionView?.cellForItem(at: indexPath) as? Cell {
                if editing {
                    Animations.startJiggle(collectionView: collectionView!, with: 0.0) // Animates the collectionView cells when the edit/done barButtonItem is tapped.
                    cell.deleteButton.isHidden = false
                } else {
                    Animations.stopJiggling(collectionView: collectionView!) // Stops the animation of the collectionView cells when the edit/done barButtonItem is tapped.
                    cell.deleteButton.isHidden = true
                }
            }
        }
    }
    
    
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Sends the chosen special order to the Display VC.
        guard let displayOrderVC = segue.destination as? DisplaySpecialOrderVC else { return }
        guard let index = collectionView.indexPath(for: (sender as? Cell)!)?.row else { return }
        displayOrderVC.specialOrder = specialOrders[index]
    }
    
    
}

