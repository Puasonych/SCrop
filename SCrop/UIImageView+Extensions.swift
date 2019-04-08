//
//  UIImageView+Extensions.swift
//  SCrop
//
//  Created by Eric Basargin on 08/04/2019.
//  Copyright © 2019 Three man army. All rights reserved.
//

import UIKit

extension UIImageView {
    func imageFrame() -> CGRect {
        guard let image = self.image else { return CGRect.zero }
        
        let imageRatio = image.size.width / image.size.height
        let imageViewRatio = self.frame.size.width / self.frame.size.height
        
        if imageRatio < imageViewRatio {
            let scaleFactor = self.frame.size.height / image.size.height
            let width = image.size.width * scaleFactor
            let topLeftX = (self.frame.size.width - width) * 0.5
            return CGRect(x: topLeftX, y: 0, width: width, height: self.frame.size.height)
        } else {
            let scalFactor = self.frame.size.width / image.size.width
            let height = image.size.height * scalFactor
            let topLeftY = (self.frame.size.height - height) * 0.5
            return CGRect(x: 0, y: topLeftY, width: self.frame.size.width, height: height)
        }
    }
}
