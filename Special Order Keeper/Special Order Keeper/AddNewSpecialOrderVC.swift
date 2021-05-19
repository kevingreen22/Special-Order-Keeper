//
//  AddNewSpecialOrderVC.swift
//  Special Order Keeper
//
//  Created by Kevin Green on 12/7/18.
//  Copyright © 2018 com.kevinGreen. All rights reserved.
//

import UIKit
import CoreData

class AddNewSpecialOrderVC: UIViewController, UITextFieldDelegate, UITextViewDelegate, ImagePickerDelegate {

    // MARK: - Insatnce Variables
    
    let managedContext = AppDelegate.getAppDelegate().persistentContainer.viewContext
    var imagePicker: ImagePicker!
    
    
    
    // MARK: - Outlets
    
    @IBOutlet weak var nameTextField: UITextField! { didSet { nameTextField.delegate = self } }
    @IBOutlet weak var phoneNumberTextField: UITextField! { didSet { phoneNumberTextField.delegate = self } }
    @IBOutlet weak var depositAmountTextField: UITextField! { didSet { depositAmountTextField.delegate = self } }
    @IBOutlet weak var companyNameTextField: UITextField! { didSet { companyNameTextField.delegate = self } }
    @IBOutlet weak var jewelryDescriptionTextView: UITextView! { didSet { jewelryDescriptionTextView.delegate = self } }
    @IBOutlet weak var refImageView: UIButton!
    
    
    
    // MARK: - Actions
    
    @IBAction func saveButtonTapped(_ sender: UIBarButtonItem) {
        print("Save button tapped")
        if createEntityDescriptionInManagedContext() {
            if let error = saveCoreData() {
                let alert = UIAlertController(title: "Error Saving", message: error.localizedDescription, preferredStyle: .alert)
                let ok = UIAlertAction(title: "Ok", style: .default, handler: nil)
                alert.addAction(ok)
                present(alert, animated: true, completion: nil)
            } else {
                navigationController?.popViewController(animated: true)
            }
        } else {
            let alert = UIAlertController(title: "Damn It Jenry!", message: "Name, Phone, deposit & description need to be filled out.", preferredStyle: .alert)
            let ok = UIAlertAction(title: "Ok", style: .default, handler: nil)
            alert.addAction(ok)
            present(alert, animated: true, completion: nil)
        }
    }
    
    @IBAction func viewTapped(_ sender: UITapGestureRecognizer) {
        view.endEditing(true)
    }
    
    @IBAction func addImage(_ sender: UIButton) {
        imagePicker.present(from: self.view)
    }
    
    
    
    
    
    
    
    
    /// Creates an entity within the managed context of the persistent container.
    ///
    /// - Returns: True if the entity was able to be created, false otherwise.
    fileprivate func createEntityDescriptionInManagedContext() -> Bool {
        if nameTextField.text != "" && phoneNumberTextField.text != "" && jewelryDescriptionTextView.text != "" && depositAmountTextField.text != "" {
            guard let entity = NSEntityDescription.entity(forEntityName: "SpecialOrder", in: managedContext) else { return false }
            let specialOrder = NSManagedObject(entity: entity, insertInto: managedContext)
            specialOrder.setValue(nameTextField.text, forKeyPath: CoreDataKeys.clientName.rawValue)
            specialOrder.setValue(phoneNumberTextField.text, forKey: CoreDataKeys.phoneNumber.rawValue)
            
            if depositAmountTextField.text == "$" { specialOrder.setValue("$0.00", forKey: CoreDataKeys.depositAmount.rawValue)
            } else { specialOrder.setValue(depositAmountTextField.text, forKey: CoreDataKeys.depositAmount.rawValue) }
            
            specialOrder.setValue(companyNameTextField.text, forKey: CoreDataKeys.company.rawValue)
            
            specialOrder.setValue(jewelryDescriptionTextView.text, forKey: CoreDataKeys.jewelryDescription.rawValue)
            specialOrder.setValue(Date(), forKey: CoreDataKeys.date.rawValue)
            
            if let imageData = refImageView.backgroundImage(for: .normal)!.pngData() {
                specialOrder.setValue(imageData, forKey: CoreDataKeys.refImage.rawValue)
            }
            
            return true
        } else { return false }
    }
    
    
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.imagePicker = ImagePicker(presentationController: self, delegate: self)
        title = "Add Special Order"
    }

    
    
    // MARK: - UITextViewDelegate
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == "Quantity, codes, size, style, color, length, etc." { textView.text = "" }
        textView.textColor = .black
    }
    
    
    func didSelect(image: UIImage?) {
        guard let image = image else {
            refImageView.setBackgroundImage(UIImage(named: "add photo.png"), for: .normal)
            return
        }
        refImageView.setBackgroundImage(image, for: .normal)
    }
    
    
    // MARK: - UITextFieldDelegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case nameTextField: phoneNumberTextField.becomeFirstResponder()
        case depositAmountTextField: companyNameTextField.becomeFirstResponder()
        case companyNameTextField: jewelryDescriptionTextView.becomeFirstResponder()
        default: break
        }
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == depositAmountTextField {
            depositAmountTextField.text = "$"
        }
    }
    
    /// This adds phone number character formating for the Phone Number textField.
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == phoneNumberTextField {
            let newString = (textField.text! as NSString).replacingCharacters(in: range, with: string)
            let components = newString.components(separatedBy: NSCharacterSet.decimalDigits.inverted)
            
            let decimalString = components.joined(separator: "") as NSString
            let length = decimalString.length
            let hasLeadingOne = length > 0 && decimalString.character(at: 0) == (1 as unichar)
            
            if length == 0 || (length > 10 && !hasLeadingOne) || length > 11 {
                let newLength = (textField.text! as NSString).length + (string as NSString).length - range.length as Int
                return (newLength > 10) ? false : true
            }
            var index = 0 as Int
            let formattedString = NSMutableString()
            
            if hasLeadingOne {
                formattedString.append("1 ")
                index += 1
            }
            if (length - index) > 3 {
                let areaCode = decimalString.substring(with: NSMakeRange(index, 3))
                formattedString.appendFormat("(%@)", areaCode)
                index += 3
            }
            if length - index > 3 {
                let prefix = decimalString.substring(with: NSMakeRange(index, 3))
                formattedString.appendFormat("%@-", prefix)
                index += 3
            }
            
            let remainder = decimalString.substring(from: index)
            formattedString.append(remainder)
            textField.text = formattedString as String
            print("length: \(length)")
            if length == 10 { depositAmountTextField.becomeFirstResponder() }
            return false
        } else {
            return true
        }
    }


    

    
    
    
}

