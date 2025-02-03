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
    var road: SKNode!
    
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
        
       
            for road in scrollLayer.children as! [SKSpriteNode] {
                
                /* Get ground node position, convert node position to scene space */
                let roadPosition = scrollLayer.convert(road.position, to: self)
                
                /* Check if ground sprite has left the scene */
                if roadPosition.y <= -road.size.height / 2 {
                    
                    print("new road will load ")
//                    /* Reposition ground sprite to the second starting position */
//                    let newPosition = CGPoint(x: (self.size.height / 2) + road.size.width, y: roadPosition.y); print("yes")
                    
                    let newPosition = CGPoint(x: roadPosition.x, y: (self.size.height) + road.size.height / 2); print("yes")
                    
                    /* Convert new node position back to scroll layer space */
                    road.position = self.convert(newPosition, to: scrollLayer); print("scroll")
                    
                }
                //            /* Loop through scroll layer nodes */
                //            for ground in scrollLayer.children as! [SKSpriteNode] {
                //
                //              /* Get ground node position, convert node position to scene space */
                //              let groundPosition = scrollLayer.convert(ground.position, to: self)
                //
                //              /* Check if ground sprite has left the scene */
                //              if groundPosition.x <= -ground.size.width / 2 {
                //
                //                  /* Reposition ground sprite to the second starting position */
                //                  let newPosition = CGPoint(x: (self.size.width / 2) + ground.size.width, y: groundPosition.y)
                //
                //                  /* Convert new node position back to scroll layer space */
                //                  ground.position = self.convert(newPosition, to: scrollLayer)
                //              }
            }
        
        }
    }
    

        
      

