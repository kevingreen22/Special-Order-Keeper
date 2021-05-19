//
//  DisplaySpecialOrderVC.swift
//  Special Order Keeper
//
//  Created by Kevin Green on 12/7/18.
//  Copyright © 2018 com.kevinGreen. All rights reserved.
//

import UIKit
import CoreData
import MessageUI

class DisplaySpecialOrderVC: UIViewController, UITextViewDelegate, UITextFieldDelegate, MFMessageComposeViewControllerDelegate, ImagePickerDelegate {
    
    // MARK: - Instance Variables
    
    var managedContext = AppDelegate.getAppDelegate().persistentContainer.viewContext
    var specialOrder: SpecialOrder!
    var imagePicker: ImagePicker!
    var coreDataButtonKey = CoreDataKeys.dateOrdered.rawValue
    
    
    
    // MARK: - Outlets
    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var dateOrderedButton: UIButton!
    @IBOutlet weak var dateCalledButton: UIButton!
    @IBOutlet weak var depositTextField: UITextField! { didSet { depositTextField.delegate = self } }
    @IBOutlet weak var companyTextField: UITextField! { didSet { companyTextField.delegate = self } }
    @IBOutlet weak var jewelryDescription: UITextView! { didSet { jewelryDescription.delegate = self } }
    @IBOutlet weak var callClientButton: UIButton!
    @IBOutlet weak var refImageView: UIButton!
    
    @IBOutlet weak var datePickerView: UIView!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var datePickerDoneButton: UIButton!
    @IBOutlet weak var datePickerCancelButton: UIButton!
    
    
    
    // MARK: - Actions
    
    /// Dismises the date picker by touching anywhere in the view.
    ///
    /// - Parameter sender: The tap that triggered the event.
    @IBAction func viewTapped(_ sender: UITapGestureRecognizer) {
        view.endEditing(true)
    }
    
    @IBAction func setDateOrdered(_ sender: UIButton) {
        view.endEditing(true)
        print("Set ordered-date button tapped")
        showDatePicker()
        coreDataButtonKey = CoreDataKeys.dateOrdered.rawValue
    }
    
    /// Sets the date the client was called back.
    ///
    /// - Parameter sender: The button that triggered the event.
    @IBAction func setDateCalledBack(_ sender: UIButton) {
        view.endEditing(true)
        print("Set called-back-date button tapped")
        showDatePicker()
        coreDataButtonKey = CoreDataKeys.dateCalled.rawValue
    }
    
    /// A button that presents an alert with options to either call, message, or cancel.
    ///
    /// - Parameter sender: The button that triggered the event.
    @IBAction func callClientButtonTapped(_ sender: UIButton) {
        print("Call/message client button tapped")
        callMessageNumber()
    }
    
    @IBAction func refImage(_ sender: UIButton) {
        imagePicker.present(from: self.view)
    }
    
    
    
    @IBAction func datePickerDoneButtonTapped(_ sender: UIButton) {
        specialOrder.setValue(datePicker.date, forKey: coreDataButtonKey)
        
        switch coreDataButtonKey {
        case CoreDataKeys.dateCalled.rawValue:
            dateCalledButton.setTitle(datePicker.date.myDateFormatted(), for: .normal)
        case CoreDataKeys.dateOrdered.rawValue:
            dateOrderedButton.setTitle(datePicker.date.myDateFormatted(), for: .normal)
        default:
            break
        }
        
        dismissDatePicker()
    }
    
    
    @IBAction func datePickerCancelButtonTapped(_ sender: UIButton) {
        dismissDatePicker()
    }
    
    
    
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imagePicker = ImagePicker(presentationController: self, delegate: self)
        initDisplay()
        
        datePickerView.addShadow()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if let error = saveCoreData() { print(error) }
    }
    
    
    
    // MARK: - ImagePickerDelegate
    
    func didSelect(image: UIImage?) {
        refImageView.setBackgroundImage(image, for: .normal)
        
        guard let image = image else {
            refImageView.setBackgroundImage(UIImage(named: "add photo.png"), for: .normal)
            return
        }
        refImageView.setBackgroundImage(image, for: .normal)
        
        if let imageData = refImageView.backgroundImage(for: .normal)!.pngData() {
            specialOrder.setValue(imageData, forKey: CoreDataKeys.refImage.rawValue)
        }
    }
    
    
    
    // MARK: - UITextViewDelegate
    
    func textViewDidChange(_ textView: UITextView) {
        specialOrder.setValue(textView.text, forKey: CoreDataKeys.jewelryDescription.rawValue)
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        specialOrder.setValue(textView.text, forKey: CoreDataKeys.jewelryDescription.rawValue)
    }
    
    
    
    // MARK: - UITextFieldDelegate
    
    /// Sets the core data value when editing the textfield has ended.
    ///
    /// - Parameter textField: The textfield triggering the call.
    func textFieldDidEndEditing(_ textField: UITextField) {
        switch textField {
        case depositTextField: specialOrder.setValue(textField.text, forKey: CoreDataKeys.depositAmount.rawValue)
        case companyTextField: specialOrder.setValue(textField.text, forKey: CoreDataKeys.company.rawValue)
        default: break
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    
   
    
    
    // MARK: - Private Methods
    
    /// Initializes the display with the entities info.
    fileprivate func initDisplay() {
        title = specialOrder.clientName
        dateLabel.text = specialOrder.date?.myDateFormatted()
        depositTextField.text = specialOrder.depositAmount
        companyTextField.text = specialOrder.company ?? ""
        
        let orderedButtonTitle = specialOrder.dateOrdered?.myDateFormatted() ?? "Tap To Set Date Ordered"
        dateOrderedButton.setTitle(orderedButtonTitle, for: .normal)
        
        let calledButtonTitle = specialOrder.dateCalled?.myDateFormatted() ?? "Tap To Set Date Called Back"
        dateCalledButton.setTitle(calledButtonTitle, for: .normal)
        
        jewelryDescription.text = specialOrder.jewelryDescription
        
        guard let imageData = specialOrder.refImage else { return }
        guard let image = UIImage(data: imageData) else { return }
        refImageView.setBackgroundImage(image, for: .normal)
    }
    
    
    fileprivate func showDatePicker() {
        UIView.animate(withDuration: 0.3) {
            self.datePickerView.transform = CGAffineTransform(translationX: 0, y: -304)
        }
    }
    
    fileprivate func dismissDatePicker() {
        UIView.animate(withDuration: 0.3) {
            self.datePickerView.transform = .identity
        }
    }
    
    /// Invokes a phone call to the client via the phone number saved to the entity in core data.
    fileprivate func callMessageNumber() {
        guard let phoneNumber = specialOrder.phoneNumber /*.value(forKey: "phoneNumber") as? String*/ else { return }
        let cleanPhoneNumber = phoneNumber.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
        if let phoneURL = URL(string: "telprompt://\(cleanPhoneNumber)")/*, UIApplication.shared.canOpenURL(callPhoneURL)*/ {
            let alert = UIAlertController(title: "Call/Message \(phoneNumber)?", message: "", preferredStyle: .alert)
            let call = UIAlertAction(title: "Call", style: .default) { (_) in
                self.callphoneNumber(phoneURL: phoneURL)
            }
            let message = UIAlertAction(title: "Message", style: .default) { (_) in
                self.sendSMSText(phoneNumber: cleanPhoneNumber)
            }
            let cancel = UIAlertAction(title: "Cancel", style: .destructive, handler: { (_) in
                self.dateCalledButton.setTitle("Tap to Call Client", for: .normal)
            })
            alert.addAction(call)
            alert.addAction(message)
            alert.addAction(cancel)
            present(alert, animated: true, completion: nil)
        }
    }
    
    /// Starts a phone call, after presenting the user with an alert to cancel or call.
    ///
    /// - Parameter phoneURL: Concatenates the phone number to call after the "telpromp:' prefix as a URL.
    fileprivate func callphoneNumber(phoneURL: URL) {
        if #available(iOS 10, *) {
            UIApplication.shared.open(phoneURL)
        } else {
            UIApplication.shared.openURL(phoneURL)
        }
    }
    
    /// Opens up the Messages app ready to send a SMS message.
    ///
    /// - Parameter phoneNumber: The phone number to send the SMS messge to.
    fileprivate func sendSMSText(phoneNumber: String) {
        if (MFMessageComposeViewController.canSendText()) {
            let controller = MFMessageComposeViewController()
            controller.body = ""
            controller.recipients = [phoneNumber]
            controller.messageComposeDelegate = self
            self.present(controller, animated: true, completion: nil)
        }
    }
    
    
    
    // MARK: - MFMessageComposeViewControllerDelegate
    
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    
    
    
    
    
    
    
    
}

