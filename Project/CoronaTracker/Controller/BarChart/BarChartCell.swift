//
//  ChartCell.swift
//  ChartView
//
//  Created by András Samu on 2019. 06. 12..
//  Copyright © 2019. András Samu. All rights reserved.
//

import SwiftUI

public struct BarChartCell : View {
    var value: Double
    var index: Int = 0
    var width: Float
    var numberOfDataPoints: Int
    var cellWidth: Double {
        return Double(width)/(Double(numberOfDataPoints) * 1.5)
    }
    
    var accentColor: Color
    var gradient: GradientColor?
    
    var emoji : String
    
    @State var scaleValue: Double = 0
    @Binding var touchLocation: CGFloat
    public var body: some View {
        ZStack {
            VStack{
            RoundedRectangle(cornerRadius: 4)
                .fill(LinearGradient(gradient: gradient?.getGradient() ?? GradientColor(start: accentColor, end: accentColor).getGradient(), startPoint: .bottom, endPoint: .top))
                Text(self.emoji)
            }
            }
            .frame(width: CGFloat(self.cellWidth))
            .scaleEffect(CGSize(width: 1, height: self.scaleValue), anchor: .bottom)
            .onAppear(){
                self.scaleValue = self.value
            }
        .animation(Animation.spring().delay(self.touchLocation < 0 ?  Double(self.index) * 0.04 : 0))
    }
}

//#if DEBUG
//struct ChartCell_Previews : PreviewProvider {
//    static var previews: some View {
//        BarChartCell(value: Double(0.75), index: 320, width: 12, numberOfDataPoints: Colors.OrangeStart, accentColor: nil, gradient: .constant(-1), emoji: "🇮🇳", touchLocation: Binding.constant(10.0))
//    }
//}
//#endif
