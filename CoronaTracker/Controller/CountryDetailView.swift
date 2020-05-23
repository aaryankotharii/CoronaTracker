//
//  CountryDetailView.swift
//  CoronaTracker
//
//  Created by Aaryan Kothari on 18/05/20.
//  Copyright © 2020 Aaryan Kothari. All rights reserved.
//

import SwiftUI

struct CountryDetailView: View {
    @ObservedObject var country = CurrentCountryData()
    var worldData : Countries!
    var data : [[Int]]
    var countryName : String = "IndiaIndiaIndiaIndiaIndia"
    var slug : String = "india"
    
    var state = ["Confirmed","Recovered","Deaths","Active"]
    
    @State var index = 0
    
    var body: some View {
        GeometryReader { geo in
            VStack(alignment: .leading){
                Text(self.countryName)
                    .font(.system(size: 40, weight: .bold))
                    .multilineTextAlignment(.leading)
                    .offset(x: 0, y: -20)
                    .lineLimit(2)
                    .minimumScaleFactor(0.6)
                Picker(selection: self.$index, label: Text("")) {
                    Image("virus-1").resizable().tag(0)
                    Image("cross-1").resizable().tag(1)
                    Image("coffin-1").resizable().tag(2)
                    Image("bolt").resizable().tag(3)
                }.pickerStyle(SegmentedPickerStyle())
                    .padding()
                Spacer()
                VStack(alignment: .leading){
                    Text(self.state[self.index])
                        .font(.system(size: 30, weight: .medium, design: .rounded))
                    HStack{
                        Text("NEW:- ").bold()
                        Text("\(self.data[self.index][0])")
                    }
                    HStack{
                        Text("TOTAL:- ").bold()
                        Text("\(self.data[self.index][1])")
                    }
                }.font(.system(size: 16, weight: .medium, design: .rounded))
                LineChartView.init(data: self.country.allData?[self.index] ?? [], title: self.state[self.index],frame: CGSize(width: geo.size.width-30, height: 150))
                    .padding(.bottom,50)
            }.onAppear(perform: self.fetch)
            .padding(.horizontal,15)
        }
    }
    
    private  func fetch(){
        print("fetching")
        self.country.fetch(slug)
    }
}

struct countryCases : View{
    var body: some View {
    Text("hi")
    }
}


struct CountryDetailView_Previews: PreviewProvider {
    static var previews: some View {
        CountryDetailView( data: [])
    }
}
