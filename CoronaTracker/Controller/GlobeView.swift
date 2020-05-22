//
//  GlobeView.swift
//  CoronaTracker
//
//  Created by Aaryan Kothari on 21/05/20.
//  Copyright © 2020 Aaryan Kothari. All rights reserved.
//

import SwiftUI
import CoreData

struct GlobeView: View {
   let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    @Environment(\.managedObjectContext) var moc
    @FetchRequest(entity: Global.entity(), sortDescriptors: []) var global : FetchedResults<Global>
    
    var cases : [countrycase]
    var body: some View {
            VStack{
                Text("Global Stats")
                chart(cases: cases)
            }.background(LinearGradient(gradient: Gradient(colors: [Color(#colorLiteral(red: 0.7294117647, green: 0.8784313725, blue: 0.9098039216, alpha: 1)),Color(#colorLiteral(red: 0.4549019608, green: 0.7647058824, blue: 0.8235294118, alpha: 1))]), startPoint: .top, endPoint: .bottom)).edgesIgnoringSafeArea(.bottom).onAppear {
                print(self.global)
        }
    }
}

struct bar : View {
    var value: Double
    var index: Int = 0
    
    @State var scaleValue: Double = 0
    var emoji : String
    
    var body: some View {
    VStack{
            ZStack(alignment: .bottom) {
                RoundedRectangle(cornerRadius: 4)
                    .fill(LinearGradient(gradient: Gradient(colors: [.red,.orange]), startPoint: .bottom, endPoint: .top))
                }
                .frame(width: 30)
                .scaleEffect(CGSize(width: 1, height: self.scaleValue), anchor: .bottom)
                .onAppear(){
                    self.scaleValue = self.value
                }
            .animation(Animation.spring().delay(0.04))
        Text(emoji)
        }
    }
}

struct chart : View{
    @State var cases : [countrycase]
    var body: some View{
        ScrollView(.horizontal, showsIndicators: false){
            HStack{
                ForEach(cases, id:\.self){country in
                    bar(value: self.calculateHeight(country.cases), emoji: country.emoji)
                        .onTapGesture {
                            print(country.emoji)
                    }
                }
            }
        }
    }
    
    func calculateHeight(_ numberOfCases : Int)->Double{
    let cases = Double(numberOfCases)
    switch cases {
        case _ where cases < 100:
                    return cases/5000
         case _ where cases < 1000:
            return  cases / 40000
                case _ where cases < 10000:
                    return cases/350000
         case _ where cases < 20000:
            return cases / 500000
         case _ where cases > 1500000:
            return 0.5
         case  _ where cases > 150000:
            return 0.4
         default:
            return Double(cases*4)/2000000
         }
    }
}



struct GlobeView_Previews: PreviewProvider {
    static var previews: some View {
        GlobeView(cases: [countrycase(name: "india", emoji: "hi", cases: 123456)])
    }
}

struct countrycase: Hashable {
    var name : String
    var emoji : String
    var cases : Int
}






extension Int32 {
    var stringValue : String{
        return String(self)
    }
}
