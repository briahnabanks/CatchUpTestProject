//
//  GameScene.swift
//  CatchUpTestProject
//
//  Created by Briahna Banks on 1/27/25.
//

import SpriteKit
import Foundation
import GameplayKit
import UIKit //Haptics

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var scrollLayer: SKNode!
    var car: SKSpriteNode!
    var scrollSpeed: CGFloat = 100
    var itemSpeed: CGFloat = 100
    var itemConstant = 0.85
    let fixedDelta: CFTimeInterval = 1.0 / 60.0 /* 60 FPS */
    var columnPositions = [CGFloat]()
    var initialTouchPosition: CGPoint?
    let iconNames: [String] = ["hat", "coney", "buffs", "faygo", "pothole", "barrier"]
    var icon: SKSpriteNode!
    var scoreLabel: SKLabelNode!
    var score = 0
    let goodItemHaptics = UIImpactFeedbackGenerator(style: .light)
    let badItemHaptics = UINotificationFeedbackGenerator()
    var itemDropRate = 0.80

    
    override func didMove(to view: SKView) {
        /* Setup your scene here */
        scrollLayer = self.childNode(withName: "scrollLayer")
        
        //conform scene to contact delegate to handle collisions
        self.physicsWorld.contactDelegate = self
        
        //set up score text
        scoreLabel = SKLabelNode(fontNamed: "SF Pro Medium")
        scoreLabel.text = "0"  // Initial text
        scoreLabel.fontSize = 28
        scoreLabel.fontColor = SKColor.white
        scoreLabel.position = CGPoint(x: 237, y: 495)
        scoreLabel.zPosition = 3
        
        // Add the score to the scene
        addChild(scoreLabel)
        
        //columns
        columnPositions = [
            frame.midX - 71.5, frame.midX, frame.midX + 71.5
        ]
        
        //Initialize column positions
        car = self.childNode(withName: "car") as? SKSpriteNode
        car.position = CGPoint(x: columnPositions[1], y: 70)
        
        //Spawn in random icon
        icon = self.childNode(withName: iconNames.randomElement() ?? "hat") as? SKSpriteNode
        
        //Start making sprites
        startGeneratingSprites()
        
        //Run haptics here to avoid lag
        goodItemHaptics.impactOccurred()
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        var firstBody: SKPhysicsBody
        var secondBody: SKPhysicsBody

        // Assign the bodies so that firstBody is always the sprite
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            firstBody = contact.bodyA
            secondBody = contact.bodyB
        } else {
            firstBody = contact.bodyB
            secondBody = contact.bodyA
        }

        // check if car and good item collided
        if firstBody.categoryBitMask == PhysicsCategory.sprite && secondBody.categoryBitMask == PhysicsCategory.car {
            if let sprite = firstBody.node {
                // Remove the sprite
                sprite.removeFromParent()
                //haptics
                goodItemHaptics.impactOccurred()
                //Check for buffs
                if sprite.name == "buffs"{
                    updateScore(by: 10)
                } else {
                    updateScore(by: 1)
                }
            }
        }
        // check if car and bad item have collided
        else if firstBody.categoryBitMask == PhysicsCategory.obstacle && secondBody.categoryBitMask == PhysicsCategory.car{
            if let sprite = firstBody.node {
                //Remove the sprite
                sprite.removeFromParent()
                //haptics
                badItemHaptics.notificationOccurred(.error)
                //Check if it is a barrier
                if sprite.name == "barrier"{
                    //end game by stopping movement
                    scene?.isPaused = true
                    print("gameover")
                } else{
                    updateScore(by: -10)
                }
            }
        }
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let location = touch.location(in:self)
            car.position.x = location.x
        }
    }
    override func update(_ currentTime: TimeInterval) {
        /* Called before each frame is rendered */
        scrollWorld()
    }
    
    func scrollWorld(){
        scrollLayer.position.y -= scrollSpeed * CGFloat(fixedDelta)
        
        /* Loop through scroll layer nodes */
        for road in scrollLayer.children as! [SKSpriteNode] {
            
            /* Get ground node position, convert node position to scene space */
            let roadPosition = scrollLayer.convert(road.position, to: self)
            
            /* Check if ground sprite has left the scene */
            if roadPosition.y <= -road.size.height / 2 {
                
                //Reposition ground sprite to the second starting position
                let newPosition = CGPoint(x: roadPosition.x, y: (self.size.height) + road.size.height / 2);
                /* Convert new node position back to scroll layer space */
                road.position = self.convert(newPosition, to: scrollLayer);
            }
            if scrollSpeed < 400 {
                scrollSpeed += 0.25
            }
        }
    }
    func createRandomSprite() {
        //randomly choose a texture
        let randomIconIndex = Int.random(in: 0..<iconNames.count)
        let texture = SKTexture(imageNamed: iconNames[randomIconIndex])
        let sprite = SKSpriteNode(texture: texture)
        let barrier = SKSpriteNode(texture: SKTexture(imageNamed: "barrier"))
        let pothole = SKSpriteNode(texture: SKTexture(imageNamed: "pothole"))
        
        //initialize position
        let positions = [CGPoint(x: columnPositions[0], y: frame.maxY),
                         CGPoint(x: columnPositions[1], y: frame.maxY),
                         CGPoint(x: columnPositions[2], y: frame.maxY)]
        let randomPositionIndex = Int.random(in: 0..<positions.count)
        
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
        
        //set sprite position
        sprite.position = positions[randomPositionIndex]
        pothole.position = positions[randomPositionIndex]
        barrier.position = positions[barrierPositionIndex]
        //set Z position
        sprite.zPosition = 2
        barrier.zPosition = 2
        pothole.zPosition = 2
        
        //set up physics for all sprites
        //Car
        car.physicsBody = SKPhysicsBody(rectangleOf: sprite.size)
        car.physicsBody?.affectedByGravity = false
        car.physicsBody?.isDynamic = true
        car.physicsBody?.categoryBitMask = PhysicsCategory.car
        car.physicsBody?.collisionBitMask = PhysicsCategory.none
        car.physicsBody?.contactTestBitMask = PhysicsCategory.sprite
    
        //Good Items
        if randomIconIndex == 0 || randomIconIndex == 1 || randomIconIndex == 2 || randomIconIndex == 3{
            sprite.physicsBody = SKPhysicsBody(texture: texture, size: sprite.size)
            sprite.name = iconNames[randomIconIndex]
            sprite.physicsBody?.affectedByGravity = false
            sprite.physicsBody?.isDynamic = false
            sprite.physicsBody?.categoryBitMask = PhysicsCategory.sprite
            sprite.physicsBody?.contactTestBitMask = PhysicsCategory.obstacle
        }
        //Barrier
        barrier.physicsBody = SKPhysicsBody(texture: SKTexture(imageNamed: "barrier"), size: barrier.size)
        barrier.name = "barrier"
        barrier.physicsBody?.affectedByGravity = false
        barrier.physicsBody?.isDynamic = false
        barrier.physicsBody?.categoryBitMask = PhysicsCategory.obstacle
        barrier.physicsBody?.contactTestBitMask = PhysicsCategory.sprite
        //pothole
        pothole.physicsBody = SKPhysicsBody(texture: SKTexture(imageNamed: "pothole"), size: pothole.size)
        pothole.name = "pothole"
        pothole.physicsBody?.affectedByGravity = false
        pothole.physicsBody?.isDynamic = false
        pothole.physicsBody?.categoryBitMask = PhysicsCategory.obstacle
        pothole.physicsBody?.contactTestBitMask = PhysicsCategory.sprite
        
        //spawn sprite when max speed occurs
        if scrollSpeed >= 400 {
            //if good item
            if sprite.physicsBody?.categoryBitMask == PhysicsCategory.sprite {
                //Add sprite and barrier to scene
                addChild(barrier)
                addChild(sprite)
            }
            else{
                //Add bad item (pothole or single barrier)
                addChild(pothole)
            }
            

            //move sprite at same speed as scroll
            let moveDown = SKAction.moveBy(x: 0, y: -frame.size.height, duration: itemSpeed * CGFloat(fixedDelta) * itemConstant)
            let remove = SKAction.removeFromParent()
            sprite.run(SKAction.sequence([moveDown, remove]))
            barrier.run(SKAction.sequence([moveDown, remove]))
            pothole.run(SKAction.sequence([moveDown, remove]))
        }
    }
    
    //start spawning the sprites
    func startGeneratingSprites() {
        
        let create = SKAction.run { [weak self] in
            self?.createRandomSprite()
        }
        let dropRate = SKAction.wait(forDuration: itemDropRate)
        run(SKAction.repeatForever(SKAction.sequence([create, dropRate])))
    }
    
    //physics category
    struct PhysicsCategory {
        static let none      : UInt32 = 0
        static let all       : UInt32 = UInt32.max
        static let sprite    : UInt32 = 0b1       // 1
        static let obstacle  : UInt32 = 0b10      // 2
        static let car       : UInt32 = 0b11      // 3
        
    }
    
    //Update Score
    func updateScore(by: Int){
        score += by
        if score < 0 {
            score = 0
        }
        scoreLabel.text = "\(score)"
    }
}


        
      

