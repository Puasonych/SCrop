//
//  ViewController.swift
//  SCropExample
//
//  Created by Eric Basargin on 08/04/2019.
//  Copyright © 2019 Three man army. All rights reserved.
//

import UIKit
import SCrop

class ViewController: UIViewController {
    @IBOutlet private weak var imageView: UIImageView!
    
    @IBAction func onTapChooseImage(_ sender: UIButton) {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.allowsEditing = false
        
        let actionSheet = UIAlertController(title: "Photo Source", message: "Choose a source", preferredStyle: UIAlertController.Style.actionSheet)
        
        actionSheet.addAction(UIAlertAction(title: "Camera", style: UIAlertAction.Style.default, handler: { (action) in
            imagePickerController.sourceType = UIImagePickerController.SourceType.camera
            self.present(imagePickerController, animated: true, completion: nil)
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Photo Library", style: UIAlertAction.Style.default, handler: { (action) in
            imagePickerController.sourceType = UIImagePickerController.SourceType.photoLibrary
            self.present(imagePickerController, animated: true, completion: nil)
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: nil))
        
        self.present(actionSheet, animated: true, completion: nil)
    }
}

extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let image = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
        
        picker.dismiss(animated: true) {
            let sCropViewController = SCropViewController(image: image)
            
            sCropViewController.delegate = self
            
            self.present(sCropViewController, animated: true, completion: nil)
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}

extension ViewController: SCropViewControllerDelegate {
    func croppedImage(result: Result<UIImage, SCropViewController.Errors>) {
        switch result {
        case let .success(image):
            self.imageView.image = image
        case let .failure(error):
            print(error.errorDescription!)
        }
    }
}
