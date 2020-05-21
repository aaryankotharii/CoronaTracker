//
//  GlobeView.swift
//  CoronaTracker
//
//  Created by Aaryan Kothari on 21/05/20.
//  Copyright © 2020 Aaryan Kothari. All rights reserved.
//

import SwiftUI

struct GlobeView: View {
    var body: some View {
        ScrollView(.horizontal){
            Text("")
        }
    }
}

struct countryBar: View{
    var height : CGFloat = 100
    var body : some View{
        VStack{
            Color(.blue)
                .cornerRadius(20, corners: [.topLeft, .bottomRight])
                .animation(.easeOut(duration: 5))
            Text("🇮🇳")
        }.frame(width: 25, height: height, alignment: .center)
    }
}

struct GlobeView_Previews: PreviewProvider {
    static var previews: some View {
        countryBar()
    }
}

extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape( RoundedCorner(radius: radius, corners: corners) )
    }
}

struct RoundedCorner: Shape {

    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}



