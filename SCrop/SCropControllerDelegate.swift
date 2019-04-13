//
//  SCropControllerDelegate.swift
//  SCrop
//
//  Created by Eric Basargin on 08/04/2019.
//  Copyright © 2019 Three man army. All rights reserved.
//

import UIKit

public protocol SCropControllerDelegate: class {
    func sCropController(_ crop: SCropController, didFinishWithInfo info: Result<UIImage, SCropController.Errors>)
    func sCropControllerDidCancel(_ crop: SCropController)
}
