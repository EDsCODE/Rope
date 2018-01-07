//
//  ScannerViewController.swift
//  Rope
//
//  Created by Eric Duong on 11/27/17.
//  Copyright © 2017 Rope. All rights reserved.
//

import AVFoundation
import UIKit

class ScannerViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    var captureSession: AVCaptureSession!
    var previewLayer: AVCaptureVideoPreviewLayer!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var promptLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        cancelButton.layer.shadowColor = UIColor.black.cgColor
        cancelButton.layer.shadowOffset = CGSize(width: 0.0, height: 1.0)
        cancelButton.layer.shadowRadius = 2
        cancelButton.layer.shadowOpacity = 0.5
        
        view.backgroundColor = UIColor.black
        captureSession = AVCaptureSession()
        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else { return }
        let videoInput: AVCaptureDeviceInput
        
        do {
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
        } catch {
            return
        }
        
        if (captureSession.canAddInput(videoInput)) {
            captureSession.addInput(videoInput)
        } else {
            failed()
            return
        }
        
        let metadataOutput = AVCaptureMetadataOutput()
        
        if (captureSession.canAddOutput(metadataOutput)) {
            captureSession.addOutput(metadataOutput)
            
            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = metadataOutput.availableMetadataObjectTypes
        } else {
            failed()
            return
        }
        
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = view.layer.bounds
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)
        
        captureSession.startRunning()
        let overlay = createOverlay(frame: view.frame)
        view.addSubview(overlay)
        view.bringSubview(toFront: cancelButton)
        view.bringSubview(toFront: promptLabel)
    }
    
    func failed() {
        let ac = UIAlertController(title: "Scanning not supported", message: "Your device does not support scanning a code from an item. Please use a device with a camera.", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
        captureSession = nil
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if (captureSession?.isRunning == false) {
            captureSession.startRunning()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if (captureSession?.isRunning == true) {
            captureSession.stopRunning()
        }
    }
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        
        if let metadataObject = metadataObjects.first, metadataObject.type == .qr {
            captureSession.stopRunning()
            guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject else { return }
            guard let stringValue = readableObject.stringValue else { return }
            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
            found(code: stringValue)
        }
    }
    
    func found(code: String) {
        
        DataService.instance.mainRef.child("ropesIP").observeSingleEvent(of: .value) { (snapshot) in
            if snapshot.hasChild(code) {
                DataService.instance.join(ropeID: code, completion: { (result) in
                    if result {
                        self.dismiss(animated: false, completion: nil)
                    } else {
                        self.codeNotValid()
                    }
                })
            } else {
                self.codeNotValid()
            }
        }
    }
    
    func codeNotValid() {
        let alert = UIAlertController(title: "Invalid QR Code", message: "This is not a Rope QR code", preferredStyle: UIAlertControllerStyle.alert)
        let action = UIAlertAction(title: "Ok", style: .cancel, handler: { (_) in
            self.captureSession.startRunning()
        })
        action.setValue(UIColor.black, forKey: "titleTextColor")
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
    }
    
    func createOverlay(frame : CGRect) -> UIView
    {
        let overlayView = UIView(frame: frame)
        overlayView.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        
        let path = CGMutablePath()
        path.addRect(CGRect(x: 20.0, y: self.view.frame.midY / 2, width: self.view.frame.width - 40, height: self.view.frame.width - 40))
        path.addRect(CGRect(origin: .zero, size: overlayView.frame.size))
        
        let maskLayer = CAShapeLayer()
        maskLayer.backgroundColor = UIColor.black.cgColor
        maskLayer.path = path
        maskLayer.fillRule = kCAFillRuleEvenOdd
        
        overlayView.layer.mask = maskLayer
        overlayView.clipsToBounds = true
        
        return overlayView
    }
    
    @IBAction func closeView(_ sender: Any) {
        captureSession.stopRunning()
        dismiss(animated: false, completion: nil)
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
}
