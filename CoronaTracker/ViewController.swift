//
//  ViewController.swift
//  CoronaTracker
//
//  Created by Aaryan Kothari on 17/05/20.
//  Copyright © 2020 Aaryan Kothari. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    

    @IBOutlet var someView: UIView!
    
    var height : Double {
        return Double(someView.frame.height)
    }
    
    var width : Double{
        return Double(someView.frame.width)
    }
    
    var spacing : Double{
        return width/3
    }
    
    let colors : [UIColor] = [#colorLiteral(red: 0.5725490451, green: 0, blue: 0.2313725501, alpha: 1),#colorLiteral(red: 0.3411764801, green: 0.6235294342, blue: 0.1686274558, alpha: 1),#colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0),#colorLiteral(red: 0.9607843161, green: 0.7058823705, blue: 0.200000003, alpha: 1)]

    
    
    override func viewDidLoad() {
        //height = Double(someView.frame.height)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    
    func addCircles(){
        
    }
    
    
    
    
    
    
    
    
    func addLines(_ array : [Double]){
        self.someView.layer.sublayers?.forEach { $0.removeFromSuperlayer() }
        for i in 0...3{
            let y = (array[i]/100) * 100
            let space = Double(spacing) * Double(i)
            let start = CGPoint(x: space, y: height)
            let end = CGPoint(x: space, y: height-y)
            addLine(from: start, to: end, color: colors[i])
        }
    }
    
    
    
    func addLine(from fromPoint : CGPoint,to toPoint:CGPoint,color:UIColor){
            let shapeLayer =  CAShapeLayer()

            let path = UIBezierPath()
            path.move(to: fromPoint)
            path.addLine(to: toPoint)

            // create shape layer for that path

            shapeLayer.fillColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0).cgColor
            shapeLayer.strokeColor = color.cgColor
            shapeLayer.lineWidth = CGFloat(width/10)
            shapeLayer.path = path.cgPath
            shapeLayer.lineCap = .round

            // animate it

            someView.layer.addSublayer(shapeLayer)
            let animation = CABasicAnimation(keyPath: "strokeEnd")
            animation.fromValue = 0
            animation.duration = 2
            shapeLayer.add(animation, forKey: "MyAnimation")

    }
    
}

