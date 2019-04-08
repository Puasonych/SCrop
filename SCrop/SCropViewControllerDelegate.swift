//
//  SCropViewControllerDelegate.swift
//  SCrop
//
//  Created by Eric Basargin on 08/04/2019.
//  Copyright © 2019 Three man army. All rights reserved.
//

import UIKit

public protocol SCropViewControllerDelegate: class {
    func croppedImage(result: Result<UIImage, SCropViewController.Errors>)
}
