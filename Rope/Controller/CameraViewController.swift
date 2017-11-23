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
    var isRecording = false
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var sendButton: UIButton!
    var currentRope: RopeIP!
    var imageData: Data?
    var videoURL: URL?
    
    var longpress: UILongPressGestureRecognizer!
    var tap: UITapGestureRecognizer!
    
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
        camera.backgroundColor = .black
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
    
    var ropeTitle: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .white
        label.textAlignment = .center
        label.font = UIFont(name: "extravaganzza", size: 26.0)
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
        topPanel.addSubview(ropeTitle)
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
            ropeTitle.leadingAnchor.constraint(equalTo: topPanel.leadingAnchor),
            ropeTitle.trailingAnchor.constraint(equalTo: topPanel.trailingAnchor),
            ropeTitle.bottomAnchor.constraint(equalTo: topPanel.bottomAnchor),
            ropeTitle.heightAnchor.constraint(equalToConstant: 50.0),
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
        
        currentRope = RopeIP()
        
        DataService.instance.usersRef.child((Auth.auth().currentUser?.uid)!).child("ropeIP").observe(.value, with: { (snapshot) in
            
            //if no active rope then show default prompt
            if let _ = snapshot.value as? Bool{
                self.promptPanel.isHidden = false
                self.view.bringSubview(toFront: self.promptPanel)
                self.removeGestures()
                
                let leftbutton = UIBarButtonItem(image: #imageLiteral(resourceName: "link"), style: .plain, target: self, action: nil) 
                self.navigationItem.leftBarButtonItem  = leftbutton
                
                let rightbutton = UIBarButtonItem(image: #imageLiteral(resourceName: "Plus"), style: .plain, target: self, action: #selector(self.segueToNewRope(_:)))
                self.navigationItem.rightBarButtonItem = rightbutton
                self.navigationItem.rightBarButtonItem?.tintColor = .white
                self.navigationItem.leftBarButtonItem?.tintColor = .white
                
            //if there is active rope allow user to use camera
            } else {
                
                let leftbutton = UIBarButtonItem(image: #imageLiteral(resourceName: "leaveRope"), style: .plain, target: self, action: #selector(self.leaveRope(_:)))
                self.navigationItem.leftBarButtonItem  = leftbutton
                let rightbutton = UIBarButtonItem(image: #imageLiteral(resourceName: "edit"), style: .plain, target: self, action:nil)
                self.navigationItem.rightBarButtonItem = rightbutton
                
                //set currentRope details
                if let dictionary = snapshot.value as? Dictionary<String, AnyObject> {
                    self.currentRope.id = dictionary.keys.first!
                    self.currentRope.knotCount = dictionary[dictionary.keys.first!]!["knotCount"] as? Int
                    self.currentRope.expirationDate = dictionary[dictionary.keys.first!]!["expirationDate"] as? Int
                    self.currentRope.title = dictionary[dictionary.keys.first!]!["title"] as? String
                    self.currentRope.role = dictionary[dictionary.keys.first!]!["role"] as? Int
                }
                
                self.showCamera()
                self.navigationItem.rightBarButtonItem?.tintColor = .white
                self.navigationItem.leftBarButtonItem?.tintColor = .white
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
            
            if getCameraType() == frontCameraInput {
                videoOutput.connection(with: AVMediaType.video)?.isVideoMirrored = true
            }
            
            videoOutput.startRecording(to: filePath, recordingDelegate: self)
            
            self.tabBarController?.tabBar.isHidden = true
            self.navigationController?.navigationBar.isHidden = true
            isRecording = true
            
            buttonTimer = Timer.scheduledTimer(timeInterval: 3.0, target: self, selector: #selector(cancel(_:)), userInfo: nil, repeats: false)
            animateRecordingLine()
        }
    }
    
    @objc func screenTapped(sender: UITapGestureRecognizer){
        if AVCaptureDevice.authorizationStatus(for: AVMediaType.video) ==  AVAuthorizationStatus.authorized {
            let settings = AVCapturePhotoSettings()
            photoOutput.capturePhoto(with: settings, delegate: self)
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
        showCamera()
    }
    
    @IBAction func sendMedia(_ sender: Any) {
        showCamera()
        if let videoURL = videoURL {
            let videoName = "\(NSUUID().uuidString)\(videoURL)"
            let ref = DataService.instance.storageRef.child(videoName)
            
            squareCropVideo(inputURL: videoURL, completion: { (videoURL) in
                _ = ref.putFile(from: videoURL, metadata: nil, completion: { (metadata, error) in
                    if let error = error {
                        print("error: \(error.localizedDescription)")
                    } else {
                        let downloadURL = metadata?.downloadURL()
                        self.currentRope.knotCount! += 1
                        DataService.instance.sendMedia(senderID: (Auth.auth().currentUser?.uid)!, mediaURL: downloadURL!, mediaType: "video", ropeIP: self.currentRope)
                        self.videoURL = nil
                    }
                })
            })
        } else if let image = imageData {
            let uid = NSUUID().uuidString
            let ref = DataService.instance.storageRef.child("\(uid).jpg")
            
            let image = UIImage(data: image)!
            let square = squareCropImageToSideLength(sourceImage: image, sideLength: 1080.0)
            
            _ = ref.putData(UIImagePNGRepresentation(square)!, metadata: nil, completion: {(metadata, error) in
                if let error  = error {
                    print("error: \(error.localizedDescription))")
                } else {
                    let downloadURL = metadata?.downloadURL()
                    self.currentRope.knotCount! += 1
                    DataService.instance.sendMedia(senderID: (Auth.auth().currentUser?.uid)!, mediaURL: downloadURL!, mediaType: "image", ropeIP: self.currentRope)
                }
            })
            
        }
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
    
    //default setup for camera view
    func showCamera() {
        
        ropeTitle.text = currentRope.title!
        
        longpress = UILongPressGestureRecognizer(target: self, action: #selector(longPressed(sender:)))
        longpress.minimumPressDuration = 0.2
        tap = UITapGestureRecognizer(target: self, action: #selector(screenTapped(sender:)))
        
        switch self.currentRope.role! {
        case 0:
            if !self.captureSession!.inputs.contains(self.frontCameraInput) {
                self.captureSession?.removeInput(self.backCameraInput)
                self.captureSession?.addInput(self.frontCameraInput)
            }
            if let gestures = self.view.gestureRecognizers, gestures.contains(longpress) {
                self.view.removeGestureRecognizer(longpress)
            }
            self.view.addGestureRecognizer(tap)
        case 1:
            if !self.captureSession!.inputs.contains(self.frontCameraInput) {
                self.captureSession?.removeInput(self.backCameraInput)
                self.captureSession?.addInput(self.frontCameraInput)
            }
            if let gestures = self.view.gestureRecognizers, gestures.contains(tap) {
                self.view.removeGestureRecognizer(tap)
            }
            self.view.addGestureRecognizer(longpress)
        case 2:
            if !self.captureSession!.inputs.contains(self.backCameraInput) {
                self.captureSession?.removeInput(self.frontCameraInput)
                self.captureSession?.addInput(self.backCameraInput)
            }
            if let gestures = self.view.gestureRecognizers, gestures.contains(longpress) {
                self.view.removeGestureRecognizer(longpress)
            }
            self.view.addGestureRecognizer(tap)
        case 3:
            if !self.captureSession!.inputs.contains(self.backCameraInput) {
                self.captureSession?.removeInput(self.frontCameraInput)
                self.captureSession?.addInput(self.backCameraInput)
            }
            if let gestures = self.view.gestureRecognizers, gestures.contains(tap) {
                self.view.removeGestureRecognizer(tap)
            }
            self.view.addGestureRecognizer(longpress)
        default:
            print("error setting up camera")
        }
        
        previewView.isHidden = true
        previewView.removeExistingContent()
        cancelButton.isHidden = true
        sendButton.isHidden = true
        self.navigationController?.navigationBar.isHidden = false
        self.tabBarController?.tabBar.isHidden = false
        self.shapeLayer?.removeFromSuperlayer()
    }
    
    func showMediaSetup() {
        removeGestures()
        previewView.isHidden = false
        self.cancelButton.isHidden = false
        self.sendButton.isHidden = false
        self.tabBarController?.tabBar.isHidden = true
        self.navigationController?.navigationBar.isHidden = true
        self.view.bringSubview(toFront: topPanel)
        self.view.bringSubview(toFront: bottomPanel)
        self.view.bringSubview(toFront: cancelButton)
        self.view.bringSubview(toFront: sendButton)
    }
    
    func removeGestures() {
        if let gestures = self.view.gestureRecognizers{
            if gestures.contains(longpress) {
                self.view.removeGestureRecognizer(longpress)
            } else if gestures.contains(tap) {
                self.view.removeGestureRecognizer(tap)
            }
        }
    }
    
    
    //crop video to Square
    func squareCropVideo(inputURL: URL, completion: @escaping (_ outputURL : URL) -> ()){
        let asset = AVAsset.init(url: inputURL)
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
                    completion(croppedOutputFileUrl)
                })
                return
            } else if exportSession.status == .failed {
                print("Export failed - \(String(describing: exportSession.error))")
            }
            return
            
        })
        
    }
    
    private func squareCropImageToSideLength(sourceImage: UIImage, sideLength: CGFloat) -> UIImage {
        // input size comes from image
        let inputSize: CGSize = sourceImage.size
        
        // round up side length to avoid fractional output size
        let sideLength: CGFloat = ceil(sideLength)
        
        // output size has sideLength for both dimensions
        let outputSize: CGSize = CGSize(width: sideLength,height:  sideLength)
        
        // calculate scale so that smaller dimension fits sideLength
        let scale: CGFloat = max(sideLength / inputSize.width,
                                 sideLength / inputSize.height)
        
        // scaling the image with this scale results in this output size
        let scaledInputSize: CGSize = CGSize(width: inputSize.width * scale, height: inputSize.height * scale)
        
        // determine point in center of "canvas"
        let center: CGPoint = CGPoint(x: outputSize.width/2.0, y: outputSize.height/2.0)
        
        // calculate drawing rect relative to output Size
        let outputRect: CGRect = CGRect(x: center.x - scaledInputSize.width/2.0,
                                        y: center.y - scaledInputSize.height/2.0,
                                        width: scaledInputSize.width,
                                        height: scaledInputSize.height)
        
        // begin a new bitmap context, scale 0 takes display scale
        UIGraphicsBeginImageContextWithOptions(outputSize, true, 0)
        
        // optional: set the interpolation quality.
        // For this you need to grab the underlying CGContext
        let ctx: CGContext = UIGraphicsGetCurrentContext()!
        ctx.interpolationQuality = .high
        
        // draw the source image into the calculated rect
        sourceImage.draw(in: outputRect)
        
        // create new image from bitmap context
        let outImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        
        // clean up
        UIGraphicsEndImageContext()
        
        // pass back new image
        return outImage
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
        
        if getCameraType() == frontCameraInput {
            //Fixed mirrored videos for back camera.
            self.imageData = UIImagePNGRepresentation(UIImage(cgImage: cgImageRef!, scale: 1.0, orientation: .leftMirrored))
            previewView.displayImage(UIImage(cgImage: cgImageRef!, scale: 1.0, orientation: .leftMirrored))
            showMediaSetup()
        } else {
            //Otherwise just submit regular image.
            self.imageData = imageData
            previewView.displayImage(UIImage(cgImage: cgImageRef!, scale: 1.0, orientation: .right))
            showMediaSetup()
        }
        
    }
}

//This class implements AVCaptureFileOutputRecordingDelegate so it can handle the videos that are recorded.
extension CameraViewController: AVCaptureFileOutputRecordingDelegate {
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        if error != nil {
            print("Error Recording from CameraView:AVCaptureFileOutputRecordingDelegate#capture: \(String(describing: error?.localizedDescription))")
            showCamera()
            
        } else {
            self.shapeLayer?.removeFromSuperlayer()
            self.videoURL = outputFileURL
            let player = AVPlayer(url: outputFileURL)
            previewView.displayVideo(player)
            showMediaSetup()
            
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

