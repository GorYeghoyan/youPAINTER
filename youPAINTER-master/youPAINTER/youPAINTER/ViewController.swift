//
//  ViewController.swift
//  youPAINTER
//
//  Created by Gor Yeghoyan on 9/14/20.
//  Copyright © 2020 Gor Yeghoyan. All rights reserved.
//

import UIKit
import PencilKit
import PhotosUI


class ViewController: UIViewController, PKCanvasViewDelegate, PKToolPickerObserver {

  
    @IBOutlet weak var pencilFingerButton: UIBarButtonItem!
    @IBOutlet weak var canvasView: PKCanvasView!
    
    let canvasWidth: CGFloat = 768
    let canvasOverscrollHight: CGFloat = 500
    
    var drawing = PKDrawing()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        canvasView.delegate = self
        canvasView.drawing = drawing
        
        canvasView.alwaysBounceVertical = true
        canvasView.allowsFingerDrawing = true
        canvasView.backgroundColor = .white
        
        if let window = parent?.view.window,
            let toolPicker = PKToolPicker.shared(for: window) {
            toolPicker.setVisible(true, forFirstResponder: canvasView)
            toolPicker.addObserver(canvasView)
            
            canvasView.becomeFirstResponder()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        setUpPencilKit()
    }
    func setUpPencilKit() {
    
        let canvasView = PKCanvasView(frame: self.view.bounds)
        guard let window = view.window, let toolPicker = PKToolPicker.shared(for: window)
        else { return }
        toolPicker.setVisible(true, forFirstResponder: canvasView)
        toolPicker.addObserver(canvasView)
        canvasView.becomeFirstResponder()
        view.addSubview(canvasView)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let canvasScale = canvasView.bounds.width / canvasWidth
        canvasView.minimumZoomScale = canvasScale
        canvasView.maximumZoomScale = canvasScale
        canvasView.zoomScale = canvasScale
        updateContentSIzeForDrawing()
        canvasView.contentOffset = CGPoint(x: 0, y: -canvasView.adjustedContentInset.top)
        
    }
    

    override var prefersHomeIndicatorAutoHidden: Bool {
        return true
    }

    @IBAction func tooglePancilOrFingerDrawing(_ sender: Any) {
        canvasView.allowsFingerDrawing.toggle()
        pencilFingerButton.title = canvasView.allowsFingerDrawing ? "Finger" : "Pencil"
    }
    
    @IBAction func saveDrawingToCameraRoll(_ sender: Any) {
        
        UIGraphicsBeginImageContextWithOptions(canvasView.bounds.size, false, UIScreen.main.scale)
        canvasView.drawHierarchy(in: canvasView.bounds, afterScreenUpdates: true)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        if image != nil {
            PHPhotoLibrary.shared().performChanges({
                PHAssetChangeRequest.creationRequestForAsset(from: image!)
            }, completionHandler: {success, error in
                
            })
        }
    }
    
    
    
    
    
   
    func canvasViewDrawingDidChange(_ canvasView: PKCanvasView) {
        updateContentSIzeForDrawing()
    }
    
    
    func updateContentSIzeForDrawing() {
        let drawing = canvasView.drawing
        let contentHight: CGFloat
        
        if !drawing.bounds.isNull {
            contentHight = max(canvasView.bounds.height, (drawing.bounds.maxX + self.canvasOverscrollHight) * canvasView.zoomScale)
        } else {
            contentHight = canvasView.bounds.height
        }
        
        
        canvasView.contentSize = CGSize(width: canvasWidth * canvasView.zoomScale, height: contentHight)
    }


}

