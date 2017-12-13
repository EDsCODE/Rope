//
//  PreviewViewController.swift
//  Rope
//
//  Created by Eric Duong on 11/1/17.
//  Copyright © 2017 Rope. All rights reserved.
//

import UIKit
import AVFoundation
import AVKit

class PreviewViewController: UIViewController {
    
    var playerLayer: AVPlayerLayer?
    fileprivate var repeatObserver: NSObjectProtocol?
    var videoURL: URL?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let url = videoURL {
            let player = AVPlayer(url: url)
            playerLayer = AVPlayerLayer(player: player)
            playerLayer!.frame = CGRect(x: 0, y: 0, width: self.view.bounds.width, height: self.view.bounds.height)
            playerLayer!.videoGravity = .resize
            self.view.layer.addSublayer(playerLayer!)
            playOnRepeat(player)
        }
        
        // Do any additional setup after loading the view.
    }
    
    private func playOnRepeat(_ player: AVPlayer) {
        player.play()
        
        repeatObserver = NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: player.currentItem, queue: nil, using: { (_) in
            DispatchQueue.main.async {
                player.seek(to: kCMTimeZero)
                player.play()
            }
        })
    }
    func removeExistingContent() {
        playerLayer?.player?.pause()
        playerLayer?.removeFromSuperlayer()
        NotificationCenter.default.removeObserver(repeatObserver as Any)
    }
    
    @IBAction func cancel(_ sender: Any) {
        self.dismiss(animated: false, completion: nil)
        removeExistingContent()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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

