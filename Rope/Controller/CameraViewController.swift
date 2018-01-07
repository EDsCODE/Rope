//
//  ChildTwoViewController.swift
//  Rope
//
//  Created by Eric Duong on 10/26/17.
//  Copyright © 2017 Rope. All rights reserved.
//

import UIKit
import AVFoundation
import Firebase
import Compression
import PromiseKit

enum CustomError : Error {
    case unwrap
    case thumbnailFail
}

class CameraViewController: UIViewController {
    
    weak var buttonTimer: Timer?
    weak var shapeLayer: CAShapeLayer?
    var isRecording = false
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var sendButton: UIButton!
    var currentRope: RopeIP?
    var imageData: Data?
    var videoURL: URL?
    
    var progressDict: [String: Int] = [:]
    
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
    //var captureMetadataOutput: AVCaptureMetadataOutput!
    
    
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
        label.font = UIFont(name: "Nunito-SemiBold", size: 16.0)
        label.text = "You are currently not in a Rope. Create or join one to get started!"
        return label
    }()
    
    var ropeTitle: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .white
        label.textAlignment = .center
        label.font = UIFont(name: "Nunito-Regular", size: 26.0)
        return label
    }()
    
    var roleButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isHidden = true
        button.imageView?.contentMode = .scaleAspectFill
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOffset = CGSize(width: 0.0, height: 1.0)
        button.layer.shadowRadius = 2
        button.layer.shadowOpacity = 0.5
        button.tintColor = .white
        return button
    }()
    
    var knotView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isHidden = true
        view.layer.cornerRadius = 5.0
        view.backgroundColor = .white
        return view
    }()
    
    var knotCountLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.isHidden = true
        label.textAlignment = .right
        label.textColor = .white
        label.text = "0"
        label.font = UIFont(name: "Nunito-Regular", size: 16.0)
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //record gesture
        longpress = UILongPressGestureRecognizer(target: self, action: #selector(longPressed(sender:)))
        longpress.minimumPressDuration = 0.0
        
        //perform necessary setup for camera view
        if AVCaptureDevice.authorizationStatus(for: AVMediaType.video) ==  AVAuthorizationStatus.authorized {
            setupCamera()
        } else {
            AVCaptureDevice.requestAccess(for: AVMediaType.video, completionHandler: { (granted: Bool) -> Void in
                if granted == true {
                    DispatchQueue.main.async {
                        self.setupCamera()
                    }
                } else {
                    let alert = UIAlertController(title: nil, message: "This app requires access to your camera to proceed. Please open settings and grant permission to camera.", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Open Settings", style: .default) { action in
                        UIApplication.shared.open(URL(string: UIApplicationOpenSettingsURLString)!)
                    })
                    self.present(alert, animated: true, completion: nil)
                }
            })
        }
        
        
        
        //determine if current user is in a Rope
        determineRopeInProgress()

        //add views
        self.view.addSubview(cameraView)
        self.view.addSubview(previewView)
        self.view.addSubview(promptPanel)
        self.view.addSubview(knotView)
        self.view.addSubview(knotCountLabel)
        self.view.addSubview(roleButton)
        promptPanel.addSubview(promptText)
        
        //cancel button shadow
        cancelButton.layer.shadowColor = UIColor.black.cgColor
        cancelButton.layer.shadowOffset = CGSize(width: 0.0, height: 1.0)
        cancelButton.layer.shadowRadius = 2
        cancelButton.layer.shadowOpacity = 0.5
        
        //sendbutton shadow and color
        sendButton.tintColor = .white
        sendButton.layer.shadowColor = UIColor.black.cgColor
        sendButton.layer.shadowOffset = CGSize(width: 0.0, height: 1.0)
        sendButton.layer.shadowRadius = 2
        sendButton.layer.shadowOpacity = 0.5
        
        knotCountLabel.layer.shadowColor = UIColor.black.cgColor
        knotCountLabel.layer.shadowOffset = CGSize(width: 0.0, height: 1.0)
        knotCountLabel.layer.shadowRadius = 2
        knotCountLabel.layer.shadowOpacity = 0.5
        
        knotView.layer.shadowColor = UIColor.black.cgColor
        knotView.layer.shadowOffset = CGSize(width: 0.0, height: 1.0)
        knotView.layer.shadowRadius = 2
        knotView.layer.shadowOpacity = 0.5
        
        //set tabbar color
        self.tabBarController?.tabBar.backgroundColor = UIColor(displayP3Red: 0.0, green: 0.0, blue: 0.0, alpha: 0.4)
        
        //top gradient
        let colorTop = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.4).cgColor
        let colorBottom = UIColor.clear.cgColor
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [colorTop, colorBottom]
        gradientLayer.locations = [ 0.0, 1.0]
        gradientLayer.frame = CGRect(x:0, y:-20, width:self.view.frame.width, height:(self.navigationController?.navigationBar.frame.height)! + 80)
        
        let background = image(from: gradientLayer)
        
        self.navigationController?.navigationBar.setBackgroundImage(background, for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.navigationBar.titleTextAttributes =
            [
                NSAttributedStringKey.font: UIFont(name: "Nunito-Regular", size: 24)!,
                NSAttributedStringKey.foregroundColor: UIColor.white
            ]
        
        let constraints = [
            cameraView.topAnchor.constraint(equalTo: self.view.topAnchor),
            cameraView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            cameraView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            cameraView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
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
            promptText.widthAnchor.constraint(equalTo: promptPanel.widthAnchor, multiplier: 0.8),
            roleButton.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 15.0),
            roleButton.topAnchor.constraint(equalTo: self.view.topAnchor, constant: self.view.frame.height * 0.1),
            roleButton.widthAnchor.constraint(equalToConstant: 30.0),
            roleButton.heightAnchor.constraint(equalToConstant: 30.0),
            knotView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -15.0),
            knotView.centerYAnchor.constraint(equalTo: roleButton.centerYAnchor),
            knotView.widthAnchor.constraint(equalToConstant: 10.0),
            knotView.heightAnchor.constraint(equalToConstant: 10.0),
            knotCountLabel.trailingAnchor.constraint(equalTo: knotView.leadingAnchor, constant: -5.0),
            knotCountLabel.centerYAnchor.constraint(equalTo: roleButton.centerYAnchor),
            knotCountLabel.widthAnchor.constraint(equalToConstant: 50.0),
            knotCountLabel.heightAnchor.constraint(equalToConstant: 30.0)
        ]
        
        NSLayoutConstraint.activate(constraints)
    }
    
    func image(from layer: CALayer) -> UIImage {
        UIGraphicsBeginImageContext(layer.frame.size)
        layer.render(in: UIGraphicsGetCurrentContext()!)
        let outputImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return outputImage ?? UIImage()
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
    
    func noRopeIPLayout() {
        print("noRopeIPLayout")
        self.removeGestures()
        self.promptPanel.isHidden = false
        self.navigationController?.navigationBar.topItem?.title = "Knot"
        self.view.bringSubview(toFront: self.promptPanel)
        self.promptText.isHidden = false
        
        let leftbutton = UIBarButtonItem(image:#imageLiteral(resourceName: "qrcode"), style: .plain, target: self, action: #selector(self.showScanner(_:)))
        self.navigationItem.leftBarButtonItem  = leftbutton
        
        
        let rightbutton = UIBarButtonItem(image: #imageLiteral(resourceName: "plus_test"), style: .plain, target: self, action: #selector(self.segueToNewRope(_:)))
        self.navigationItem.rightBarButtonItem = rightbutton
        self.navigationItem.rightBarButtonItem?.tintColor = .white
        self.navigationItem.leftBarButtonItem?.tintColor = .white
    }
    
    func determineRopeInProgress() {
        
        DataService.instance.usersRef.child((Auth.auth().currentUser?.uid)!).child("ropeIP").observe(.value, with: { (snapshot) in
            
            //if no active rope then show default prompt
            if let _ = snapshot.value as? Bool {
                self.noRopeIPLayout()
                
            //if there is active rope allow user to use camera
            } else {
                
                let leftbutton = UIBarButtonItem(image: #imageLiteral(resourceName: "leaveRope"), style: .plain, target: self, action: #selector(self.leaveRope(_:)))
                self.navigationItem.leftBarButtonItem  = leftbutton
                let rightbutton = UIBarButtonItem(image:#imageLiteral(resourceName: "qrcode"), style: .plain, target: self, action:#selector(self.showRopeIPDetails(_:)))
                self.navigationItem.rightBarButtonItem = rightbutton
                
                //set currentRope details
                if let dictionary = snapshot.value as? Dictionary<String, AnyObject> {
                    let id = dictionary.keys.first!
                    let expirationDate = dictionary[dictionary.keys.first!]!["expirationDate"] as! Int
                    let title = dictionary[dictionary.keys.first!]!["title"] as! String
                    let role = dictionary[dictionary.keys.first!]!["role"] as! Int
                    let contribution = dictionary[dictionary.keys.first!]!["contribution"] as! Int
                    self.currentRope = RopeIP(expirationDate: expirationDate, participants: [], title: title, id: id, role: role, contribution: contribution)
                    self.knotCountLabel.text = "\(5 - contribution)"
                }
                
                self.showCamera()
                self.navigationItem.rightBarButtonItem?.tintColor = .white
                self.navigationItem.leftBarButtonItem?.tintColor = .white
                self.promptPanel.isHidden = true
                
            }
            
        })
    }
    
    @objc func showScanner(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: "showQRscanner", sender: self)
    }
    
    @objc func showRopeIPDetails(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: "showRopeIPDetails", sender: self)
    }
    
    @objc func leaveRope(_ sender: UIBarButtonItem){
        let alert = UIAlertController(title: "Leaving Rope", message: "Are you sure you want to leave this Rope?", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Confirm", style: .default, handler: { _ in
            DataService.instance.leaveCurrentRope()
            self.currentRope = nil
            self.progressDict = [:]
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
            
            self.roleButton.isHidden = true
            self.knotCountLabel.isHidden = true
            self.knotView.isHidden = true
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
    
//    func compressVideo(inputURL: URL, outputURL: URL, handler:@escaping (_ exportSession: AVAssetExportSession?)-> Void) {
//        let urlAsset = AVURLAsset(url: inputURL, options: nil)
//        guard let exportSession = AVAssetExportSession(asset: urlAsset, presetName: AVAssetExportPreset960x540) else {
//            handler(nil)
//
//            return
//        }
//
//        exportSession.outputURL = outputURL
//        exportSession.outputFileType = AVFileType.mov
//        exportSession.shouldOptimizeForNetworkUse = true
//        exportSession.exportAsynchronously { () -> Void in
//            handler(exportSession)
//        }
//    }
    
    func compressVideo(inputURL: URL, outputURL: URL) -> Promise<AVAssetExportSession> {
        let urlAsset = AVURLAsset(url: inputURL, options: nil)
        guard let exportSession = AVAssetExportSession(asset: urlAsset, presetName: AVAssetExportPreset960x540) else {
            return Promise(error: CustomError.unwrap)
        }
        return Promise { fulfill, reject in
            exportSession.outputURL = outputURL
            exportSession.outputFileType = AVFileType.mov
            exportSession.shouldOptimizeForNetworkUse = true
            exportSession.exportAsynchronously { () -> Void in
                if let err = exportSession.error {
                    reject(err)
                } else {
                    fulfill(exportSession)
                }
            }
        }
    }
    
    func uploadFile(url: URL) -> Promise<URL> {
        let videoName = "\(NSUUID().uuidString)\((url))"
        let ref = DataService.instance.storageRef.child(videoName)
        return Promise { fulfill, reject in
            _ = ref.putFile(from: url, metadata: nil, completion: { (metadata, error) in
                if let error = error {
                    reject(error)
                } else {
                    let downloadURL = metadata!.downloadURL()
                    fulfill(downloadURL!)
                }
            })
            
        }
    }
    
    @IBAction func sendMedia(_ sender: Any) {
        showCamera()
        let task = UIApplication.shared.beginBackgroundTask(expirationHandler: nil)
        
        currentRope!.contribution += 1
        knotCountLabel.text = "\(5 - currentRope!.contribution)"
        DataService.instance.updateContribution(currentRope!.id, currentRope!.contribution)
        
        print(currentRope!.contribution)
        
        let copyRopeIP = self.currentRope!.copy() as! RopeIP
        if let videoURL = self.videoURL {
            let asset = AVURLAsset(url: videoURL, options: nil)
            let imgGenerator = AVAssetImageGenerator(asset: asset)
            imgGenerator.appliesPreferredTrackTransform = true
            do {
                let cgImage = try imgGenerator.copyCGImage(at: CMTimeMake(0, 1), actualTime: nil)
                let thumbnail = UIImage(cgImage: cgImage)
                let data = NSData(contentsOf: videoURL as URL)!
                let key = DataService.instance.mainRef.childByAutoId().key
                if self.currentRope != nil {
                    self.progressDict[key] = 0
                    print(self.progressDict)
                }
                print("File size before compression: \(Double(data.length / 1048576)) mb")
                
                let compressedURL = NSURL.fileURL(withPath: NSTemporaryDirectory() + NSUUID().uuidString + ".m4v")
                print("starting task")
                
                //promise chain for compressing/uploading/updating
                    self.compressVideo(inputURL: videoURL, outputURL: compressedURL)
                        .then{ exportSession -> Promise<URL> in
                            self.uploadFile(url: exportSession.outputURL!)
                        }.then{ downloadURL -> Promise<Bool> in
                            return DataService.instance.sendMedia(senderID: (Auth.auth().currentUser?.uid)!, mediaURL: downloadURL, mediaType: "video", ropeIP: copyRopeIP, thumbnailImage: thumbnail, key: key)
                        }.then{ _ -> Void in
                            UIApplication.shared.endBackgroundTask(task)
                            DispatchQueue.main.async {
                                if let rope = self.currentRope {
                                    rope.printdetail()
                                    self.progressDict[key] = 1
                                }
                                print(self.progressDict)
                                print("Successfully uploaded knot")
                            }
                        }.catch{ error -> Void in
                            print(error)
                            if let _ = self.currentRope{
                                self.progressDict[key] = -1
                            }
                    }
                
            } catch {
                print("Thumbnail Fail")
            }
        }
        if currentRope!.contribution >= 5 {
            print("leaving")
            self.view.removeGestureRecognizer(longpress)
            self.noRopeIPLayout()
            DispatchQueue.main.async {
                self.currentRope = nil
                DataService.instance.leaveCurrentRope()
                self.progressDict = [:]
            }
        }
            //DispatchQueue.global(qos: .background).async {
//                print("starting task")
//                self.compressVideo(inputURL: videoURL, outputURL: compressedURL) { (exportSession) in
//                    guard let session = exportSession else {
//                        print("export session cmopression failed")
//                        return
//                    }
//
//                    switch session.status {
//
//                    case .completed:
//
//                        guard let compressedData = NSData(contentsOf: (exportSession?.outputURL!)!) else {
//                            print("compress data failed")
//                            return
//                        }
//
//                        let videoName = "\(NSUUID().uuidString)\((exportSession?.outputURL!)!)"
//                        let ref = DataService.instance.storageRef.child(videoName)
//                        _ = ref.putFile(from: (exportSession?.outputURL!)!, metadata: nil, completion: { (metadata, error) in
//                            if let error = error {
//                                print("error: \(error.localizedDescription)")
//                            } else {
//                                let downloadURL = metadata?.downloadURL()
//                                    DataService.instance.sendMedia(senderID: (Auth.auth().currentUser?.uid)!, mediaURL: downloadURL!, mediaType: "video", ropeIP: copyRopeIP, videoURL: (exportSession?.outputURL!)!, image: nil)
//                                self.videoURL = nil
//                            }
//                        })
//
//                        print("File size after compression: \(Double(compressedData.length / 1048576)) mb")
//
//                    default:
//                        print("error compressing")
//                        break
//                    }
//                }
            //}
        
    }
    
    
    func animateRecordingLine() {
        self.shapeLayer?.removeFromSuperlayer()
        
        // create whatever path you want
        
        let path = UIBezierPath()
        path.move(to: CGPoint(x: 0, y: self.view.frame.height))
        path.addLine(to: CGPoint(x: self.view.bounds.width, y: self.view.frame.height))
        
        // create shape layer for that path
        
        let shapeLayer = CAShapeLayer()
        shapeLayer.fillColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0).cgColor
        shapeLayer.strokeColor = #colorLiteral(red: 1, green: 0, blue: 0, alpha: 1).cgColor
        shapeLayer.lineWidth = 30
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
        
        if let rope = self.currentRope {
            self.navigationItem.title = rope.title
            switch rope.role {
                
            case 0:
                if !self.captureSession!.inputs.contains(self.frontCameraInput) {
                    self.captureSession?.removeInput(self.backCameraInput)
                    self.captureSession?.addInput(self.frontCameraInput)
                }
                self.roleButton.setImage(#imageLiteral(resourceName: "videoselfie").withRenderingMode(.alwaysTemplate), for: .normal)
            case 1:
                if !self.captureSession!.inputs.contains(self.backCameraInput) {
                    self.captureSession?.removeInput(self.frontCameraInput)
                    self.captureSession?.addInput(self.backCameraInput)
                }
                self.roleButton.setImage(#imageLiteral(resourceName: "videolandscape").withRenderingMode(.alwaysTemplate), for: .normal)
            default:
                print("error setting up camera")
            }
        }
        
        self.view.addGestureRecognizer(longpress)
        
        previewView.isHidden = true
        previewView.removeExistingContent()
        cancelButton.isHidden = true
        sendButton.isHidden = true
        self.navigationController?.navigationBar.isHidden = false
        self.tabBarController?.tabBar.isHidden = false
        self.roleButton.isHidden = false
        self.knotCountLabel.isHidden = false
        self.knotView.isHidden = false
        self.shapeLayer?.removeFromSuperlayer()
    }
    
    func showMediaSetup() {
        removeGestures()
        self.roleButton.isHidden = true
        self.knotCountLabel.isHidden = true
        self.knotView.isHidden = true
        previewView.isHidden = false
        self.cancelButton.isHidden = false
        self.sendButton.isHidden = false
        self.tabBarController?.tabBar.isHidden = true
        self.navigationController?.navigationBar.isHidden = true
        self.view.bringSubview(toFront: cancelButton)
        self.view.bringSubview(toFront: sendButton)
    }
    
    func removeGestures() {
        if let gestures = self.view.gestureRecognizers{
            if gestures.contains(longpress) {
                self.view.removeGestureRecognizer(longpress)
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showRopeIPDetails" {
            let destination = segue.destination as! RopeIPDetailViewController
            destination.ropeIP = currentRope
        }
    }
    
    func found(code: String) {
        print(code)
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
            self.imageData = UIImageJPEGRepresentation(UIImage(cgImage: cgImageRef!, scale: 1.0, orientation: .leftMirrored), 0.9)
            previewView.displayImage(UIImage(cgImage: cgImageRef!, scale: 1.0, orientation: .leftMirrored))
            showMediaSetup()
        } else {
            //Otherwise just submit regular image.
            self.imageData = UIImageJPEGRepresentation(UIImage(cgImage: cgImageRef!, scale: 1.0, orientation: .right), 0.9)
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

