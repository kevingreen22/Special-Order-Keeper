//
//  ViewImageViewController.swift
//  Special Order Keeper
//
//  Created by Kevin Green on 3/7/20.
//  Copyright © 2020 com.kevinGreen. All rights reserved.
//

import UIKit

class ViewImageViewController: UIViewController, UIGestureRecognizerDelegate {

    var image = UIImage()
    
    
    
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var imgView: UIImageView!
    
    @IBAction func doneButtonTapped(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imgView.image = image
        imgView.isUserInteractionEnabled = true
        
        let pinchZoom = UIPinchGestureRecognizer(target: self, action: #selector(handlePinch))
        let pan = UIPanGestureRecognizer(target: self, action: #selector(handlePan))
        imgView.addGestureRecognizer(pinchZoom)
        imgView.addGestureRecognizer(pan)
        pinchZoom.delegate = self
        pan.delegate = self
        
    }
    
    /// Handles a pinch gesture
    /// - Parameter recognizer: A UIPinchGestureRecognizer
    @objc func handlePinch(recognizer: UIPinchGestureRecognizer) {
        print("Image pinched")
        guard let imgView = recognizer.view else { return }
        
        switch recognizer.state {
        case .began, .changed:
            imgView.transform = imgView.transform.scaledBy(x: recognizer.scale, y: recognizer.scale)
            recognizer.scale = 1.0
//        case .ended, .cancelled, .failed:
//            UIView.animate(withDuration: 0.2) {
//                imgView.transform = .identity
//            }
        default:
            break
        }
    }
    
    /// Handles the pan gesture
    /// - Parameter recognizer: A UIPanGestureRecognizer
    @objc func handlePan(recognizer: UIPanGestureRecognizer) {
        print("Image panned")
        guard let imgView = recognizer.view else { return }
            
        switch recognizer.state {
        case .began, .changed:
            let translation = recognizer.translation(in: self.view)
            imgView.center = CGPoint(x: imgView.center.x + translation.x, y: imgView.center.y + translation.y)
            recognizer.setTranslation(CGPoint(x: 0, y: 0), in: self.view)
//        case .ended, .cancelled, .failed:
//            UIView.animate(withDuration: 0.2) {
//                imgView.transform = .identity
//            }
        default:
            break
        }
    }
    
    
    
    // MARK: - UIGestureRecognizerDelegate
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
        
        
}
