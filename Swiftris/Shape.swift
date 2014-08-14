//
//  Shape.swift
//  Swiftris
//
//  Created by Wesley Matlock on 8/12/14.
//  Copyright (c) 2014 Insoc. All rights reserved.
//

import Foundation
import SpriteKit

let NumOrientations: UInt32 = 4

enum Orientation: Int, Printable {
    case Zero = 0, Ninety, OneEighty, TwoSeventy
    
    var description:String {
        
        switch self {
        case .Zero:
            return "0"
        case .Ninety:
            return "90"
        case .OneEighty:
            return "180"
        case .TwoSeventy:
            return "270"
            
            
        }
    }
    
    static func random() -> Orientation {
        return Orientation.fromRaw(Int(arc4random_uniform(NumOrientations)))!
    }
    
    
    static func rotate(orientation:Orientation, clockWise:Bool) ->Orientation {
        
        var rotated = orientation.toRaw() + (clockWise ? 1 : -1)
        
        if rotated > Orientation.TwoSeventy.toRaw() {
            rotated = Orientation.Zero.toRaw()
        }
        else if rotated < 0 {
            rotated = Orientation.TwoSeventy.toRaw()
        }
        
        return Orientation.fromRaw(rotated)!
        
    }
    
}

//Number of shape varieties
let NumShapeTypes:UInt32 = 7

//Shape Indexes
let FirstBlockIdx:Int = 0
let SecondBlockIdx:Int = 1
let ThirdBlockIdx:Int = 2
let FourthBlockIdx:Int = 3


class Shape: Hashable, Printable {
    
    //Color of the shape
    let color:BlockColor
    
    // blocks comprising the shape
    var blocks = Array<Block>()
    
    //the current orientation of the shape
    var orientation: Orientation
    
    //column and ro representing the shapes anchor point
    var column, row:Int
    
    //Required overrides..
    var blockRowColumnPositions:[Orientation: Array<(colomnDiff:Int, rowDiff:Int)>] {
        return [:]
    }
    
    var bottomBlocksForOrientations:[Orientation: Array<Block>] {
        return [:]
    }
    var bottomBlocks:Array<Block> {
        if let bottomBlocks = bottomBlocksForOrientations[orientation] {
            return bottomBlocks
        }
        return []
    }
    
    //Hashtable
    var hashValue:Int {
        return reduce(blocks, 0) { $0.hashValue ^ $1.hashValue }
    }
    
    //Printable
    var description:String {
        return "\(color) block facing \(orientation): \(blocks[FirstBlockIdx]), \(blocks[SecondBlockIdx]), \(blocks[ThirdBlockIdx]), \(blocks[FourthBlockIdx])"
    }
    
    init(column:Int, row:Int, color:BlockColor, orientation:Orientation) {
        self.column = column
        self.row = row
        self.color = color
        self.orientation = orientation
    }
    
    convenience init(column:Int, row:Int) {
        self.init(column:column, row:row, color:BlockColor.random(), orientation:Orientation.random())
    }
    
    final func initializeBlocks() {
        if let blockRowColumnTranslations = blockRowColumnPositions[orientation] {
            
            for i in 0..<blockRowColumnTranslations.count {
                
                let blockRow = row + blockRowColumnTranslations[i].rowDiff
                let blockColumn = column + blockRowColumnTranslations[i].colomnDiff
                let newBlock = Block(column: blockColumn, row: blockRow, color: color)
                blocks.append(newBlock)
            }
        }
    }
    
    final func rotateBlocks(orientation: Orientation) {
        if let blockRowColumnTranslation:Array<(columnDiff: Int, rowDiff: Int)> = blockRowColumnPositions[orientation] {
            for (idx, (columnDiff:Int, rowDiff:Int)) in enumerate(blockRowColumnTranslation) {
                blocks[idx].column = column + columnDiff
                blocks[idx].row = row + rowDiff
            }
        }
    }
    
    final func rotateClockwise() {
        
        let newOrientation = Orientation.rotate(orientation, clockWise: true)
        rotateBlocks(orientation)
        orientation = newOrientation
        
    }
    
    final func rotateCounterClockwise() {
        let newOrientation = Orientation.rotate(orientation, clockWise: false)
        rotateBlocks(orientation)
        orientation = newOrientation
        
    }
    
    final func lowerShapeByOneRow() {
        shiftBy(0, rows:1)
    }
    
    final func raiseShapeByOneRow() {
        shiftBy(0, rows: -1)
    }
    
    final func shiftRightByOneColumn() {
        shiftBy(1, rows: 0)
    }
    
    final func shiftLeftByOneColumn() {
        shiftBy(-1, rows: 0)
    }
    
    
    final func shiftBy(columns:Int, rows:Int) {
        self.column += columns
        self.row += rows
        
        for block in blocks {
            block.column += columns
            block.row += rows
        }
    }
    
    final func moveTo(column: Int, row:Int) {
        self.column = column
        self.row = row
        rotateBlocks(orientation)
    }

    final class func random(startingColumn:Int, startingRow:Int) -> Shape {

        switch Int(arc4random_uniform(NumShapeTypes)) {
        
        case 0:
            return SquareShape(column: startingColumn, row: startingRow)
        case 1:
            return LineShape(column: startingColumn, row: startingRow)
        case 2:
            return TShape(column: startingColumn, row: startingRow)
        case 3:
            return LShape(column: startingColumn, row: startingRow)
        case 4:
            return JShape(column: startingColumn, row: startingRow )
        case 5:
            return SShape(column: startingColumn, row: startingRow)
        default:
            return ZShape(column: startingColumn, row: startingRow)
        
        }
    }
    
}

func ==(lhs:Shape, rhs:Shape) -> Bool {
    return lhs.row == rhs.row && lhs.column == rhs.column
}






