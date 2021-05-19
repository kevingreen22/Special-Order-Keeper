//
//  Cell.swift
//  Special Order Keeper
//
//  Created by Kevin Green on 12/7/18.
//  Copyright © 2018 com.kevinGreen. All rights reserved.
//

import UIKit

class Cell: UICollectionViewCell {
    
    var delegate: CellDelegate?
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var dateOrderedLabel: UILabel!
    @IBOutlet weak var calledBackLabel: UILabel!
    @IBOutlet weak var companyLabel: UILabel!
    @IBOutlet weak var deleteButton: UIButton!
    
    @IBAction func deleteTapped(_ sender: UIButton) {
        delegate?.deleteEntity(from: self)
    }
    
    
    
}
