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
import Photos

class CameraViewController: SwiftyCamViewController, SwiftyCamViewControllerDelegate {
    
    weak var buttonTimer: Timer?
    weak var shapeLayer: CAShapeLayer?
    var capturedURL: URL?
    
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
    
    var tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        cameraDelegate = self
        
        self.videoQuality = .resolution1920x1080
        self.maximumVideoDuration = 3.0
        
        self.view.addSubview(topPanel)
        self.view.addSubview(bottomPanel)
        
        //setup tableview
        tableView.delegate = self
        self.view.addSubview(tableView)
        tableView.backgroundColor = UIColor(displayP3Red: 0.0, green: 0.0, blue: 0.0, alpha: 0.35)
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.register(UINib(nibName: "RopeCell", bundle: nil), forCellReuseIdentifier: "ropeCell")
        
        let constraints = [
            topPanel.topAnchor.constraint(equalTo: self.view.topAnchor),
            topPanel.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            topPanel.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            topPanel.heightAnchor.constraint(equalToConstant: (self.view.bounds.height - self.view.bounds.width) / 2),
            bottomPanel.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            bottomPanel.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            bottomPanel.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            bottomPanel.heightAnchor.constraint(equalToConstant: (self.view.bounds.height - self.view.bounds.width) / 2),
            tableView.topAnchor.constraint(equalTo: self.view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
        ]
        NSLayoutConstraint.activate(constraints)
        setupLongPressforVideo()
        
        // Do any additional setup after loading the view.
    }
    
    func setupLongPressforVideo() {
        let longPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(longPressed(sender:)))
        self.view.addGestureRecognizer(longPressGestureRecognizer)
    }
    
    @objc func longPressed(sender: UILongPressGestureRecognizer){
        if sender.state == .ended {
            print("UIGestureRecognizerStateEnded")
            stopVideoRecording()
            pause(shapeLayer!)
            self.buttonTimer?.invalidate()
            //Do Whatever You want on End of Gesture
        }
        else if sender.state == .began {
            print("UIGestureRecognizerStateBegan.")
            tableView.isHidden = true
            startVideoRecording()
            buttonTimer = Timer.scheduledTimer(timeInterval: 3.0, target: self, selector: #selector(cancel(_:)), userInfo: nil, repeats: false)
            animateRecordingLine()
        }
    }
    
    @objc func cancel(_ timerObject: Timer) {
        print("cancel")
        stopVideoRecording()
        pause(shapeLayer!)
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
    
    func pause(_ theLayer: CALayer) {
        let mediaTime: CFTimeInterval = CACurrentMediaTime()
        let pausedTime: CFTimeInterval = theLayer.convertTime(mediaTime, from: nil)
        theLayer.speed = 0.0
        theLayer.timeOffset = pausedTime
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
    
    func getOutputPath( _ name: String ) -> String
    {
        let documentPath = NSSearchPathForDirectoriesInDomains( .documentDirectory, .userDomainMask, true )[ 0 ] as NSString
        let outputPath = "\(documentPath)/\(name).mov"
        return outputPath
    }
    
    func swiftyCam(_ swiftyCam: SwiftyCamViewController, didBeginRecordingVideo camera: SwiftyCamViewController.CameraSelection) {
        // Called when startVideoRecording() is called
        // Called if a SwiftyCamButton begins a long press gesture
    }
    
    func swiftyCam(_ swiftyCam: SwiftyCamViewController, didFinishRecordingVideo camera: SwiftyCamViewController.CameraSelection) {
        // Called when stopVideoRecording() is called
        // Called if a SwiftyCamButton ends a long press gesture
    }
    
    func swiftyCam(_ swiftyCam: SwiftyCamViewController, didFinishProcessVideoAt url: URL) {
        print("crop")
        squareCropVideo(inputURL: url as NSURL, completion: { (outputURL) -> () in
            // Save video to photo library
            //            PHPhotoLibrary.shared().performChanges({
            //                PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL:outputURL! as URL)
            //            }) { saved, error in
            //                if saved {
            //                    print ("save successful")
            //                }
            //                else {
            //                    print ("save failed")
            //                }
            //            }
            self.capturedURL = outputURL! as URL
            self.performSegue(withIdentifier: "showPreview", sender: self)
            
        })
        
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        self.shapeLayer?.removeFromSuperlayer()
        if segue.identifier == "showPreview" {
            let destination = segue.destination as? PreviewViewController
            if let url = capturedURL {
                destination?.videoURL = url
                self.capturedURL = nil
                tableView.isHidden = false
            }
        }
    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}

extension CameraViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.contentView.backgroundColor = UIColor.clear
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100.0
    }
    
}

extension CameraViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ropeCell", for: indexPath) as! RopeCell
        cell.backgroundColor = .clear
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
}
