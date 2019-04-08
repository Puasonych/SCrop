//
//  SCropViewController+Errors.swift
//  SCrop
//
//  Created by Eric Basargin on 08/04/2019.
//  Copyright © 2019 Three man army. All rights reserved.
//

import Foundation

public extension SCropViewController {
    enum Errors: Error, LocalizedError {
        case correctionError
        case unableCropImage
        
        public var errorDescription: String? {
            switch self {
            case .correctionError:
                return "Failed to correct the orientation of the image"
            case .unableCropImage:
                return "Unable to crop image"
            }
        }
    }
}
