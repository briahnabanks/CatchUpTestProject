//
//  GameScene.swift
//  CatchUpTestProject
//
//  Created by Briahna Banks on 1/27/25.
//

import SpriteKit
import Foundation
import GameplayKit
import UIKit // Haptics framework for tactile feedback
import AVFoundation

var player: AVAudioPlayer! // Global audio player for background music

// GameScene is a subclass of SKScene and conforms to SKPhysicsContactDelegate for collision handling.
class GameScene: SKScene, SKPhysicsContactDelegate {
    
    // MARK: - Properties
    
    var scrollLayer: SKNode!       // The node that contains scrolling background elements.
    var car: SKSpriteNode!         // The player's car sprite.
    var scrollSpeed: CGFloat = 100 // Speed at which the background scrolls.
    var itemSpeed: CGFloat = 100   // Speed at which items move.
    var itemConstant = 0.85        // Constant to adjust the item movement duration.
    let fixedDelta: CFTimeInterval = 1.0 / 60.0 /* 60 FPS frame duration */
    var columnPositions = [CGFloat]() // Array of X positions for columns.
    var initialTouchPosition: CGPoint? // To store the initial touch position (if needed).
    let iconNames: [String] = ["hat", "coney", "buffs", "faygo", "pothole", "barrier"] // Names of available icons.
    var icon: SKSpriteNode!        // A sprite node to hold the randomly spawned icon.
    var scoreLabel: SKLabelNode!   // Label to display the score.
    var score = 0                  // Game score.
    let goodItemHaptics = UIImpactFeedbackGenerator(style: .light) // Haptic feedback for good items.
    let badItemHaptics = UINotificationFeedbackGenerator()         // Haptic feedback for bad items.
    var itemDropRate = 0.80        // Interval for spawning new items.
    var gameover : SKSpriteNode!   // Sprite node for the game over image.

    // MARK: - Scene Lifecycle
    
    override func didMove(to view: SKView) {
        /* Setup your scene here */
        
        // Retrieve the scrollLayer node from the scene.
        scrollLayer = self.childNode(withName: "scrollLayer")
        
        // Set the physics world contact delegate for collision detection.
        self.physicsWorld.contactDelegate = self
        
        // Set up the score label with its properties.
        scoreLabel = SKLabelNode(fontNamed: "SF Pro Medium")
        scoreLabel.text = "0"  // Initial text.
        scoreLabel.fontSize = 28
        scoreLabel.fontColor = SKColor.white
        scoreLabel.position = CGPoint(x: 237, y: 495)
        scoreLabel.zPosition = 3
        
        // Add the score label to the scene.
        addChild(scoreLabel)
        
        // Define column positions based on the scene's width.
        columnPositions = [
            frame.midX - 71.5, frame.midX, frame.midX + 71.5
        ]
        
        // Initialize the car sprite from the scene and set its starting position.
        car = self.childNode(withName: "car") as? SKSpriteNode
        car.position = CGPoint(x: columnPositions[1], y: 70)
        
        // Spawn in a random icon from the scene using one of the names from iconNames.
        icon = self.childNode(withName: iconNames.randomElement() ?? "hat") as? SKSpriteNode
        
        // Begin generating sprites (items and obstacles) during gameplay.
        startGeneratingSprites()
        
        // Trigger a haptic feedback to pre-warm the haptics (avoids lag during gameplay).
        goodItemHaptics.impactOccurred()
        
        // Pre-render the Game Over image, set its properties, and add it to the scene.
        gameover = SKSpriteNode(texture: SKTexture(imageNamed: "gameover"))
        gameover.size = CGSize(width: 300, height: 300)
        gameover.position = CGPoint(x: columnPositions[1], y: 400)
        addChild(gameover)
        gameover.zPosition = 3
        gameover.isHidden = true
        
        // Start the countdown sequence and background music.
        startCountdown()
    }
    
    // MARK: - Physics Contact Delegate
    
    // This method is called when two physics bodies make contact.
    func didBegin(_ contact: SKPhysicsContact) {
        var firstBody: SKPhysicsBody
        var secondBody: SKPhysicsBody

        // Ensure firstBody has the lower category bit mask for consistency.
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            firstBody = contact.bodyA
            secondBody = contact.bodyB
        } else {
            firstBody = contact.bodyB
            secondBody = contact.bodyA
        }

        // Check if the car has collided with a good item.
        if firstBody.categoryBitMask == PhysicsCategory.sprite && secondBody.categoryBitMask == PhysicsCategory.car {
            if let sprite = firstBody.node {
                // Remove the collected sprite from the scene.
                sprite.removeFromParent()
                // Provide haptic feedback for a good item.
                goodItemHaptics.impactOccurred()
                // Award extra points if the sprite is a "buffs" item.
                if sprite.name == "buffs"{
                    updateScore(by: 10)
                } else {
                    updateScore(by: 1)
                }
            }
        }
        
        // Check if the car has collided with a bad item.
        else if firstBody.categoryBitMask == PhysicsCategory.obstacle && secondBody.categoryBitMask == PhysicsCategory.car{
            if let sprite = firstBody.node {
                // Remove the obstacle from the scene.
                sprite.removeFromParent()
                // Provide haptic feedback indicating an error or collision.
                badItemHaptics.notificationOccurred(.error)
                // If the obstacle is a barrier, end the game.
                if sprite.name == "barrier"{
                    // Pause the scene and display the Game Over image.
                    scene?.isPaused = true
                    gameover.isHidden = false
                } else{
                    updateScore(by: -10)
                }
            }
        }
    }

    // MARK: - Touch Handling
    
    // Called when a touch moves; updates the car's position accordingly.
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let location = touch.location(in:self)
            car.position.x = location.x
        }
    }
    
    // MARK: - Update Loop
    
    // Called before each frame is rendered.
    override func update(_ currentTime: TimeInterval) {
        /* Called before each frame is rendered */
        scrollWorld()
    }
    
    // MARK: - Scrolling Logic
    
    // Moves the scrollLayer to simulate a scrolling background.
    func scrollWorld(){
        scrollLayer.position.y -= scrollSpeed * CGFloat(fixedDelta)
        
        /* Loop through scroll layer nodes (assumed to be road segments) */
        for road in scrollLayer.children as! [SKSpriteNode] {
            
            /* Convert the road sprite's position to scene coordinates */
            let roadPosition = scrollLayer.convert(road.position, to: self)
            
            /* If the road has scrolled off-screen, reposition it to the top */
            if roadPosition.y <= -road.size.height / 2 {
                
                // Calculate the new position above the scene.
                let newPosition = CGPoint(x: roadPosition.x, y: (self.size.height) + road.size.height / 2);
                /* Convert back to scrollLayer coordinates and assign */
                road.position = self.convert(newPosition, to: scrollLayer);
            }
            // Increase the scroll speed gradually until a set limit is reached.
            if scrollSpeed < 400 {
                scrollSpeed += 0.15
            }
        }
    }
    
    // MARK: - Sprite Generation
    
    // Creates a random sprite (good item or obstacle) and configures its physics.
    func createRandomSprite() {
        // Randomly choose a texture based on iconNames.
        let randomIconIndex = Int.random(in: 0..<iconNames.count)
        let texture = SKTexture(imageNamed: iconNames[randomIconIndex])
        let sprite = SKSpriteNode(texture: texture)
        let barrier = SKSpriteNode(texture: SKTexture(imageNamed: "barrier"))
        let pothole = SKSpriteNode(texture: SKTexture(imageNamed: "pothole"))
        
        // Define spawn positions for items (using columns).
        let positions = [CGPoint(x: columnPositions[0], y: frame.maxY),
                         CGPoint(x: columnPositions[1], y: frame.maxY),
                         CGPoint(x: columnPositions[2], y: frame.maxY)]
        let randomPositionIndex = Int.random(in: 0..<positions.count)
        
        // Determine a separate column for the barrier so it doesn't overlap with the sprite.
        var barrierPositionIndex = Int.random(in: 0..<positions.count)
        if randomPositionIndex == barrierPositionIndex {
            if randomPositionIndex - 1 < 0 {
                barrierPositionIndex += 1
            }
            else if randomPositionIndex + 1 > 2 {
                barrierPositionIndex -= 1
            }
            else {
                barrierPositionIndex -= 1
            }
        }
        
        // Set positions for the good item and obstacles.
        sprite.position = positions[randomPositionIndex]
        pothole.position = positions[randomPositionIndex]
        barrier.position = positions[barrierPositionIndex]
        // Set layering order.
        sprite.zPosition = 2
        barrier.zPosition = 2
        pothole.zPosition = 2
        
        // Configure the car's physics body (if not already configured).
        car.physicsBody = SKPhysicsBody(rectangleOf: sprite.size)
        car.physicsBody?.affectedByGravity = false
        car.physicsBody?.isDynamic = true
        car.physicsBody?.categoryBitMask = PhysicsCategory.car
        car.physicsBody?.collisionBitMask = PhysicsCategory.none
        car.physicsBody?.contactTestBitMask = PhysicsCategory.sprite
    
        // Set up physics for good items (first four icons).
        if randomIconIndex == 0 || randomIconIndex == 1 || randomIconIndex == 2 || randomIconIndex == 3{
            sprite.physicsBody = SKPhysicsBody(texture: texture, size: sprite.size)
            sprite.name = iconNames[randomIconIndex]
            sprite.physicsBody?.affectedByGravity = false
            sprite.physicsBody?.isDynamic = false
            sprite.physicsBody?.categoryBitMask = PhysicsCategory.sprite
            sprite.physicsBody?.contactTestBitMask = PhysicsCategory.obstacle
        }
        // Set up physics for barrier (a bad item).
        barrier.physicsBody = SKPhysicsBody(texture: SKTexture(imageNamed: "barrier"), size: barrier.size)
        barrier.name = "barrier"
        barrier.physicsBody?.affectedByGravity = false
        barrier.physicsBody?.isDynamic = false
        barrier.physicsBody?.categoryBitMask = PhysicsCategory.obstacle
        barrier.physicsBody?.contactTestBitMask = PhysicsCategory.sprite
        // Set up physics for pothole (another bad item).
        pothole.physicsBody = SKPhysicsBody(texture: SKTexture(imageNamed: "pothole"), size: pothole.size)
        pothole.name = "pothole"
        pothole.physicsBody?.affectedByGravity = false
        pothole.physicsBody?.isDynamic = false
        pothole.physicsBody?.categoryBitMask = PhysicsCategory.obstacle
        pothole.physicsBody?.contactTestBitMask = PhysicsCategory.sprite
        
        // Only spawn the sprites once the scroll speed reaches a threshold.
        if scrollSpeed >= 400 {
            // If the sprite is a good item, add it along with its barrier.
            if sprite.physicsBody?.categoryBitMask == PhysicsCategory.sprite {
                addChild(barrier)
                addChild(sprite)
            }
            else{
                // Otherwise, add the bad item (pothole).
                addChild(pothole)
            }
            
            // Define the move action to move the sprite downward off the screen.
            let moveDown = SKAction.moveBy(x: 0, y: -frame.size.height, duration: itemSpeed * CGFloat(fixedDelta) * itemConstant)
            let remove = SKAction.removeFromParent()
            sprite.run(SKAction.sequence([moveDown, remove]))
            barrier.run(SKAction.sequence([moveDown, remove]))
            pothole.run(SKAction.sequence([moveDown, remove]))
        }
    }
    
    
    // MARK: - Sprite Generation Loop
    
    // Starts an endless loop that generates sprites at intervals.
    func startGeneratingSprites() {
        let create = SKAction.run { [weak self] in
            self?.createRandomSprite()
        }
        let dropRate = SKAction.wait(forDuration: itemDropRate)
        run(SKAction.repeatForever(SKAction.sequence([create, dropRate])))
    }
    
    // MARK: - Physics Categories
    
    // PhysicsCategory defines bit masks for collision detection.
    struct PhysicsCategory {
        static let none      : UInt32 = 0
        static let all       : UInt32 = UInt32.max
        static let sprite    : UInt32 = 0b1       // 1
        static let obstacle  : UInt32 = 0b10      // 2
        static let car       : UInt32 = 0b11      // 3
    }
    
    // MARK: - Score Management
    
    // Updates the score by the specified amount and updates the score label.
    func updateScore(by: Int){
        score += by
        if score < 0 {
            score = 0
        }
        scoreLabel.text = "\(score)"
    }
    
    // MARK: - Countdown and Audio Setup
    
    // Starts a countdown sequence with instructions and plays background music.
    func startCountdown() {
        let countdownLabel = SKLabelNode(fontNamed: "SF Pro Display-Medium")
        let instructions1 = SKSpriteNode(texture: SKTexture(imageNamed: "instructions1"))
        let instructions2 = SKSpriteNode(texture: SKTexture(imageNamed: "instructions2"))
        let go = SKSpriteNode(texture: SKTexture(imageNamed: "go"))
        
        // Position instructions in the center of the scene.
        instructions1.position = CGPoint(x: size.width / 2, y: size.height / 2)
        instructions2.position = CGPoint(x: size.width / 2, y: size.height / 2)
        go.position = CGPoint(x: size.width / 2, y: size.height / 2)
        
        // Set zPositions to ensure instructions appear above other elements.
        instructions1.zPosition = 4
        instructions2.zPosition = 4
        
        // Set sizes for the instruction sprites.
        instructions1.size = CGSize(width: 280, height: 568)
        instructions2.size = CGSize(width: 280, height: 568)
        go.size = CGSize(width: 200, height: 200)
        
        // Add instructions and countdown label to the scene.
        addChild(instructions1)
        addChild(instructions2)
        addChild(go)
        addChild(countdownLabel)
        
        // Initially hide the instruction sprites.
        instructions1.isHidden = true
        instructions2.isHidden = true
        go.isHidden = true
        
        // Create a sequence to show instructions, wait, and then fade out.
        let countdownSequence = SKAction.sequence([
            SKAction.run { instructions1.isHidden = false },
            SKAction.wait(forDuration: 5.0),
            SKAction.run { instructions1.isHidden = true
                instructions2.isHidden = false},
            SKAction.wait(forDuration: 5.0),
            SKAction.run { instructions2.isHidden = true
                go.isHidden = false},
            SKAction.wait(forDuration: 2.0),
            SKAction.run {
                go.isHidden = true
            },
            SKAction.fadeOut(withDuration: 0.5),
            SKAction.removeFromParent()
        ])
        
        // Run the countdown sequence on the countdown label.
        countdownLabel.run(countdownSequence)
        
        // Load and play background music.
        let url = Bundle.main.url(forResource: "babytron type beat", withExtension: "mp3")!
        player = try! AVAudioPlayer(contentsOf: url)
        player.numberOfLoops = -1 // Infinitely loop
        player.play()
    }
}
