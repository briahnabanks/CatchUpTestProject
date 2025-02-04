//
//  GameScene.swift
//  CatchUpTestProject
//
//  Created by Briahna Banks on 1/27/25.
//

import SpriteKit
import Foundation
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var scrollLayer: SKNode!
    var car: SKSpriteNode!
    var scrollSpeed: CGFloat = 100
    let fixedDelta: CFTimeInterval = 1.0 / 60.0 /* 60 FPS */
    var columnPositions = [CGFloat]()
    var initialTouchPosition: CGPoint?
    let iconNames: [String] = ["hat", "coney", "buffs", "pothole", "barrier"]
    var icon: SKSpriteNode!
    
    override func didMove(to view: SKView) {
        /* Setup your scene here */
        scrollLayer = self.childNode(withName: "scrollLayer")
        
        //conform scene to contact delegate to handle collisions
        self.physicsWorld.contactDelegate = self
        
        columnPositions = [
            frame.midX - 71.5, frame.midX, frame.midX + 71.5
        ]
        
        //Initialize column positions
        car = self.childNode(withName: "car") as? SKSpriteNode
        car.position = CGPoint(x: columnPositions[1], y: 60)
        
        //conform to physics delegate
        self.physicsWorld.contactDelegate = self
        
        //Spawn in random icon
        icon = self.childNode(withName: iconNames.randomElement() ?? "hat") as? SKSpriteNode
        
        //Start making sprites
        startGeneratingSprites()
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
            print("good item")
            if let sprite = firstBody.node {
                // Remove the sprite
                sprite.removeFromParent()
            }
        }
        // check if car and bad item have collided
        else if firstBody.categoryBitMask == PhysicsCategory.obstacle && secondBody.categoryBitMask == PhysicsCategory.car{
            print("bad item")
            if let sprite = firstBody.node {
                //Remove the sprite
                sprite.removeFromParent()
            }
        }
    }
    
    func touchDown(atPoint pos : CGPoint) {
        
    }
    
    func touchMoved(toPoint pos : CGPoint) {
        
    }
    
    //@objc func swipedRight(sender: UISwipeGestureRecognizer) {}
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let location = touch.location(in:self)
            car.position.x = location.x
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        /* Called when a touch begins */
        
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
        }
    }
    
    func createRandomSprite() {
        //randomly choose a texture
        let randomIconIndex = Int.random(in: 0..<iconNames.count)
        let texture = SKTexture(imageNamed: iconNames[randomIconIndex])
        let sprite = SKSpriteNode(texture: texture)
        
        //initialize position
        let positions = [CGPoint(x: columnPositions[0], y: frame.maxY),
                         CGPoint(x: columnPositions[1], y: frame.maxY),
                         CGPoint(x: columnPositions[2], y: frame.maxY)]
        let randomPositionIndex = Int.random(in: 0..<positions.count)
        sprite.position = positions[randomPositionIndex]
        //set Z position
        sprite.zPosition = 2
        
        //set up physics
        //Car
        car.physicsBody = SKPhysicsBody(rectangleOf: sprite.size)
        car.physicsBody?.affectedByGravity = false
        car.physicsBody?.isDynamic = true
        car.physicsBody?.categoryBitMask = PhysicsCategory.car
        car.physicsBody?.collisionBitMask = PhysicsCategory.none
        car.physicsBody?.contactTestBitMask = PhysicsCategory.sprite
        
        //Good Items
        if randomIconIndex == 0 || randomIconIndex == 1 || randomIconIndex == 2{
            sprite.physicsBody = SKPhysicsBody(texture: texture, size: sprite.size)
            sprite.physicsBody?.affectedByGravity = false
            sprite.physicsBody?.isDynamic = false
            sprite.physicsBody?.categoryBitMask = PhysicsCategory.sprite
            sprite.physicsBody?.contactTestBitMask = PhysicsCategory.obstacle
        }
        //Bad Items
        else {
            sprite.physicsBody = SKPhysicsBody(texture: texture, size: sprite.size)
            sprite.physicsBody?.affectedByGravity = false
            sprite.physicsBody?.isDynamic = false
            sprite.physicsBody?.categoryBitMask = PhysicsCategory.obstacle
            sprite.physicsBody?.contactTestBitMask = PhysicsCategory.sprite
        }
        
        //spawn sprite
        addChild(sprite)
        
        //move sprite at same speed as scroll
        let moveDown = SKAction.moveBy(x: 0, y: -frame.size.height, duration: scrollSpeed * (CGFloat(fixedDelta) * 3.25))
        let remove = SKAction.removeFromParent()
        sprite.run(SKAction.sequence([moveDown, remove]))
    }
    
    //start spawning the sprites
    func startGeneratingSprites() {
        let create = SKAction.run { [weak self] in
            self?.createRandomSprite()
        }
        let wait = SKAction.wait(forDuration: 3.0)  // Adjust time based on your needs
        run(SKAction.repeatForever(SKAction.sequence([create, wait])))
    }
    
    //physics category
    struct PhysicsCategory {
        static let none      : UInt32 = 0
        static let all       : UInt32 = UInt32.max
        static let sprite    : UInt32 = 0b1       // 1
        static let obstacle  : UInt32 = 0b10      // 2
        static let car       : UInt32 = 0b11      // 3
        
    }
}


        
      

