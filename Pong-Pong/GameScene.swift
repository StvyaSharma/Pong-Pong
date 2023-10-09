//
//  GameScene.swift
//  Pong-Pong
//
//  Created by Stvya Sharma on 21/04/21.
//

import SpriteKit
import GameplayKit
import AVFoundation

// Declare some global constants
let width = 800 as CGFloat
let height = 1200 as CGFloat
let racketHeight = 150 as CGFloat
let ballRadius = 20 as CGFloat
// Three types of collision objects possible
enum CollisionTypes: UInt32 {
    case Ball = 1
    case Wall = 2
    case Racket = 4
}
// Racket direction
enum RacketDirection: Int{
    case None = 0
    case Up = 1
    case Down = 2
}
//: ### SpriteKit scene
// SpriteKit scene
public class GameScene: SKScene, SKPhysicsContactDelegate {
    let racketSpeed = 500.0
    var direction = RacketDirection.None
    var score = 0
    var HighScore = 0
    var gameRunning = false
    // Screen elements
    var racket: SKShapeNode?
    var ball: SKShapeNode?
    let backButton = SKLabelNode()
    let scoreLabel = SKLabelNode()
    let HighScoreLabel = SKLabelNode()
    // Initialize objects during first start
    public override func sceneDidLoad() {
        super.sceneDidLoad()
        var resr = SKShapeNode()
        scoreLabel.fontSize = 40
        scoreLabel.position = CGPoint(x: 600, y: height - 100)
        HighScoreLabel.fontSize = 40
        HighScoreLabel.fontName = "AvenirNext-Bold"
        scoreLabel.fontName = "AvenirNext-Bold"
        HighScoreLabel.position = CGPoint(x: 200, y: height - 100)
        backButton.position = CGPoint(x: 740, y: height - 60)
        backButton.fontSize = 40
        backButton.fontName = "AvenirNext-Bold"
        self.addChild(HighScoreLabel)
        self.addChild(scoreLabel)
        self.addChild(backButton)
        createWalls()
        createBall(position: CGPoint(x: width / 2, y: height / 2))
        createRacket()
        startNewGame()
        self.physicsWorld.contactDelegate = self
    }
    // Create the ball sprite
    func createBall(position: CGPoint) {
        let physicsBody = SKPhysicsBody(circleOfRadius: ballRadius)
        ball = SKShapeNode(circleOfRadius: ballRadius)
        physicsBody.categoryBitMask = CollisionTypes.Ball.rawValue
        physicsBody.collisionBitMask = CollisionTypes.Wall.rawValue | CollisionTypes.Ball.rawValue | CollisionTypes.Racket.rawValue
        physicsBody.affectedByGravity = false
        physicsBody.restitution = 1
        physicsBody.linearDamping = 0
        physicsBody.velocity = CGVector(dx: -500, dy: 500)
        ball!.physicsBody = physicsBody
        ball!.position = position
        ball!.fillColor = SKColor.white
    }
    // Create the walls
    func createWalls() {
        createWall(rect: CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: ballRadius, height: height)))
        createWall(rect: CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: width, height: ballRadius)))
        createWall(rect: CGRect(origin: CGPoint(x: 0, y: height - ballRadius), size: CGSize(width: width, height: ballRadius)))
    }
    func createWall(rect: CGRect) {
        let node = SKShapeNode(rect: rect)
        node.fillColor = SKColor.white
        node.physicsBody = getWallPhysicsbody(rect: rect)
        self.addChild(node)
    }
    // Create the physics objetcs to handle wall collisions
    func getWallPhysicsbody(rect: CGRect) -> SKPhysicsBody {
        let physicsBody = SKPhysicsBody(rectangleOf: rect.size, center: CGPoint(x: rect.midX, y: rect.midY))
        physicsBody.affectedByGravity = false
        physicsBody.isDynamic = false
        physicsBody.collisionBitMask = CollisionTypes.Ball.rawValue
        physicsBody.categoryBitMask = CollisionTypes.Wall.rawValue
        return physicsBody
    }
    // Create the racket sprite
    func createRacket() {
        racket =  SKShapeNode(rect: CGRect(origin: CGPoint.zero, size: CGSize(width: ballRadius, height: racketHeight)))
        self.addChild(racket!)
        racket!.fillColor = SKColor.white
        let physicsBody = SKPhysicsBody(rectangleOf: racket!.frame.size, center: CGPoint(x: racket!.frame.midX, y: racket!.frame.midY))
        physicsBody.affectedByGravity = false
        physicsBody.isDynamic = false
        physicsBody.collisionBitMask = CollisionTypes.Ball.rawValue
        physicsBody.categoryBitMask = CollisionTypes.Racket.rawValue
        physicsBody.contactTestBitMask = CollisionTypes.Ball.rawValue
        racket!.physicsBody = physicsBody
    }
    // Start a new game
    func startNewGame() {
        score = 0
        scoreLabel.text = "Current Score : \(score)"
        HighScoreLabel.text = "Hight Score : \(HighScore)"
        racket!.position = CGPoint(x: width - ballRadius * 2, y: height / 2)
        backButton.text = "Back"
        var counter = 3
        let startLabel = SKLabelNode(text: "Game Over")
        startLabel.fontName = "AvenirNext-Bold"
        startLabel.position = CGPoint(x: width / 2, y: height / 2)
        startLabel.fontSize = 160
        self.addChild(startLabel)
        // Animated countdown
        let fadeIn = SKAction.fadeIn(withDuration: 0.5)
        let fadeOut = SKAction.fadeOut(withDuration: 0.5)
        startLabel.text = "3"
        self.playbeep()
        startLabel.run(SKAction.sequence([fadeIn, fadeOut]), completion: {
            startLabel.text = "2"
            self.playbeep()
            startLabel.run(SKAction.sequence([fadeIn, fadeOut]), completion: {
                startLabel.text = "1"
                self.playbeep()
                startLabel.run(SKAction.sequence([fadeIn, fadeOut]), completion: {
                    startLabel.text = "0"
                    self.playbeep()
                    startLabel.run(SKAction.sequence([fadeIn, fadeOut]), completion: {
                        startLabel.text = "Start"
                        self.playboop()
                        startLabel.run(SKAction.sequence([fadeIn, fadeOut]),completion: {
                            startLabel.removeFromParent()
                            self.playBacktrack()
                            self.gameRunning = true
                            self.ball!.position = CGPoint(x: 30, y: height / 2)
                            self.addChild(self.ball!)
                        })
                    })
                })
            })
        })
    }
//: ### Touch Movements
    // Handle touch events to move the racket
    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let location = touch.location(in: self)
            if location.y > height / 2 {
                direction = RacketDirection.Up
            } else if location.y < height / 2{
                direction = RacketDirection.Down
            }
        }
    }
    // Stop racket movement
    public override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        direction = RacketDirection.None
    }
    // Game loop:
    // - Game over check: Ball still on screen
    // - Trigger racket movement
    var dt = TimeInterval(0)
    public override func update(_ currentTime: TimeInterval) {
        if gameRunning {
            super.update(currentTime)
            checkGameOver()
            if dt > 0 {
                moveRacket(dt: currentTime - dt)
            }
            dt = currentTime
        }
    }
    // Move the racket up or down
    func moveRacket(dt: TimeInterval) {
        if direction == RacketDirection.Up && racket!.position.y < height - racketHeight {
            racket!.position.y = racket!.position.y + CGFloat(racketSpeed * dt)
        } else if direction == RacketDirection.Down && racket!.position.y > 0 {
            racket!.position.y = racket!.position.y - CGFloat(racketSpeed * dt)
        }
    }
    
//: ### Game Over Function
    // Check if the ball is still on screen
    // Game Over animation
    func checkGameOver() {
        if ball!.position.x > CGFloat(width) {
            gameRunning = false
            ball!.removeFromParent()
            let gameOverLabel = SKLabelNode(text: "Game Over")
            
            gameOverLabel.fontName = "AvenirNext-Bold"
            gameOverLabel.position = CGPoint(x: width / 2, y: height / 2)
            gameOverLabel.fontSize = 80
            self.addChild(gameOverLabel)
            self.playboop()
            gameOverLabel.run(SKAction.scale(to: 1, duration: 2.5), completion: {
                
                gameOverLabel.removeFromParent()
                self.startNewGame()
            })
            
            
        }
    }
    
    // Detect collisions between ball and racket to increase the score
    public func didBegin(_ contact: SKPhysicsContact) {
        if contact.bodyA.categoryBitMask == CollisionTypes.Racket.rawValue || contact.bodyB.categoryBitMask == CollisionTypes.Racket.rawValue {
            score += 1
            
            if score > HighScore {
                HighScore = score
            }
            HighScoreLabel.text = String("High Score : \(HighScore)")
            
            scoreLabel.text = String("Current Score : \(score)")
        }
    }
//: ### Color Jump Music
    var audioPlayer: AVAudioPlayer?
    
    func playBacktrack() {
        if let audioURL = Bundle.main.url(forResource: "Pong Backtrack", withExtension: "mp3") {
            do {
                try self.audioPlayer = AVAudioPlayer(contentsOf: audioURL) /// make the audio player
                self.audioPlayer?.numberOfLoops = 10000
                self.audioPlayer?.setVolume(0.3, fadeDuration: 0)
                self.audioPlayer?.play() /// start playing
                
            } catch {
                print("Couldn't play audio. Error: \(error)")
            }
            
        } else {
            print("No audio file found")
        }
    }
    func playbeep() {
        if let audioURL = Bundle.main.url(forResource: "Pong Beep", withExtension: "m4a") {
            do {
                try self.audioPlayer = AVAudioPlayer(contentsOf: audioURL) /// make the audio player
                self.audioPlayer?.numberOfLoops = 0/// Number of times to loop the audio
                self.audioPlayer?.play() /// start playing
                
            } catch {
                print("Couldn't play audio. Error: \(error)")
            }
            
        } else {
            print("No audio file found")
        }
    }
    func playboop() {
        if let audioURL = Bundle.main.url(forResource: "Pong Boop", withExtension: "m4a") {
            do {
                try self.audioPlayer = AVAudioPlayer(contentsOf: audioURL) /// make the audio player
                self.audioPlayer?.numberOfLoops = 0 /// Number of times to loop the audio
                self.audioPlayer?.play() /// start playing
                
            } catch {
                print("Couldn't play audio. Error: \(error)")
            }
        } else {
            print("No audio file found")
        }
    }
}
