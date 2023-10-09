//
//  GameViewController.swift
//  Pong-Pong
//
//  Created by Stvya Sharma on 21/04/21.
//

import UIKit
import SpriteKit
import GameplayKit

class GameViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let view = self.view as! SKView? {

            // Load the SKScene from 'GameScene.sks'
            if let scene = SKScene(fileNamed: "GameScene"){
                // Set the scale mode to scale to fit the window
                scene.scaleMode = .aspectFill

                scene.backgroundColor =
                    UIColor(red:130.0/255.0, green:210.0/255.0, blue:220.0/255.0, alpha:1.0)
                // Present the scene
                
                _ = SKView(frame: CGRect(origin: CGPoint(x: 0, y: 1000), size: CGSize(width: 400, height: 750)))
                let scene = GameScene(size: CGSize(width: 800, height: 1500))
                view.presentScene(scene)
                scene.backgroundColor =
                    UIColor(red:130.0/255.0, green:210.0/255.0, blue:220.0/255.0, alpha:1.0)
                
            }
            view.frame = CGRect(origin: CGPoint.zero, size: CGSize(width: 400, height: 600))
            view.ignoresSiblingOrder = true
            
            view.showsFPS = true
            view.showsNodeCount = true
        }
    }

    override var shouldAutorotate: Bool {
        return true
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
}



