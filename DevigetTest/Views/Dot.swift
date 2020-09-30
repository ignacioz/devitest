//
//  Dot.swift
//  DevigetTest
//
//  Created by Ignacio Zunino on 30/09/2020.
//

import UIKit

@IBDesignable
class Dot: UIView {
    
    @IBInspectable var color: UIColor = UIColor.blue {
       didSet {
           setNeedsDisplay()
       }
    }

    override func draw(_ rect: CGRect) {
      let path = UIBezierPath(ovalIn: rect)
      color.setFill()
      path.fill()
    }
    
}
