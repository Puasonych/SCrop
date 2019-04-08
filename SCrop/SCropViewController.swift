//
//  SCropViewController.swift
//  SCrop
//
//  Created by Eric Basargin on 04/04/2019.
//  Copyright © 2019 Three man army. All rights reserved.
//

import UIKit

open class SCropViewController: UIViewController {
    @IBOutlet private weak var scrollView: UIScrollView!
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var shadowView: UIView!
    @IBOutlet private weak var cropView: UIView!
    @IBOutlet private weak var tabBarView: UIView!
    @IBOutlet private weak var cancleButton: UIButton!
    @IBOutlet private weak var usePhotoButton: UIButton!

    private var image: UIImage
    
    public weak var delegate: SCropViewControllerDelegate?
    
    @IBInspectable var cropViewBorderColor: UIColor = UIColor.white {
        didSet {
            self.cropView.layer.borderColor = self.cropViewBorderColor.cgColor
        }
    }
    
    @IBInspectable var cropViewBorderWidth: CGFloat = 1 {
        didSet {
            self.cropView.layer.borderWidth = self.cropViewBorderWidth
        }
    }
    
    @IBInspectable var cropViewCornerRadius: CGFloat = 0 {
        didSet {
            self.cropView.layer.cornerRadius = self.cropViewCornerRadius
        }
    }
    
    @IBInspectable var shadowViewBackgoundColor: UIColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5) {
        didSet {
            self.shadowView.backgroundColor = self.shadowViewBackgoundColor
        }
    }
    
    @IBInspectable var tabBarBackgoundColor: UIColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.75) {
        didSet {
            self.tabBarView.backgroundColor = self.tabBarBackgoundColor
        }
    }
    
    @IBInspectable var cancleButtonColor: UIColor = UIColor.white {
        didSet {
            self.cancleButton.setTitleColor(self.cancleButtonColor, for: UIControl.State.normal)
        }
    }
    
    @IBInspectable var usePhotoButtonColor: UIColor = UIColor.white {
        didSet {
            self.usePhotoButton.setTitleColor(self.usePhotoButtonColor, for: UIControl.State.normal)
        }
    }
    
    public init(image: UIImage) {
        self.image = image
        super.init(nibName: nil, bundle: nil)
    }
    
    open override func viewDidLoad() {
        self.scrollView.delegate = self
        self.imageView.image = self.image
        self.cropView.layer.masksToBounds = true
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.addTransparentHole()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @IBAction func onTapCancleButton(_ sender: UIButton) {
        self.closeViewController()
    }
    
    @IBAction func onTapUserPhotoButton(_ sender: UIButton) {
        guard let fixedImage = self.image.fixedOrientation() else {
            delegate?.croppedImage(result: .failure(.correctionError))
            self.closeViewController()
            return
        }
        
        let cropArea = self.cropArea(for: fixedImage)
        guard let croppedImage = fixedImage.cropped(boundingBox: cropArea) else {
            delegate?.croppedImage(result: .failure(.unableCropImage))
            self.closeViewController()
            return
        }
        
        delegate?.croppedImage(result: .success(croppedImage))
        
        self.closeViewController()
    }
    
    private func addTransparentHole() {
        self.view.layoutIfNeeded()
        let layer = CAShapeLayer()
        
        let path = UIBezierPath(rect: CGRect(x: 0,
                                             y: 0,
                                             width: self.view.frame.width,
                                             height: self.view.frame.height))
        let smallPath = UIBezierPath(roundedRect: CGRect(x: self.cropView.frame.origin.x + 1,
                                                         y: self.cropView.frame.origin.y + 1,
                                                         width: self.cropView.frame.width - 2,
                                                         height: self.cropView.frame.height - 2),
                                     cornerRadius: self.cropView.frame.width / 2)
        
        path.append(smallPath)
        
        layer.path = path.cgPath
        layer.fillRule = CAShapeLayerFillRule.evenOdd
        layer.fillColor = UIColor.black.cgColor
        
        self.shadowView.layer.mask = layer
        self.view.layoutIfNeeded()
    }
    
    private func closeViewController() {
        if let navigationController = self.navigationController {
            navigationController.popViewController(animated: true)
        } else {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    private func cropArea(for image: UIImage) -> CGRect {
        let factor = image.size.width / self.view.frame.width
        let scale = 1 / self.scrollView.zoomScale
        let boundaryRect = CGRect(x: self.view.frame.width / 2 - self.cropView.frame.width / 2,
                                  y: self.view.frame.height / 2 - self.cropView.frame.height / 2,
                                  width: self.cropView.frame.width,
                                  height: self.cropView.frame.height)
        let imageFrame = self.imageView.imageFrame()
        
        let x = (self.scrollView.contentOffset.x + boundaryRect.origin.x - imageFrame.origin.x) * scale * factor
        let y = (self.scrollView.contentOffset.y + boundaryRect.origin.y - imageFrame.origin.y) * scale * factor
        let width = boundaryRect.width * scale * factor
        let height = boundaryRect.height * scale * factor
        
        return CGRect(x: x, y: y, width: width, height: height)
    }
}

extension SCropViewController: UIScrollViewDelegate {
    public func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.imageView
    }
}
