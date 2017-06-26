//
//  MonsterNode.swift
//  I Scream
//
//  Created by JR on 6/23/17.
//  Copyright © 2017 JR. All rights reserved.
//

import UIKit
import SpriteKit

class MonsterNode: SKNode {
    var totalHealth : Int64 = 0
    var health : Int64 = 0
    let healthL = SKSpriteNode(imageNamed: "HPLeft")
    let healthM = SKSpriteNode(imageNamed: "HPMiddle")
    let healthR = SKSpriteNode(imageNamed: "HPRight")
    init(_ hp : Int64){
        super.init()
        totalHealth = hp
        health = hp
        makeMonster()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func makeMonster(){
        let healthBackgroundL = SKSpriteNode(imageNamed: "HPBackgroundLeft")
        let healthBackgroundM = SKSpriteNode(imageNamed: "HPBackgroundMiddle")
        let healthBackgroundR = SKSpriteNode(imageNamed: "HPBackgroundRight")
        healthBackgroundL.position = CGPoint(x: -(healthBackgroundM.size.width+healthBackgroundR.size.width)/2, y: (153-20)/2)
        healthBackgroundL.zPosition = 2
        healthBackgroundM.position = CGPoint(x: healthBackgroundL.position.x+healthBackgroundL.size.width/2+healthBackgroundM.size.width/2, y: healthBackgroundL.position.y)
        healthBackgroundM.zPosition = 2
        healthBackgroundR.position = CGPoint(x: healthBackgroundM.position.x+healthBackgroundM.size.width/2+healthBackgroundR.size.width/2, y: healthBackgroundL.position.y)
        healthBackgroundR.zPosition = 2
        self.addChild(healthBackgroundL)
        self.addChild(healthBackgroundM)
        self.addChild(healthBackgroundR)
        
        healthL.position = CGPoint(x: -(healthM.size.width+healthR.size.width)/2, y: (153-20)/2)
        healthL.zPosition = 3
        healthM.position = CGPoint(x: healthL.position.x+healthL.size.width/2+healthM.size.width/2, y: healthL.position.y)
        healthM.zPosition = 3
        healthR.position = CGPoint(x: healthM.position.x+healthM.size.width/2+healthR.size.width/2, y: healthL.position.y)
        healthR.zPosition = 3
        self.addChild(healthL)
        self.addChild(healthM)
        self.addChild(healthR)
        
        let body = SKSpriteNode(imageNamed: "Fireball")
        body.zPosition = 3
        body.position = CGPoint(x: 0, y: -30/2)
        let bodyPhysics = SKPhysicsBody(texture: SKTexture(imageNamed: "Fireball"), size: body.size)
        bodyPhysics.categoryBitMask = 4
        bodyPhysics.collisionBitMask = 4
        body.physicsBody = bodyPhysics
        
        self.addChild(body)
        self.zPosition = 2
    }
    
    func decreaseHealth(_ healthDecrease : Int64){
        health -= healthDecrease
        print(health)
        if(health <= 0 || 100*CGFloat(health)/CGFloat(totalHealth) < 5){
            healthL.removeFromParent()
            healthM.removeFromParent()
            healthR.removeFromParent()
        }
        else{
            let healthWidth = 100*CGFloat(health)/CGFloat(totalHealth)
            let healthMWidth = healthWidth - 6*2
            if(healthMWidth <= 0){
                healthL.run(SKAction.resize(toWidth: healthWidth/2, duration: 0))
                healthM.run(SKAction.resize(toWidth: 0, duration: 0))
                healthR.run(SKAction.resize(toWidth: healthWidth/2, duration: 0))
                let healthLX = -50+healthWidth/4
                healthL.run(SKAction.moveTo(x: healthLX, duration: 0))
                healthR.run(SKAction.moveTo(x: healthLX+healthWidth/2, duration: 0))

            }
            else{
                let healthMX = healthL.position.x+healthL.size.width/2+healthMWidth/2
                healthM.run(SKAction.resize(toWidth: healthMWidth, duration: 0))
                healthM.run(SKAction.moveTo(x: healthMX, duration: 0))
                healthR.run(SKAction.moveTo(x: healthMX+healthMWidth/2+healthR.size.width/2, duration: 0))
            }
        }
    }
}
