//
//  RopeDisplayViewController.swift
//  Rope
//
//  Created by Eric Duong on 11/22/17.
//  Copyright © 2017 Rope. All rights reserved.
//

import UIKit
import AVFoundation

class RopeDisplayViewController: UIViewController {
    
//    var playerQueue: AVQueuePlayer!
    
    var playerLayer: AVPlayerLayer?
    fileprivate var nextObserver: NSObjectProtocol?
    var rope: Rope!
    var currentIndex = 0
    var isPlaying = false
    @IBOutlet weak var cancelPlayback: UIButton!
    fileprivate var repeatObserver: NSObjectProtocol?
    
    var imageDisplay : UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.backgroundColor = .white
        imageView.isUserInteractionEnabled = true
        return imageView
    }()
    
    var informationView : GradientView = {
        let view = GradientView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        return view
    }()
    
    var creatorLabel : UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .white
        label.text = "hello"
        label.font = UIFont(name: "Nunito-SemiBold", size: 12.0)
        return label
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .black
        self.view.addSubview(imageDisplay)
        self.view.addSubview(informationView)
        self.view.addSubview(creatorLabel)
        
        cancelPlayback.layer.shadowColor = UIColor.black.cgColor
        cancelPlayback.layer.shadowOffset = CGSize(width: 0.0, height: 1.0)
        cancelPlayback.layer.shadowRadius = 2
        cancelPlayback.layer.shadowOpacity = 0.5
        
        let constraints = [
            imageDisplay.topAnchor.constraint(equalTo: self.view.topAnchor),
            imageDisplay.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            imageDisplay.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            imageDisplay.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            informationView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            informationView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            informationView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            informationView.heightAnchor.constraint(equalTo: self.view.heightAnchor, multiplier: 0.1),
            creatorLabel.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 15.0),
            creatorLabel.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            creatorLabel.topAnchor.constraint(equalTo: informationView.topAnchor),
            creatorLabel.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
        ]
        NSLayoutConstraint.activate(constraints)
        
        isPlaying = true
        let nextMediaGesture = UITapGestureRecognizer(target: self, action: #selector(clickedNext(_:)))
        imageDisplay.addGestureRecognizer(nextMediaGesture)
        
        displayRope(currentIndex)
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "loadState" {
            displayRope(currentIndex)
            if let media = object as? Media {
                print("removing observer")
                media.removeObserver(self, forKeyPath: "loadState")
            }
        }
    }
    
    @objc private func clickedNext(_ sender: UITapGestureRecognizer) {
        displayRope(currentIndex)
    }
    
    func displayRope(_ index: Int) {
        print("displaying \(currentIndex)")
        if rope.media.count > 0 && isPlaying {
            if index < rope.media.count && index >= 0{
                
                //if media hasn't loaded yet
                if rope.media[index].loadState == .loading || rope.media[index].loadState == .unloaded {
                    self.rope.media[index].addObserver(self, forKeyPath: "loadState", options: .new, context: nil)
                    imageDisplay.image = #imageLiteral(resourceName: "cat")
                    imageDisplay.clipsToBounds = true
                } else {
                    //display image for 3 seconds
                    if "image" == rope.media[index].mediaType {
                        removeExistingContent()
                        let mediaImage = UIImage(data: rope.media[index].image!)
                        imageDisplay.image = mediaImage
                        currentIndex += 1
                        
                        //display video
                    } else if "video" == rope.media[index].mediaType {
                        removeExistingContent()
                        let url = rope.media[index].videoURL!
                        let previewImage = loadImage(url)
                        imageDisplay.image = previewImage
                        let player = AVPlayer(url: url)
                        playerLayer = AVPlayerLayer(player: player)
                        playerLayer!.videoGravity = .resizeAspectFill
                        self.view.layoutIfNeeded()
                        playerLayer!.frame = imageDisplay.bounds
                        imageDisplay.layer.addSublayer(playerLayer!)
                        play(player)
                        currentIndex += 1
                    }
                    creatorLabel.text = rope.media[index].senderName
                }
            } else if index == rope.media.count {
                currentIndex = 0
                displayRope(currentIndex)
            }
            self.view.bringSubview(toFront: cancelPlayback)

        } else {
            print("not enough knots")
        }
    }
    
    @IBAction func cancelPlayback(_ sender: Any) {
        playerLayer?.player?.pause()
        removeExistingContent()
        isPlaying = false
        dismiss(animated: false, completion: nil)
    }
    
    func removeExistingContent() {
        imageDisplay.image = nil
        playerLayer?.player?.pause()
        playerLayer?.removeFromSuperlayer()
        NotificationCenter.default.removeObserver(self)
        NotificationCenter.default.removeObserver(repeatObserver as Any)
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    ///Plays the video and set up a notification that will play the video again when completed.
    private func play(_ player: AVPlayer) {
        player.play()
        repeatObserver = NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: player.currentItem, queue: nil, using: { (_) in
            DispatchQueue.main.async {
                player.seek(to: kCMTimeZero)
                player.play()
            }
        })
    }

    @objc private func videoEnded(_ sender: Notification) {
        displayRope(currentIndex)
    }
    
    func loadImage(_ url: URL) -> UIImage {
        let asset = AVURLAsset(url: url, options: nil)
        let imgGenerator = AVAssetImageGenerator(asset: asset)
        imgGenerator.appliesPreferredTrackTransform = true
        do {
            let cgImage = try imgGenerator.copyCGImage(at: CMTimeMake(0, 1), actualTime: nil)
            let uiImage = UIImage(cgImage: cgImage)
            return uiImage
        } catch {
            return UIImage()
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

class GradientView: UIView {
    
    private let gradient : CAGradientLayer = CAGradientLayer()
    
    override func layoutSublayers(of layer: CALayer) {
        super.layoutSublayers(of: layer)
        self.gradient.frame = self.bounds
    }
    
    override public func draw(_ rect: CGRect) {
        self.gradient.frame = self.bounds
        self.gradient.colors = [UIColor.clear.cgColor, UIColor(displayP3Red: 0.0, green: 0.0, blue: 0.0, alpha: 0.7).cgColor]
        self.gradient.startPoint = CGPoint(x: 1, y: 0)
        self.gradient.endPoint = CGPoint(x: 1, y: 1)
        if self.gradient.superlayer == nil {
            self.layer.insertSublayer(self.gradient, at: 0)
        }
    }
}
