//
//  StartingScene.swift
//  CatchUpTestProject
//
//  Created by Joseph Brinker on 2/17/25.
//

import SpriteKit

class StartingScene: SKScene {
 
    override func didMove(to view: SKView) {
        
        //create button
        let button = SKLabelNode(text: "Start Game")
        button.name = "startButton"
        button.fontColor = .white
        button.position = CGPoint(x: 100, y: 300)
        
        addChild(button)
        print("added button")
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let touchedNode = atPoint(location)
        
        if touchedNode.name == "startButton" {
            let gameScene = GameScene(size: self.size)
            let transition = SKTransition.fade(withDuration: 0.5)
            self.view?.presentScene(gameScene, transition: transition)
        }
    }
}
