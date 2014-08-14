//
//  GameViewController.swift
//  Swiftris
//
//  Created by Wesley Matlock on 8/12/14.
//  Copyright (c) 2014 Insoc. All rights reserved.
//

import UIKit
import SpriteKit

class GameViewController: UIViewController, SwiftrisDelegate, UIGestureRecognizerDelegate {
    
    var scene: GameScene!
    var swiftris:Swiftris!
    
    var panPointReference:CGPoint?
    
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var levelLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Configure the view.
        let skView = view as SKView
        skView.multipleTouchEnabled = false
        
        // Create and configure the scene.
        scene = GameScene(size: skView.bounds.size)
        scene.scaleMode = .AspectFill
        scene.tick = didTick
        
        swiftris = Swiftris()
        swiftris.delegate = selfma
        swiftris.beginGame()
        
        // Present the scene.
        skView.presentScene(scene)
        
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    @IBAction func didTap(sender: UITapGestureRecognizer) {
        
        swiftris.rotateShape()
    
    }
    
    @IBAction func didPan(sender: UIPanGestureRecognizer) {
        let currentPoint = sender.translationInView(self.view)
        
        
        if let originalPoint = panPointReference {
            
            if abs(currentPoint.x - originalPoint.x) > (BlockSize * 9.0) {
                
                if sender.velocityInView(self.view).x > CGFloat(0) {
                    swiftris.moveShapeRight()
                    panPointReference = currentPoint
                }
                else {
                    swiftris.moveShapeLeft()
                    panPointReference = currentPoint
                    
                }
            }
        
        }
        else if sender.state == .Begin {
            panPointReference = currentPoint
        }
    }
    
    @IBAction func didSwipe(sender: UISwipeGestureRecognizer) {
        swiftris.dropShape()
    }
    
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer!, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer!) -> Bool {
        return true
    }
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer!, shouldRequireFailureOfGestureRecognizer otherGestureRecognizer: UIGestureRecognizer!) -> Bool {
        
        if let swipeRec = gestureRecognizer as? UISwipeGestureRecognizer {
            
            if let panRec = otherGestureRecognizer as? UIPanGestureRecognizer {
                return true
            }
        }
        else if let panRec = gestureRecognizer as? UIPanGestureRecognizer {
            if let tapRect = otherGestureRecognizer as? UITapGestureRecognizer {
                return true
                
                
            }
        }
        
        
        return false
        
    }
    
    func didTick() {
        
        swiftris.letShapeFall()
    }
    
    func nextShape() {
        
        let newShapes = swiftris.newShape()
        
        if let fallingShape = newShapes.fallingShape {
            
            self.scene.addPreviewShapeToScene(newShapes.nextShape!) {}
            self.scene.movePreviewShape(fallingShape) {
                
                self.view.userInteractionEnabled = true
                self.scene.startTicking()
            }
            
        }
        
    }
    
    
    func gameDidBegin(swiftris: Swiftris) {
        
        levelLabel.text = "\(swiftris.level)"
        scoreLabel.text = "\(swiftris.score)"

        
        
        //false when restarting a new game
        if swiftris.nextShape != nil && swiftris.nextShape!.blocks[0].sprite == nil {
            
            scene.addPreviewShapeToScene(swiftris.nextShape, completion: nil) {
                self.nextShape()
            }
        }
        else {
            nextShape()
        }
        
    }
    
    func gameDidEnd(swiftris: Swiftris) {
        
        view.userInteractionEnabled = false
        scene.stopTicking()
        
        scene.playSound("gameover.mp3")
        scene.animateCollapsingLines(swiftris.removeAllBlocks(), fallenBlocks: Array<Array<Block>>()) {
            swiftris.beginGame()
        }
        
        
    }
    
    func gameDidLeavelUp(swiftris: Swiftris) {
        
        levelLabel.text = "\(swiftris.level)"
        
        
        if scene.tickLenthMillis >= 100 {
            scene.tickLenthMillis -= 100
        }
        else if scene.tickLenthMillis > 50 {
            scene.tickLenthMillis -= 50
        }
        
        scene.playSound("levelup.mp3")
    }
    
    
    func gameShapeDidDrop(swiftris: Swiftris) {
        
        scene.stopTicking()
        scene.redrawShape(swiftris.fallingShape!, completion: nil) {
            swiftris.letShapeFall()
        }
        
    }
    
    
    func gameShapeDidLand(swiftris: Swiftris) {
        scene.stopTicking()
        self.view.userInteractionEnabled = false
        
        
        let removedLines = swiftris.removeCompletedLines()
        
        if removedLines.linesRemoved.count > 0 {
            self.scoreLabel.text = "\(swiftris.score)"
            
            scene.animateCollapsingLines(removedLines.linesRemoved, fallenBlocks: removedLines.fallenBlocks, completion: nil) {
                
                self.gameShapeDidLand(swiftris)
            }
            
            scene.playSound("bomb.mp3")
            
        }
        else {
            nextShape() 
        }
        
        
    }
    
    func gameShapeDidMove(swiftris: Swiftris) {
        scene.redrawShape(swiftris.fallingShape!, completion: nil)
    }
    
    
    
    
    
}
