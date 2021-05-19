//
//  Animations.swift
//  Special Order Keeper
//
//  Created by Kevin Green on 12/9/18.
//  Copyright © 2018 com.kevinGreen. All rights reserved.
//

import UIKit

class Animations {
    
    /// Animates the collectionView cells when the edit/done barButtonItem is tapped.
    ///
    /// - Parameters:
    ///   - collectionView: The collection view object to animate.
    ///   - delay: The amount of delay to apply to the animation.
    static func startJiggle(collectionView: UICollectionView, with delay: CFTimeInterval) {
        let degrees: CGFloat = 5.0
        let animation = CAKeyframeAnimation(keyPath: "transform.rotation.z")
        animation.beginTime = CACurrentMediaTime() + delay
        animation.duration = 0.8
        animation.isCumulative = true
        animation.repeatCount = Float.infinity
        animation.values = [0.0,
                            (degrees * CGFloat(CGFloat.pi / 180)) * 0.25,
                            0.0,
                            (degrees * CGFloat(CGFloat.pi / 180)) * 0.25,
                            0.0,
                            (degrees * CGFloat(CGFloat.pi / 180)) * 0.25,
                            0.0,
                            (degrees * CGFloat(CGFloat.pi / 180)) * 0.25,
                            0.0]
        animation.fillMode = CAMediaTimingFillMode.forwards;
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear)
        animation.isRemovedOnCompletion = true
        
        for cell in collectionView.visibleCells {
            cell.layer.add(animation, forKey: "jiggle")
        }
    }
    
    
    /// Stops the animation of the collectionView cells when the edit/done barButtonItem is tapped.
    ///
    /// - Parameter collectionView: The collection view object to animate.
    static func stopJiggling(collectionView: UICollectionView) {
        for cell in collectionView.visibleCells {
            cell.layer.removeAnimation(forKey: "jiggle")
            cell.layer.removeAllAnimations()
            cell.transform = CGAffineTransform.identity
            cell.layer.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        }
    }
    
}
