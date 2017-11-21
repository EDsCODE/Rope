//
//  ChildTwoViewController.swift
//  Rope
//
//  Created by Eric Duong on 10/26/17.
//  Copyright © 2017 Rope. All rights reserved.
//

import UIKit
import SwiftyCam
import AVFoundation
import Firebase

class CameraViewController: UIViewController {
    
    weak var buttonTimer: Timer?
    weak var shapeLayer: CAShapeLayer?
    var capturedURL: URL?
    var isRecording = false
    @IBOutlet weak var cancelButton: UIButton!
    var currentRope: RopeIP?
    
    //Camera stuff
    var captureSession: AVCaptureSession?
    var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    var photoOutput: AVCapturePhotoOutput!
    var videoOutput: AVCaptureMovieFileOutput!
    var backCameraInput: AVCaptureDeviceInput!
    var frontCameraInput: AVCaptureDeviceInput!
    var microphoneInput: AVCaptureDeviceInput!
    
    var topPanel: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.dark)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = view.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(blurEffectView)
        return view
    }()
    
    var promptPanel: UIView = {
        let textView = UIView()
        textView.translatesAutoresizingMaskIntoConstraints = false
        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.dark)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = textView.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        textView.addSubview(blurEffectView)
        return textView
    }()
    
    var bottomPanel: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.dark)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = view.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(blurEffectView)
        return view
    }()
    
    var previewView: PreviewView = {
        let preview = PreviewView()
        preview.translatesAutoresizingMaskIntoConstraints = false
        preview.isHidden = true
        return preview
    }()
    
    var cameraView: UIView = {
        let camera = UIView()
        camera.translatesAutoresizingMaskIntoConstraints = false
        camera.isHidden = false
        camera.backgroundColor = .green
        return camera
    }()
    
    var promptText: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 2
        label.lineBreakMode = .byWordWrapping
        label.textColor = .white
        label.textAlignment = .center
        label.font = UIFont(name: "extravaganzza", size: 18.0)
        label.text = "You are currently not in a Rope. Create or join one to get started!"
        return label
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //perform necessary setup for camera view
        setupCamera()
        
        //determine if current user is in a Rope
        determineRopeInProgress()
        
        self.view.addSubview(cameraView)
        self.view.addSubview(topPanel)
        self.view.addSubview(bottomPanel)
        self.view.addSubview(previewView)
        self.view.addSubview(promptPanel)
        promptPanel.addSubview(promptText)
        

        
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = UIImage.imageWithColor(color: UIColor(displayP3Red: 100.0, green: 100.0, blue: 100.0, alpha: 0.5))
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.navigationBar.titleTextAttributes =
            [
                NSAttributedStringKey.font: UIFont(name: "extravaganzza", size: 28)!,
                NSAttributedStringKey.foregroundColor: UIColor.white
            ]
        
        let constraints = [
            cameraView.topAnchor.constraint(equalTo: self.view.topAnchor),
            cameraView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            cameraView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            cameraView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            topPanel.topAnchor.constraint(equalTo: self.view.topAnchor),
            topPanel.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            topPanel.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            topPanel.heightAnchor.constraint(equalToConstant: (self.view.bounds.height - self.view.bounds.width) / 2),
            bottomPanel.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            bottomPanel.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            bottomPanel.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            bottomPanel.heightAnchor.constraint(equalToConstant: (self.view.bounds.height - self.view.bounds.width) / 2),
            previewView.topAnchor.constraint(equalTo: self.view.topAnchor),
            previewView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            previewView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            previewView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            promptPanel.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            promptPanel.topAnchor.constraint(equalTo: self.view.topAnchor),
            promptPanel.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            promptPanel.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            promptText.centerXAnchor.constraint(equalTo: promptPanel.centerXAnchor),
            promptText.centerYAnchor.constraint(equalTo: promptPanel.centerYAnchor),
            promptText.widthAnchor.constraint(equalTo: promptPanel.widthAnchor, multiplier: 0.8)
        ]
        NSLayoutConstraint.activate(constraints)
    }
    
    func setupCamera() {
        captureSession = AVCaptureSession()
        photoOutput = AVCapturePhotoOutput()
        videoOutput = AVCaptureMovieFileOutput()
        captureSession?.addOutput(photoOutput)
        captureSession?.addOutput(videoOutput)
        
        let backCamera: AVCaptureDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: AVMediaType.video, position: .back)!
        let frontCamera: AVCaptureDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: AVMediaType.video, position: .front)!
        let microphone: AVCaptureDevice = AVCaptureDevice.default(for: AVMediaType.audio)!
        do {
            backCameraInput = try AVCaptureDeviceInput(device: backCamera)
            frontCameraInput = try AVCaptureDeviceInput(device: frontCamera)
            microphoneInput = try AVCaptureDeviceInput(device: microphone)
            captureSession?.addInput(backCameraInput)
            captureSession?.addInput(microphoneInput)
            videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession!)
            videoPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
            videoPreviewLayer?.frame = view.layer.bounds
            cameraView.layer.addSublayer(videoPreviewLayer!)
            captureSession?.startRunning()
        } catch {
            print(error)
        }
    
    }
    
    func determineRopeInProgress() {
        
        let longpress = UILongPressGestureRecognizer(target: self, action: #selector(longPressed(sender:)))
        
        DataService.instance.usersRef.child((Auth.auth().currentUser?.uid)!).child("ropeIP").observe(.value, with: { (snapshot) in
            
            //if no active rope then show default prompt
            if let _ = snapshot.value as? Bool{
                self.promptPanel.isHidden = false
                self.view.bringSubview(toFront: self.promptPanel)
                self.view.removeGestureRecognizer(longpress)
                
                let leftbutton = UIBarButtonItem(image: #imageLiteral(resourceName: "link"), style: .plain, target: self, action: nil) 
                self.navigationItem.leftBarButtonItem  = leftbutton
                
                let rightbutton = UIBarButtonItem(image: #imageLiteral(resourceName: "Plus"), style: .plain, target: self, action: #selector(self.segueToNewRope(_:)))
                self.navigationItem.rightBarButtonItem = rightbutton
                self.navigationItem.rightBarButtonItem?.tintColor = .white
                self.navigationItem.leftBarButtonItem?.tintColor = .white
                
            //if there is active rope allow user to user camera
            } else {
                print(snapshot.value!)
                let leftbutton = UIBarButtonItem(image: #imageLiteral(resourceName: "leaveRope"), style: .plain, target: self, action: #selector(self.leaveRope(_:)))
                self.navigationItem.leftBarButtonItem  = leftbutton
                let rightbutton = UIBarButtonItem(image: #imageLiteral(resourceName: "edit"), style: .plain, target: self, action:nil)
                self.navigationItem.rightBarButtonItem = rightbutton
                
                self.navigationItem.rightBarButtonItem?.tintColor = .white
                self.navigationItem.leftBarButtonItem?.tintColor = .white
                longpress.minimumPressDuration = 0.2
                self.view.addGestureRecognizer(longpress)
                self.promptPanel.isHidden = true
                
            }
            
        })
    }
    
    @objc func leaveRope(_ sneder: UIBarButtonItem){
        let alert = UIAlertController(title: "Leaving Rope", message: "Are you sure you want to leave this Rope?", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Confirm", style: .default, handler: { _ in
            DataService.instance.leaveCurrentRope()
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    @objc func segueToNewRope(_ sender: UIBarButtonItem){
        performSegue(withIdentifier: "toNewRope", sender: self)
    }
    
    //use for recording
    @objc func longPressed(sender: UILongPressGestureRecognizer){
        if sender.state == .ended {
            if isRecording == true {
                print("UIGestureRecognizerStateEnded")
                videoOutput.stopRecording()
                pause(shapeLayer!)
                self.buttonTimer?.invalidate()
            }
            isRecording = false
            //Do Whatever You want on End of Gesture
        } else if sender.state == .began {
            print("UIGestureRecognizerStateBegan.")
            
            let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let filePath = documentsURL.appendingPathComponent("temp.mp4")
            videoOutput.startRecording(to: filePath, recordingDelegate: self)
            
            self.tabBarController?.tabBar.isHidden = true
            self.navigationController?.navigationBar.isHidden = true
            isRecording = true
            
            buttonTimer = Timer.scheduledTimer(timeInterval: 3.0, target: self, selector: #selector(cancel(_:)), userInfo: nil, repeats: false)
            animateRecordingLine()
        }
        
    }
    
    ///Returns the current camera type associated with the Capture Session
    public func getCameraType() -> AVCaptureDeviceInput? {
        let inputs = captureSession?.inputs as! [AVCaptureDeviceInput]
        if inputs.contains(backCameraInput) {
            return backCameraInput
        } else if inputs.contains(frontCameraInput) {
            return frontCameraInput
        } else {
            return nil
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.shared.statusBarStyle = .lightContent
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        UIApplication.shared.statusBarStyle = .default
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @objc func cancel(_ timerObject: Timer) {
        print("cancel")
        if isRecording == true {
            videoOutput.stopRecording()
            pause(shapeLayer!)
            self.buttonTimer?.invalidate()
        }
        isRecording = false
    }
    
    @IBAction func dismissPreview(_ sender: Any) {
        previewView.isHidden = true
        previewView.removeExistingContent()
        cancelButton.isHidden = true
        self.capturedURL = nil
        self.tabBarController?.tabBar.isHidden = false
        self.navigationController?.navigationBar.isHidden = false
    }
    
    func animateRecordingLine() {
        self.shapeLayer?.removeFromSuperlayer()
        
        // create whatever path you want
        
        let path = UIBezierPath()
        path.move(to: CGPoint(x: 0, y: bottomPanel.frame.minY))
        path.addLine(to: CGPoint(x: self.view.bounds.width, y: bottomPanel.frame.minY))
        
        // create shape layer for that path
        
        let shapeLayer = CAShapeLayer()
        shapeLayer.fillColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0).cgColor
        shapeLayer.strokeColor = #colorLiteral(red: 1, green: 0, blue: 0, alpha: 1).cgColor
        shapeLayer.lineWidth = 4
        shapeLayer.path = path.cgPath
        
        // animate it
        
        view.layer.addSublayer(shapeLayer)
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.fromValue = 0
        animation.duration = 3.0
        shapeLayer.add(animation, forKey: "MyAnimation")
        
        // save shape layer
        
        self.shapeLayer = shapeLayer
    }
    
    //pause animation
    func pause(_ theLayer: CALayer) {
        let mediaTime: CFTimeInterval = CACurrentMediaTime()
        let pausedTime: CFTimeInterval = theLayer.convertTime(mediaTime, from: nil)
        theLayer.speed = 0.0
        theLayer.timeOffset = pausedTime
    }
    
    func squareCropVideo(inputURL: NSURL, completion: @escaping (_ outputURL : NSURL?) -> ()){
        let asset = AVAsset.init(url: inputURL as URL)
        print (asset)
        let composition = AVMutableComposition.init()
        composition.addMutableTrack(withMediaType: AVMediaType.video, preferredTrackID: kCMPersistentTrackID_Invalid)
        
        //input clip
        let clipVideoTrack = asset.tracks(withMediaType: AVMediaType.video)[0]
        
        //make it square
        let videoComposition = AVMutableVideoComposition()
        videoComposition.renderSize = CGSize(width: CGFloat(clipVideoTrack.naturalSize.height), height: CGFloat(clipVideoTrack.naturalSize.height))
        videoComposition.frameDuration = CMTimeMake(1, 30)
        let instruction = AVMutableVideoCompositionInstruction()
        instruction.timeRange = CMTimeRangeMake(kCMTimeZero, CMTimeMakeWithSeconds(60, 30))
        
        //rotate to potrait
        let transformer = AVMutableVideoCompositionLayerInstruction(assetTrack: clipVideoTrack)
        let t1 = CGAffineTransform(translationX: clipVideoTrack.naturalSize.height, y: -(clipVideoTrack.naturalSize.width - clipVideoTrack.naturalSize.height) / 2)
        let t2: CGAffineTransform = t1.rotated(by: .pi/2)
        let finalTransform: CGAffineTransform = t2
        transformer.setTransform(finalTransform, at: kCMTimeZero)
        instruction.layerInstructions = [transformer]
        videoComposition.instructions = [instruction]
        
        let croppedOutputFileUrl = URL( fileURLWithPath: getOutputPath( NSUUID().uuidString ) )
        let exportSession = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetHighestQuality)!
        exportSession.videoComposition = videoComposition
        exportSession.outputURL = croppedOutputFileUrl
        exportSession.outputFileType = AVFileType.mov
        
        exportSession.exportAsynchronously( completionHandler: { () -> Void in
            
            if exportSession.status == .completed {
                DispatchQueue.main.async(execute: {
                    completion(croppedOutputFileUrl as NSURL)
                })
                return
            } else if exportSession.status == .failed {
                print("Export failed - \(String(describing: exportSession.error))")
            }
            
            completion(nil)
            return
            
        })
        
    }
    
    func getOutputPath( _ name: String ) -> String {
        let documentPath = NSSearchPathForDirectoriesInDomains( .documentDirectory, .userDomainMask, true )[ 0 ] as NSString
        let outputPath = "\(documentPath)/\(name).mov"
        return outputPath
    }
    
}

///This class implements AVCapturePhotoCaptureDelegate so it can handle the photos that are taken.
extension CameraViewController: AVCapturePhotoCaptureDelegate {
    
    ///Upon photo capture, renders the image in a UIImageView and submit it to the Camera View Delegate.
    func photoOutput(_ captureOutput: AVCapturePhotoOutput, didFinishProcessingPhoto photoSampleBuffer: CMSampleBuffer?, previewPhoto previewPhotoSampleBuffer: CMSampleBuffer?, resolvedSettings: AVCaptureResolvedPhotoSettings, bracketSettings: AVCaptureBracketedStillImageSettings?, error: Error?) {
        
        let imageData = AVCapturePhotoOutput.jpegPhotoDataRepresentation(forJPEGSampleBuffer: photoSampleBuffer!, previewPhotoSampleBuffer: previewPhotoSampleBuffer)
        
        let dataProvider = CGDataProvider(data: imageData! as CFData)
        
        let cgImageRef = CGImage(jpegDataProviderSource: dataProvider!, decode: nil, shouldInterpolate: true, intent: .defaultIntent)
        
//        if getCameraType() == frontCameraInput {
//            //Fixed mirrored videos for back camera.
//            delegate.submit(image: UIImage(cgImage: cgImageRef!, scale: 1.0, orientation: .leftMirrored))
//        } else {
//            //Otherwise just submit regular image.
//            delegate.submit(image: UIImage(cgImage: cgImageRef!, scale: 1.0, orientation: .right))
//        }
        
    }
}

//This class implements AVCaptureFileOutputRecordingDelegate so it can handle the videos that are recorded.
extension CameraViewController: AVCaptureFileOutputRecordingDelegate {
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        if error != nil {
            print("Error Recording from CameraView:AVCaptureFileOutputRecordingDelegate#capture: \(String(describing: error?.localizedDescription))")
            previewView.isHidden = true
            previewView.removeExistingContent()
            cancelButton.isHidden = true
            self.capturedURL = nil
            self.navigationController?.navigationBar.isHidden = false
            self.tabBarController?.tabBar.isHidden = false
            self.shapeLayer?.removeFromSuperlayer()
        } else {
            
            self.shapeLayer?.removeFromSuperlayer()
            
            let player = AVPlayer(url: outputFileURL)
            previewView.displayVideo(player)
            previewView.isHidden = false
            self.cancelButton.isHidden = false
            
            self.view.bringSubview(toFront: topPanel)
            self.view.bringSubview(toFront: bottomPanel)
            self.view.bringSubview(toFront: cancelButton)
            
        }
    }
}


extension UIImage {
    class func imageWithColor(color: UIColor) -> UIImage {
        let rect = CGRect(x: 0.0, y: 0.0, width: 1.0, height: 0.5)
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0.0)
        color.setFill()
        UIRectFill(rect)
        let image : UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return image
    }
}

