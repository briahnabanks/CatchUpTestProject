//
//  GameScene.swift
//  CatchUpTestProject
//
//  Created by Briahna Banks on 1/27/25.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    
    var scrollLayer: SKNode!
    var car: SKSpriteNode!
    var roadDraft: SKNode!
    
    let  scrollSpeed: CGFloat = 100
    
    let fixedDelta: CFTimeInterval = 1.0 / 60.0 /* 60 FPS */
    
    override func didMove(to view: SKView) {
        /* Setup your scene here */
        scrollLayer = self.childNode(withName: "scrollLayer")
        car = self.childNode(withName: "car") as? SKSpriteNode
       
        
        //*gesture recognizer*
        
        
        
        //        let swipeRight : UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(GameScene.swipedRight))
        //
        //
        //        swipeRight.direction = .right
        //        view.addGestureRecognizer(swipeRight)
        //
        
    }
    
    @objc func swipedRight(sender: UISwipeGestureRecognizer) { print("Object has been swiped")}
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) { print("swipe detected")
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
        
      

