//
//  GameScene.swift
//  CatchUpTestProject
//
//  Created by Briahna Banks on 1/27/25.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var scrollLayer: SKNode!
    var car: SKSpriteNode!
    var roadDraft: SKNode!
    let  scrollSpeed: CGFloat = 100
    let fixedDelta: CFTimeInterval = 1.0 / 60.0 /* 60 FPS */
    var columnPositions = [CGFloat]()
    var initialTouchPosition: CGPoint?
    var isSwipeActionCommitted = false

    
    override func didMove(to view: SKView) {
        /* Setup your scene here */
        scrollLayer = self.childNode(withName: "scrollLayer")
        
        columnPositions = [
            90, 160, 250
        ]
        
        //Initialize column positions
        car = self.childNode(withName: "car") as? SKSpriteNode
        car.position = CGPoint(x: columnPositions[1], y: 60)
        
        //conform to physics delegate
        self.physicsWorld.contactDelegate = self

    }
    
    func touchDown(atPoint pos : CGPoint) {

    }
    
    func touchMoved(toPoint pos : CGPoint) {

    }
    
    func touchUp(atPoint pos : CGPoint) {

    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            initialTouchPosition = touch.location(in: self)
            isSwipeActionCommitted = false
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let initialTouchPosition = initialTouchPosition, !isSwipeActionCommitted else { return }
        if let touch = touches.first {
            let currentTouchPosition = touch.location(in: self)
            let movement = currentTouchPosition.x - initialTouchPosition.x

            if abs(movement) > 100
            { // Threshold to detect a swipe
                if movement > 0 {
                    print("Swiped right")
                    if car.position.x < columnPositions[2]{
                        car.position.x += 90
                    }
                } else{
                    print("Swiped left")
                    if car.position.x > columnPositions[0]{
                        car.position.x -= 90
                    }
                }
                // Reset initial position to prevent continuous detection
                self.initialTouchPosition = currentTouchPosition
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        initialTouchPosition = nil // Reset when touch ends
        isSwipeActionCommitted = false
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
    }
    
    
    override func update(_ currentTime: TimeInterval) {
        /* Called before each frame is rendered */
        scrollWorld()
        
    }
    
    func scrollWorld(){
        scrollLayer.position.y -= scrollSpeed * CGFloat(fixedDelta)
        
        /* Loop through scroll layer nodes */
        for roadDraft in scrollLayer.children as! [SKSpriteNode] { 

          /* Get ground node position, convert node position to scene space */
            let roadDraftPosition = scrollLayer.convert(roadDraft.position, to: self)

          /* Check if ground sprite has left the scene */
            if roadDraftPosition.y <= -roadDraft.size.width / 1 {

              /* Reposition ground sprite to the second starting position */
                let newPosition = CGPoint(x: (self.size.width / 2) + roadDraft.size.width, y: roadDraftPosition.y);

              /* Convert new node position back to scroll layer space */
                roadDraft.position = self.convert(newPosition, to: scrollLayer); print("scroll")
          }
        }
    }
    
}
        
      

