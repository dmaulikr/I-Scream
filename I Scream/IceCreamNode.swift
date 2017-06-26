//
//  IceCreamNode.swift
//  I Scream
//
//  Created by JR on 6/24/17.
//  Copyright © 2017 JR. All rights reserved.
//

import UIKit
import SpriteKit

class IceCreamNode: SKSpriteNode {
    var damage : Int64 = 0
    
    init(_ myImage : String, _ myDamage : Int64){
        let texture = SKTexture(imageNamed: myImage)
        super.init(texture: texture, color: UIColor.clear, size: texture.size())
        damage = myDamage
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func getDamagePoints() -> Int64{
        return damage
    }
    
    func setDamagePoints(_ myDamage : Int64){
        damage = myDamage
    }
}
