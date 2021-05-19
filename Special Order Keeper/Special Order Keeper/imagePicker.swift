//
//  imagePicker.swift
//  Special Order Keeper
//
//  Created by Kevin Green on 3/5/20.
//  Copyright © 2020 com.kevinGreen. All rights reserved.
//

import UIKit
import AVFoundation
import Photos

public protocol ImagePickerDelegate: AnyObject {
    func didSelect(image: UIImage?)
}

open class ImagePicker: NSObject {

    private let pickerController: UIImagePickerController
    private weak var presentationController: UIViewController?
    private weak var delegate: ImagePickerDelegate?

    public init(presentationController: UIViewController, delegate: ImagePickerDelegate) {
        self.pickerController = UIImagePickerController()
        super.init()
        self.presentationController = presentationController
        self.delegate = delegate
        self.pickerController.delegate = self
        self.pickerController.allowsEditing = true
        self.pickerController.mediaTypes = ["public.image"]
    }
    
    
    public func present(from sourceView: UIView) {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        if let action = self.action(for: .camera, title: Constants.takePhoto) {
            alertController.addAction(action)
        }
        if let action = self.action(for: .photoLibrary, title: Constants.photoLibrary) {
            alertController.addAction(action)
        }
        let action = UIAlertAction(title: "View Image", style: .default) { (_) in
            let sb = UIStoryboard(name: "Main", bundle: nil)
            guard let viewImageVC = sb.instantiateViewController(withIdentifier: "ViewImageVC") as? ViewImageViewController else { return }
            guard let displayVC = self.presentationController?.parent?.children[1] as? DisplaySpecialOrderVC else { return }
            guard let image = displayVC.refImageView.backgroundImage(for: .normal) else { return }
            viewImageVC.image = image
            displayVC.present(viewImageVC, animated: true, completion: nil)
        }
        alertController.addAction(action)
        
        alertController.addAction(UIAlertAction(title: Constants.cancelBtnTitle, style: .cancel, handler: nil))

        if UIDevice.current.userInterfaceIdiom == .pad {
            alertController.popoverPresentationController?.sourceView = sourceView
            alertController.popoverPresentationController?.sourceRect = sourceView.bounds
            alertController.popoverPresentationController?.permittedArrowDirections = [.left, .right]
        }

        self.presentationController?.present(alertController, animated: true)
    }
    
    
    
    
    fileprivate func action(for type: UIImagePickerController.SourceType, title: String) -> UIAlertAction? {
        guard UIImagePickerController.isSourceTypeAvailable(type) else { return nil }
        
        return UIAlertAction(title: title, style: .default) { [unowned self] _ in
            switch type {
            case .camera:
                let cameraAuthorizationStatus = AVCaptureDevice.authorizationStatus(for: .video)
                switch cameraAuthorizationStatus {
                case .notDetermined: self.requestPermission(for: type)
                case .authorized: self.presentMedia(type: type)
                case .restricted, .denied: self.alertAccessNeeded(for: type)
                @unknown default:
                    break
                }
                
            case .photoLibrary, .savedPhotosAlbum:
                let photoLibraryAuthorizationStatus = PHPhotoLibrary.authorizationStatus()
                switch photoLibraryAuthorizationStatus {
                case .notDetermined: self.requestPermission(for: type)
                case .authorized, .limited: self.presentMedia(type: type)
                case .restricted, .denied: self.alertAccessNeeded(for: type)
                @unknown default:
                    break
                }
                
            @unknown default:
                break
            }
        }
    }
    

    fileprivate func requestPermission(for type: UIImagePickerController.SourceType) {
        switch type {
        case .camera:
            AVCaptureDevice.requestAccess(for: .video, completionHandler: { accessGranted in
                guard accessGranted == true else { return }
                self.presentMedia(type: type)
            })
        case .photoLibrary, .savedPhotosAlbum:
            PHPhotoLibrary.requestAuthorization { (status) in
                if status == .authorized {
                    self.presentMedia(type: type)
                }
            }
        default:
            break
        }
    }
    
    fileprivate func presentMedia(type: UIImagePickerController.SourceType) {
        DispatchQueue.main.async {
            self.pickerController.sourceType = type
            self.presentationController?.present(self.pickerController, animated: true)
        }
    }
    
    fileprivate func alertAccessNeeded(for type: UIImagePickerController.SourceType) {
        var message = ""
        switch type {
        case .camera:
            message = Constants.alertForCameraAccessMessage
        case .photoLibrary, .savedPhotosAlbum:
            message = Constants.alertForPhotoLibraryMessage
        default:
            return
        }
        
        let alert = UIAlertController(title: Constants.titleForAccessAlert, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: Constants.cancelBtnTitle, style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: Constants.settingsBtnTitle, style: .default, handler: { (alert) -> Void in
            let settingsURL = URL(string: UIApplication.openSettingsURLString)!
            UIApplication.shared.open(settingsURL, options: [:], completionHandler: nil)
        }))
        self.presentationController?.present(alert, animated: true, completion: nil)
    }
    
    
    
    
    fileprivate func pickerController(_ controller: UIImagePickerController, didSelect image: UIImage?) {
        controller.dismiss(animated: true, completion: nil)
        self.delegate?.didSelect(image: image)
    }
    
    
    
}


fileprivate struct Constants {
    static let takePhoto = "Take Photo"
    static let photoLibrary = "Photo Library"

    static let titleForAccessAlert = "Access Needed"
    static let alertForPhotoLibraryMessage = "App does not have access to your photos. To enable access, tap settings and turn on Photo Library Access."
    static let alertForCameraAccessMessage = "App does not have access to your camera. To enable access, tap settings and turn on Camera."
        
    static let settingsBtnTitle = "Settings"
    static let cancelBtnTitle = "Cancel"
}




extension ImagePicker: UIImagePickerControllerDelegate {
    
    public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.pickerController(picker, didSelect: nil)
    }
    
    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        // to handle image
        guard let image = info[.editedImage] as? UIImage else { return self.pickerController(picker, didSelect: nil) }
        self.pickerController(picker, didSelect: image)
    }
    
}

extension ImagePicker: UINavigationControllerDelegate { }


