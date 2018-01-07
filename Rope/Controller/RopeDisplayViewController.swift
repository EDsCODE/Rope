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
    var currentIndex = -1
    var isPlaying = false
    @IBOutlet weak var cancelPlayback: UIButton!
    fileprivate var repeatObserver: NSObjectProtocol?
    
    var imageDisplay : UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.backgroundColor = UIColor(displayP3Red: 42.0/255.0, green: 42.0/255.0, blue: 42.0/255.0, alpha: 1)
        imageView.isUserInteractionEnabled = true
        return imageView
    }()
    
    var informationView : GradientView = {
        let view = GradientView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        return view
    }()
    
    var titleView: GradientView = {
        let view = GradientView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        view.isHidden = true
        return view
    }()
    
    var creatorLabel : UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .white
        label.text = "hello"
        label.isHidden = true
        label.font = UIFont(name: "Nunito-SemiBold", size: 16.0)
        return label
    }()
    
    var titleLabel : UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .white
        label.text = "TITLE"
        label.font = UIFont(name: "Nunito-SemiBold", size: 28.0)
        return label
    }()
    
    var timeLabel : UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .white
        label.text = "TIME"
        label.font = UIFont(name: "Nunito-SemiBold", size: 16.0)
        return label
    }()
    
    var separator : UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.lightGray
        view.layer.cornerRadius = 2
        return view
    }()
    
    var thumbnailSpinner: SpinnerView!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .black
        self.view.addSubview(imageDisplay)
        self.view.addSubview(informationView)
        informationView.addSubview(creatorLabel)
        self.view.addSubview(titleView)
        titleView.addSubview(titleLabel)
        titleView.addSubview(timeLabel)
        titleView.addSubview(separator)
        
        thumbnailSpinner = SpinnerView(frame: CGRect(x: self.view.frame.midX - 25.0, y: self.view.frame.midY - 25.0, width: 50.0, height: 50.0))
        
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
            titleView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            titleView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            titleView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            titleView.heightAnchor.constraint(equalTo: self.view.heightAnchor, multiplier: 0.5),
            creatorLabel.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 20.0),
            creatorLabel.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            creatorLabel.topAnchor.constraint(equalTo: informationView.topAnchor),
            creatorLabel.bottomAnchor.constraint(equalTo: self.informationView.bottomAnchor),
            timeLabel.leadingAnchor.constraint(equalTo: self.titleView.leadingAnchor, constant: 20.0),
            timeLabel.trailingAnchor.constraint(equalTo: self.titleView.trailingAnchor, constant: -20.0),
            timeLabel.heightAnchor.constraint(equalToConstant: 20.0),
            timeLabel.bottomAnchor.constraint(equalTo: self.titleView.bottomAnchor, constant: -15.0),
            separator.bottomAnchor.constraint(equalTo: self.timeLabel.topAnchor, constant: -10.0),
            separator.leadingAnchor.constraint(equalTo: self.titleView.leadingAnchor, constant: 20.0),
            separator.trailingAnchor.constraint(equalTo: self.titleView.trailingAnchor, constant: -20.0),
            separator.heightAnchor.constraint(equalToConstant: 4.0),
            titleLabel.leadingAnchor.constraint(equalTo: self.titleView.leadingAnchor, constant: 20.0),
            titleLabel.trailingAnchor.constraint(equalTo: self.titleView.trailingAnchor, constant: -20.0),
            titleLabel.bottomAnchor.constraint(equalTo: self.separator.topAnchor, constant: -10.0),
            titleLabel.heightAnchor.constraint(equalToConstant: 40.0)
        ]
        NSLayoutConstraint.activate(constraints)
        
        isPlaying = true
        let nextMediaGestureImage = UITapGestureRecognizer(target: self, action: #selector(clickedNext(_:)))
        let nextMediaGestureGradient = UITapGestureRecognizer(target: self, action: #selector(clickedNext(_:)))
        imageDisplay.addGestureRecognizer(nextMediaGestureImage)
        titleView.addGestureRecognizer(nextMediaGestureGradient)
        
        displayRope(currentIndex)
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "loadState" {
            thumbnailSpinner.layer.removeAllAnimations()
            displayRope(currentIndex)
            if let media = object as? Media {
                media.removeObserver(self, forKeyPath: "loadState")
            }
        }
    }
    
    @objc private func clickedNext(_ sender: UITapGestureRecognizer) {
        displayRope(currentIndex)
    }
    
    func displayRope(_ index: Int) {
        if index < rope.media.count - 1 && index >= -1 && self.rope.media[index + 1].loadState == .unloaded {
            self.rope.media[index + 1].load(completion: { (loaded) in
                if loaded {
                    self.rope.media[index + 1].loadState = .loaded
                }
            })
        }
        
        if rope.media.count > 0 && isPlaying {
            if index < rope.media.count && index >= 0{
                titleView.isHidden = true
                //if media hasn't loaded yet
                if rope.media[index].loadState == .unloaded {
                    removeExistingContent()
                    self.rope.media[index].addObserver(self, forKeyPath: "loadState", options: .new, context: nil)
                    //display title screen with thumbnail
//                    imageDisplay.image = #imageLiteral(resourceName: "cat")
//                    imageDisplay.clipsToBounds = true
                    thumbnailSpinner.isHidden = false
                    imageDisplay.addSubview(thumbnailSpinner)
                    thumbnailSpinner.animate()
                } else if rope.media[index].loadState == .loading {
                    removeExistingContent()
                    self.rope.media[index].addObserver(self, forKeyPath: "loadState", options: .new, context: nil)
//                    imageDisplay.image = #imageLiteral(resourceName: "cat")
//                    imageDisplay.clipsToBounds = true
                    thumbnailSpinner.isHidden = false
                    imageDisplay.addSubview(thumbnailSpinner)
                    thumbnailSpinner.animate()
                } else if rope.media[index].loadState == .loaded {
                    creatorLabel.isHidden = false
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
                currentIndex = -1
                displayRope(currentIndex)
            } else if index == -1 {
                removeExistingContent()
                creatorLabel.isHidden = true
                titleView.isHidden = false
                titleLabel.text = rope.title
                let startDate = Date(timeIntervalSince1970: Double(rope.media[0].sentDate / 1000))
                let endDate = Date(timeIntervalSince1970: Double(rope.media[rope.media.count - 1].sentDate / 1000))
                let dayTimePeriodFormatter = DateFormatter()
                dayTimePeriodFormatter.dateFormat = "MMMM dd, yyyy"
                dayTimePeriodFormatter.timeZone = TimeZone.current
                let startdateString = dayTimePeriodFormatter.string(from: startDate)
                let enddateString = dayTimePeriodFormatter.string(from: endDate)
                timeLabel.text = (startdateString == enddateString) ? "\(startdateString)": "\(startdateString) - \(enddateString)"
                imageDisplay.image = UIImage(data: self.rope.thumbnailData)
                imageDisplay.clipsToBounds = true
                currentIndex += 1
            }
            self.view.bringSubview(toFront: cancelPlayback)

        } else {
            print("not enough knots")
        }
    }
    
    @IBAction func cancelPlayback(_ sender: Any) {
        dismiss(animated: false, completion: nil)
        DispatchQueue.main.async {
            self.playerLayer?.player?.pause()
            self.removeExistingContent()
            self.isPlaying = false
        }
    }
    
    func removeExistingContent() {
        thumbnailSpinner.isHidden = true
        thumbnailSpinner.removeFromSuperview()
        thumbnailSpinner.layer.removeAllAnimations()
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
        self.gradient.colors = [UIColor.clear.cgColor, UIColor(displayP3Red: 0.0, green: 0.0, blue: 0.0, alpha: 0.5).cgColor]
        self.gradient.startPoint = CGPoint(x: 1, y: 0)
        self.gradient.endPoint = CGPoint(x: 1, y: 1)
        if self.gradient.superlayer == nil {
            self.layer.insertSublayer(self.gradient, at: 0)
        }
    }
}
