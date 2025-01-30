//
//  GameScene.swift
//  CatchUpTestProject
//
//  Created by Briahna Banks on 1/27/25.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    
    var car : SKSpriteNode!
    var columnPositions = [CGFloat]()
    var initialTouchPosition: CGPoint?
    var isSwipeActionCommitted = false

    
    override func didMove(to view: SKView) {
        
        columnPositions = [
            -175, 0, 175
        ]
        
        //Initialize column positions
        car = self.childNode(withName: "car") as? SKSpriteNode
        
        car.position = CGPoint(x: columnPositions[0], y: -500)

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

            if abs(movement) > 200 { // Threshold to detect a swipe
                if movement > 0 {
                    print("Swiped right")
                    if car.position.x < columnPositions[2] {
                        car.position.x += 175
                    }
                } else {
                    print("Swiped left")
                    if car.position.x > columnPositions[0] {
                        car.position.x -= 175
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
        // Called before each frame is rendered
    }
}
