//
//  HomeTableViewCell.swift
//  CoronaTracker
//
//  Created by Aaryan Kothari on 17/05/20.
//  Copyright © 2020 Aaryan Kothari. All rights reserved.
//

import UIKit

class HomeTableViewCell: UITableViewCell {

    @IBOutlet var countryNameLabel: UILabel!
    
    @IBOutlet var graphView: UIView!
    
    var height : Double {
        return Double(graphView.frame.height)
    }
    
    var width : Double{
        return Double(graphView.frame.width)
    }
    
    var spacing : Double{
        return width/3
    }
    var total : Int!
    var recovered : Int!
    var deaths : Int!
    var active : Int {
        return total-deaths-recovered
    }

    
    
    let colors : [UIColor] = [#colorLiteral(red: 0.9921568627, green: 0.1882352941, blue: 0.4117647059, alpha: 1),#colorLiteral(red: 0.9960784314, green: 0.6705882353, blue: 0, alpha: 1),#colorLiteral(red: 0.08235294118, green: 0.7960784314, blue: 0.2666666667, alpha: 1),#colorLiteral(red: 0.2549019608, green: 0.2549019608, blue: 0.2549019608, alpha: 1)]

    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        let i = calculatePercentages()
        addLines(i)
        print(total,recovered,deaths,active)
        print(i)
    }
    
    func calculatePercentages()->[Double]{
        let activePercentage = Double(active)/Double(total)
        let deathPercentage = Double(deaths)/Double(total)
        let recoveredPercentage = Double(recovered)/Double(total)
        return [1,activePercentage,recoveredPercentage,deathPercentage]
    }
    
    func addLines(_ array : [Double]){
        self.graphView.layer.sublayers?.forEach { $0.removeFromSuperlayer() }
        for i in 0...3{
            let y = array[i] * height
            let space = spacing * Double(i)
            let start = CGPoint(x: space, y: height)
            let end = CGPoint(x: space, y: height-y)
            let color = colors[i]
            let graph = HomeGraph(start: start, end: end, color: color, space: space)
            addLine(graph)
        }
    }
    
    
    
    func addLine(_ graph : HomeGraph){
            let shapeLayer =  CAShapeLayer()

            let path = UIBezierPath()
        path.move(to: graph.start)
        path.addLine(to: graph.end)

            // create shape layer for that path

            shapeLayer.fillColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0).cgColor
        shapeLayer.strokeColor = graph.color.cgColor
            shapeLayer.lineWidth = CGFloat(width/10)
            shapeLayer.path = path.cgPath
            shapeLayer.lineCap = .round

            // animate it

            graphView.layer.addSublayer(shapeLayer)
            let animation = CABasicAnimation(keyPath: "strokeEnd")
            animation.fromValue = 0
            animation.duration = 2
            shapeLayer.add(animation, forKey: "MyAnimation")

    }
    
    

}

struct HomeGraph {
    var start : CGPoint
    var end : CGPoint
    var color : UIColor
    var space : Double
}
