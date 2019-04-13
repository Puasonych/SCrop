//
//  SCropController.swift
//  SCrop
//
//  Created by Eric Basargin on 04/04/2019.
//  Copyright © 2019 Three man army. All rights reserved.
//

import UIKit

public class SCropController: UIViewController {
    @IBOutlet private weak var scrollView: UIScrollView!
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var shadowView: UIView!
    @IBOutlet private weak var cropView: UIView!
    @IBOutlet private weak var tabBarView: UIView!
    @IBOutlet private weak var cancelButton: UIButton!
    @IBOutlet private weak var usePhotoButton: UIButton!

    private let image: UIImage
    
    public enum CropViewType {
        case circle
        case rectangle
    }
    
    public weak var delegate: SCropControllerDelegate?
    
    public var cropViewBorderColor: UIColor = UIColor.white {
        didSet {
            self.cropView.layer.borderColor = self.cropViewBorderColor.cgColor
        }
    }
    
    public var cropViewBorderWidth: CGFloat = 1 {
        didSet {
            self.cropView.layer.borderWidth = self.cropViewBorderWidth
        }
    }
    
    public var cropViewCornerRadius: CGFloat = 0 {
        didSet {
            self.cropView.layer.cornerRadius = self.cropViewCornerRadius
            self.needUpdateCropViewCornerRadius()
        }
    }
    
    public var cropViewType: CropViewType = .circle {
        didSet {
            self.needUpdateCropViewCornerRadius()
        }
    }
    
    public var shadowViewBackgoundColor: UIColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5) {
        didSet {
            self.shadowView.backgroundColor = self.shadowViewBackgoundColor
        }
    }
    
    public var tabBarBackgoundColor: UIColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.75) {
        didSet {
            self.tabBarView.backgroundColor = self.tabBarBackgoundColor
        }
    }
    
    public init(image: UIImage) {
        self.image = image
        let name = String(describing: type(of: self))
        super.init(nibName: name, bundle: Bundle(for: SCropController.self))
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        self.imageView.image = self.image
        
        self.cropView.layer.masksToBounds = true
        self.cropView.backgroundColor = UIColor.clear
        
        self.scrollView.layoutIfNeeded()
        
        self.needUpdateContentInset()
        
        self.scrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: false)
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.addTransparentHole()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override var prefersStatusBarHidden: Bool {
        return true
    }
    
    public func setTintColor(_ color: UIColor?, for state: UIControl.State) {
        self.cancelButton.setTitleColor(color, for: state)
        self.usePhotoButton.setTitleColor(color, for: state)
    }

    @IBAction func onTapCancelButton(_ sender: UIButton) {
        self.delegate?.sCropControllerDidCancel(self)
    }
    
    @IBAction func onTapUserPhotoButton(_ sender: UIButton) {
        guard let fixedImage = self.imageView.image?.fixedOrientation() else {
            self.delegate?.sCropController(self, didFinishWithInfo: .failure(.correctionError))
            return
        }
        
        let cropArea = self.cropArea(for: fixedImage)
        guard let croppedImage = fixedImage.cropped(boundingBox: cropArea) else {
            self.delegate?.sCropController(self, didFinishWithInfo: .failure(.unableCropImage))
            return
        }
        
        self.delegate?.sCropController(self, didFinishWithInfo: .success(croppedImage))
    }
    
    private func needUpdateContentInset() {
        let imageFrame = self.imageView.imageFrame()
        
        let leftAndRightSpace = (self.scrollView.frame.width - imageFrame.width) / 2
        
        var topAndBottomSpace: CGFloat = CGFloat.zero
        if self.scrollView.frame.height >= imageFrame.height {
            topAndBottomSpace = (self.scrollView.contentSize.height - imageFrame.height) / 2 - (self.scrollView.frame.height - imageFrame.height) / 2
        } else {
            topAndBottomSpace = (self.scrollView.contentSize.height - imageFrame.height) / 2
        }

        let leftAndRightInsets = (self.scrollView.frame.width - self.cropView.frame.width) / 2
        let topAndBottomInsets = self.scrollView.frame.height >= imageFrame.height ? (imageFrame.height - self.cropView.frame.height) / 2 : (self.scrollView.frame.height - self.cropView.frame.height) / 2

        self.scrollView.contentInset = UIEdgeInsets(top: topAndBottomInsets - topAndBottomSpace,
                                                    left: leftAndRightInsets,
                                                    bottom: topAndBottomInsets - topAndBottomSpace,
                                                    right: leftAndRightInsets)
    }
    
    private func needUpdateCropViewCornerRadius() {
        switch self.cropViewType {
        case .circle:
            self.cropView.layer.cornerRadius = self.cropView.frame.width / 2
        case .rectangle:
            self.cropView.layer.cornerRadius = self.cropViewCornerRadius
        }
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
    
    private func currentCropArea() -> CGRect {
        let scale = 1 / self.scrollView.zoomScale
        let boundaryRect = CGRect(x: self.view.frame.width / 2 - self.cropView.frame.width / 2,
                                  y: self.view.frame.height / 2 - self.cropView.frame.height / 2,
                                  width: self.cropView.frame.width,
                                  height: self.cropView.frame.height)
        let imageFrame = self.imageView.imageFrame()
        let factor = imageFrame.width / self.view.frame.width
        
        let x = (self.scrollView.contentOffset.x + boundaryRect.origin.x - imageFrame.origin.x) * scale * factor
        let y = (self.scrollView.contentOffset.y + boundaryRect.origin.y - imageFrame.origin.y) * scale * factor
        let width = boundaryRect.width * scale * factor
        let height = boundaryRect.height * scale * factor
        
        return CGRect(x: x, y: y, width: width, height: height)
    }
}

extension SCropController: UIScrollViewDelegate {
    public func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.imageView
    }
    
    public func scrollViewDidZoom(_ scrollView: UIScrollView) {
        self.needUpdateContentInset()
    }
}
