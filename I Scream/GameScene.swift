//
//  GameScene.swift
//  I Scream
//
//  Created by JR on 6/20/17.
//  Copyright © 2017 JR. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var screenHeight = CGFloat(0)
    var screenWidth = CGFloat(0)
    var lastTime: TimeInterval?
    var cannon: SKSpriteNode?
    var cannonAngle = CGFloat.pi/2
    var cannonDestX = CGFloat(0)
    var movingCannon = false
    var rotatingCannon = false
    var touchNum = 0
    var oneTouch = false
    
    override func didMove(to view: SKView) {
        setUpDimensions()
        setUpBackground()
        setUpGame()
    }
    
    func setUpDimensions(){
        screenHeight = self.size.height
        screenWidth = self.size.width
    }
    
    func setUpBackground(){
        let background = SKSpriteNode(imageNamed: "Background")
        background.size = self.size
        background.zPosition = 0
        self.addChild(background)
    }
    
    func setUpGame(){
        print("SET UP GAME")
        let leftWall = SKNode()
        leftWall.physicsBody = SKPhysicsBody(edgeFrom: CGPoint(x: -self.frame.width/2, y: self.frame.height/2), to: CGPoint(x: -self.frame.width/2, y: -self.frame.height/2))
        leftWall.physicsBody?.categoryBitMask = 1
        //leftWall.physicsBody?.collisionBitMask = 2
        leftWall.physicsBody?.friction = 0
        self.addChild(leftWall)
        
        let rightWall = SKNode()
        rightWall.physicsBody = SKPhysicsBody(edgeFrom: CGPoint(x: self.frame.width/2, y: self.frame.height/2), to: CGPoint(x: self.frame.width/2, y: -self.frame.height/2))
        rightWall.physicsBody?.categoryBitMask = 1
        rightWall.physicsBody?.friction = 0
        //rightWall.physicsBody?.collisionBitMask = 2
        self.addChild(rightWall)
        
        self.physicsWorld.contactDelegate = self
        self.physicsWorld.gravity = CGVector(dx: 0, dy: 0)
    
        cannon = SKSpriteNode(imageNamed: "IceCreamCannon")
        cannon?.size = CGSize(width: 64, height: 210)
        //cannon?.position = CGPoint(x: 0, y: 0)
        cannon?.zPosition = 2
        cannon?.position = CGPoint(x: 0, y: -screenHeight/2)
        self.addChild(cannon!)
        
        makeEnemy()
    }
    
    func fireIceCream(){
        //let iceCream = SKSpriteNode(imageNamed: "IceCreamProjectile")
        //iceCream.size = CGSize(width: 48, height: 105)
        let cannonCurrAngle = cannon!.zRotation+CGFloat.pi/2
        let iceCream = IceCreamNode("IceCreamProjectile", 1)
        iceCream.size = CGSize(width: 64, height: 66)
        iceCream.position = CGPoint(x: (cannon?.position.x)!+90*cos(cannonCurrAngle), y: (cannon?.position.y)!+90*sin(cannonCurrAngle))
        iceCream.zPosition = 1
        iceCream.zRotation = cannonCurrAngle-CGFloat.pi/2
        iceCream.run(SKAction.fadeOut(withDuration: 4.5))
        iceCream.run(SKAction.sequence([SKAction.wait(forDuration: 4), SKAction.run({
            iceCream.removeFromParent()
        })]))
        self.addChild(iceCream)
    
        let iceCreamPhysicsBody = SKPhysicsBody(circleOfRadius: iceCream.size.width/2)
        iceCreamPhysicsBody.collisionBitMask = 1
        iceCreamPhysicsBody.contactTestBitMask = 1 | 4
        iceCreamPhysicsBody.categoryBitMask = 2
        iceCreamPhysicsBody.friction = 0
        iceCreamPhysicsBody.restitution = 1
        iceCreamPhysicsBody.allowsRotation = false
        iceCreamPhysicsBody.linearDamping = 0
        iceCream.physicsBody = iceCreamPhysicsBody
        iceCream.physicsBody!.applyImpulse(CGVector(dx: 130*cos(cannonCurrAngle), dy: 130*sin(cannonCurrAngle)))
    }
    
    
    func didBegin(_ contact: SKPhysicsContact){
        var firstBody: SKPhysicsBody?
        var secondBody: SKPhysicsBody?
        if (contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask)
        {
            firstBody = contact.bodyA;
            secondBody = contact.bodyB;
        }
        else
        {
            firstBody = contact.bodyB;
            secondBody = contact.bodyA;
        }
        if(firstBody?.categoryBitMask == 1){
            let iceCream = secondBody?.node as! IceCreamNode
            let iceCreamAngle = iceCream.zRotation+CGFloat.pi/2
            //if(iceCreamAngle > CGFloat(0)){
                iceCream.run(SKAction.rotate(toAngle: CGFloat.pi/2-iceCreamAngle, duration: 0))
                iceCream.setDamagePoints(iceCream.getDamagePoints()*2)
            //}
            //else{
            //    iceCream.run(SKAction.rotate(toAngle: iceCreamAngle+CGFloat(M_PI/2), duration: 0))
            //}
            //iceCream.removeFromParent()
        }
        else{
            let iceCream = firstBody?.node as! IceCreamNode
            //iceCream.removeAllActions()
            let enemy = secondBody?.node?.parent as! MonsterNode
            enemy.removeAction(forKey: "damaged")
            if(!iceCream.isHidden){
                iceCream.removeFromParent()
                iceCream.isHidden = true
                enemy.decreaseHealth(iceCream.getDamagePoints())
            }
            enemy.run(SKAction.sequence([SKAction.fadeAlpha(to: 0.6, duration: 0.0), SKAction.wait(forDuration: 0.1), SKAction.fadeAlpha(to: 1, duration: 0.0)]), withKey: "damaged")
        }
    }
    
    func makeEnemy(){
        let enemy = MonsterNode(100)
        enemy.position = CGPoint(x: 0, y: 0)
        self.addChild(enemy)
    }
    
    func touchDown(atPoint pos : CGPoint) {
        if(touchNum == 0){
            oneTouch = true
        }
        else{
            oneTouch = false
        }
        touchNum += 1
        if(oneTouch){
        if(pos.x > (cannon?.position.x)!-105 && pos.x < (cannon?.position.x)!+105 && pos.y < -screenHeight/2+155){
            movingCannon = true
        }
        else{
            let dx = pos.x-(cannon?.position.x)!
            let dy = pos.y+self.frame.height/2
            cannonAngle = atan(dy/dx)
            if(dx > 0){
                cannonAngle = atan(dy/dx)
            }
            else{
                cannonAngle = CGFloat.pi+atan(dy/dx)
            }
            //cannon?.removeAction(forKey: "rotate")
            //cannon?.run(SKAction.sequence([SKAction.run({self.rotatingCannon = true}), SKAction.rotate(toAngle: cannonAngle-CGFloat(M_PI/2), duration: 0.3), SKAction.run({self.rotatingCannon = false})]), withKey: "rotate")
        }
        }
    }
    
    func touchMoved(toPoint pos : CGPoint) {
        if(oneTouch){
            if(movingCannon){
            //if(movingCannon && abs(pos.x-(cannon?.position.x)!) < 60 && pos.y < -screenHeight/2+CGFloat(115)){
                cannonDestX = pos.x
            }
            else{
            //if(pos.y > -self.frame.height/2+self.frame.height/8){
                let dx = pos.x-(cannon?.position.x)!
                let dy = pos.y+self.frame.height/2
                cannonAngle = atan(dy/dx)
                if(dx < 0){
                    cannonAngle = CGFloat.pi+atan(dy/dx)

                }
                //if(abs(newCannonAngle-cannonAngle) < CGFloat(M_PI/8)){
                    //cannon?.removeAction(forKey: "rotate")
                    //cannon?.run(SKAction.rotate(toAngle: newCannonAngle-CGFloat(M_PI/2), duration: 0), withKey: "rotate")
                    //cannonAngle = newCannonAngle
                //}
            //}
            }
        }
    }
    
    func touchUp(atPoint pos : CGPoint) {
        touchNum -= 1
        if(touchNum == 0){
        //if(cannon?.contains(pos))!{
            movingCannon = false
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        for t in touches { self.touchDown(atPoint: t.location(in: self)) }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchMoved(toPoint: t.location(in: self)) }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
    }
    
    
    override func update(_ currentTime: TimeInterval) {
        let cannonCurrAngle = (cannon?.zRotation)!+CGFloat.pi/2
        var angleDiff = CGFloat(0)
        if(abs(cannonCurrAngle-cannonAngle) > CGFloat.pi/180){
            angleDiff += CGFloat.pi/180
        }
        if(abs(cannonCurrAngle-cannonAngle) > CGFloat.pi/16){
            angleDiff += CGFloat.pi/180*2
        
        }
        if(abs(cannonCurrAngle-cannonAngle) > CGFloat.pi/8){
            angleDiff += CGFloat.pi/180*3
        }
        if(abs(cannonCurrAngle-cannonAngle) > CGFloat.pi/4){
            angleDiff += CGFloat.pi/180*4
        }
        if(cannonCurrAngle > cannonAngle){
            cannon?.run(SKAction.rotate(byAngle: -CGFloat(angleDiff), duration: 0), withKey: "rotate")
        }
        else{
            cannon?.run(SKAction.rotate(byAngle: CGFloat(angleDiff), duration: 0), withKey: "rotate")
        }
        
        let cannonCurrX = cannon?.position.x
        var xDiff = CGFloat(0)
        if(abs(cannonCurrX!-cannonDestX) > 2){
            xDiff += 2
        }
        if(abs(cannonCurrX!-cannonDestX) > 5){
            xDiff += 3
        }
        if(abs(cannonCurrX!-cannonDestX) > 10){
            xDiff += 4
        }
        if(abs(cannonCurrX!-cannonDestX) > 20){
            xDiff += 4
        }
        if(abs(cannonCurrX!-cannonDestX) > 30){
            xDiff += 5
        }
        if(cannonCurrX! > cannonDestX){
            cannon?.run(SKAction.moveBy(x: -xDiff, y: 0, duration: 0))
        }
        else{
            cannon?.run(SKAction.moveBy(x: xDiff, y: 0, duration: 0))
        }
        
        if(lastTime == nil){
            lastTime = currentTime
        }
        else{
            if(currentTime-lastTime! > 0.4){
                fireIceCream()
                lastTime = currentTime
            }
        }

    }
}
