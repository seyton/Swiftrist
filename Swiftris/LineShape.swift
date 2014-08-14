//
//  LineShape.swift
//  Swiftris
//
//  Created by Wesley Matlock on 8/12/14.
//  Copyright (c) 2014 Insoc. All rights reserved.
//

import Foundation



class LineShape:Shape {
    
    /**

    Orientaitons 0 and 180:
    |0|*
    |1|
    |2|
    |3|
    
    
    Orientaitons 90 and 270
    
       *
    |0|1|2|3|
    
    
    
    */
    
    
    
    override var blockRowColumnPositions: [Orientation: Array<(columnDiff: Int, rowDiff: Int)>] {
        
        return [
            Orientation.Zero:       [(0,0), (0,1), (0,2), (0,3)],
            Orientation.Ninety:     [(-1,0), (0,0), (1,0), (2,0)],
            Orientation.OneEighty:  [(0,0), (0,1), (0,2), (0,3)],
            Orientation.TwoSeventy: [(-1,0), (0,0), (1,0), (2,0)]
        ]
    }
    
    override var bottomBlocksForOrientations: [Orientation: Array<Block>] {
        
        return [
            Orientation.Zero:       [blocks[FourthBlockIdx]],
            Orientation.Ninety:     blocks,
            Orientation.OneEighty:  [blocks[FourthBlockIdx]],
            Orientation.TwoSeventy: blocks
        ]
    }
}

