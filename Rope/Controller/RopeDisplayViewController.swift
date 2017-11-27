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
    
    var imageDisplay : UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.backgroundColor = .white
        return imageView
    }()
    
    var videoView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .green
        return view
    }()


    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .black
        self.view.addSubview(imageDisplay)
    
        let constraints = [
            imageDisplay.topAnchor.constraint(equalTo: self.view.topAnchor),
            imageDisplay.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            imageDisplay.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            imageDisplay.leadingAnchor.constraint(equalTo: self.view.leadingAnchor)
        ]
        NSLayoutConstraint.activate(constraints)

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
    
    func displayRope(_ index: Int) {
        if rope.media.count > 0 {
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
                        Timer.scheduledTimer(timeInterval: 3.0, target: self, selector: #selector(playNext(_:)), userInfo: nil, repeats: false)
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
                }
            } else if index == rope.media.count {
                currentIndex = 0
                displayRope(currentIndex)
            }
        } else {
            print("not enough knots")
        }
    }
    
    @objc func playNext(_ timerObject: Timer) {
        displayRope(currentIndex)
    }
    
    func removeExistingContent() {
        imageDisplay.image = nil
        playerLayer?.player?.pause()
        playerLayer?.removeFromSuperlayer()
        NotificationCenter.default.removeObserver(self)
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    ///Plays the video and set up a notification that will play the video again when completed.
    private func play(_ player: AVPlayer) {
        player.play()
        NotificationCenter.default.addObserver(self, selector: #selector(videoEnded(_:)), name: .AVPlayerItemDidPlayToEndTime, object: player.currentItem)
    }

    @objc private func videoEnded(_ sender: Notification) {
        displayRope(currentIndex)
    }
    
    func loadImage(_ url: URL) -> UIImage {
        let asset = AVURLAsset(url: url, options: nil)
        let imgGenerator = AVAssetImageGenerator(asset: asset)
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
