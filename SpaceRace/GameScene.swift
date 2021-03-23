//
//  GameScene.swift
//  SpaceRace
//
//  Created by Gökberk Köksoy on 1.03.2021.
//

import SpriteKit


class GameScene: SKScene, SKPhysicsContactDelegate {
    var starfield: SKEmitterNode!
    var player: SKSpriteNode!
    var scoreLabel: SKLabelNode!
    
    let possibleEnemies = ["ball", "hammer", "tv"]
    var isGameOver = false
    var gameTimer: Timer?
    var isTouched: Bool!
    
    var enemyCount = 0
    var interval: Double = 1
    var score = 0 {
        didSet {
            scoreLabel.text = "Score: \(score)"
        }
    }
    
    override func didMove(to view: SKView) {
        backgroundColor = .black
        starfield = SKEmitterNode(fileNamed: "starfield")!
        starfield.position = CGPoint(x: 1024, y: 384)
        starfield.advanceSimulationTime(10)
        starfield.zPosition = -1
        addChild(starfield)
        
        player = SKSpriteNode(imageNamed: "player")
        player.position = CGPoint(x: 100, y: 384)
        player.physicsBody = SKPhysicsBody(texture: player.texture!, size: player.size)
        player.physicsBody?.contactTestBitMask = 1
        addChild(player)
        
        scoreLabel = SKLabelNode(fontNamed: "Chalkduster")
        scoreLabel.position = CGPoint(x: 16, y: 16)
        scoreLabel.horizontalAlignmentMode = .left
        addChild(scoreLabel)
        score = 0
        
        physicsWorld.gravity = .zero
        physicsWorld.contactDelegate = self
        
        gameTimer = Timer.scheduledTimer(timeInterval: interval, target: self, selector: #selector(createEnemy), userInfo: nil, repeats: true)
    }
    
    @objc func createEnemy() {
        guard let enemy = possibleEnemies.randomElement() else { return }
        
        let node = SKSpriteNode(imageNamed: enemy)
        node.position = CGPoint(x: 1200, y: Int.random(in: 50...728))
        addChild(node)
        enemyCount += 1
        if enemyCount % 20 == 0  && interval > 0 {
            gameTimer?.invalidate()
            gameTimer = Timer.scheduledTimer(timeInterval: interval - 0.1, target: self, selector: #selector(createEnemy), userInfo: nil, repeats: true)
        }
        node.physicsBody = SKPhysicsBody(texture: node.texture!, size: node.size)
        node.physicsBody?.categoryBitMask = 1
        node.physicsBody?.velocity = CGVector(dx: -500, dy: 0)
        node.physicsBody?.angularVelocity = 5
        node.physicsBody?.linearDamping = 0
        node.physicsBody?.angularDamping = 0
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        
        for node in children {
            if node.position.x < -300 {
                node.removeFromParent()
            }
        }
        
        if !isGameOver {
            score += 1
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let players = nodes(at: location)
        if players.contains(player) {
            isTouched = true
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        var location = touch.location(in: self)
        
        // dont go too up or down
        if location.y < 100 {
            location.y = 100
        } else if location.y > 668 {
            location.y = 668
        }
        
        if isTouched {
            player.position = location
        }

    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) { isTouched = false }
    
    func didBegin(_ contact: SKPhysicsContact) {
        let explosion = SKEmitterNode(fileNamed: "explosion")!
        explosion.position = player.position
        addChild(explosion)
        
        player.removeFromParent()
        isGameOver = true
        gameTimer?.invalidate()
    }
}
