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
    var countryName : String = "IndiaIndiaIndiaIndiaIndia"
    var slug : String = "india"
    
    var state = ["Confirmed","Recovered","Deaths","Active"]
    
    @State var index = 0
    
    var body: some View {
        GeometryReader { geo in
            VStack(alignment: .leading){
                Text(self.countryName)
                   // .padding(.leading, 20.0)
                    .font(.system(size: 40, weight: .bold))
                    .multilineTextAlignment(.leading)
                    .offset(x: 0, y: -20)
                    .lineLimit(1)
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
                        Text("\(self.worldData.NewConfirmed)")
                    }
                    HStack{
                        Text("TOTAL:- ").bold()
                        Text("\(self.worldData.NewConfirmed)")
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

struct CountryCases: View {
    var country : Countries!
    var name : String = "🇮🇳 INDIA"
    var body: some View {
        VStack(spacing:30){
            Text(name)
                .font(Font.system(size: 50, weight: .bold, design: .rounded))
                .underline()
            HStack(spacing:20){
                
                VStack(alignment: .trailing,spacing: 10){
                    Text("")
                    Text("Cases:")
                    Text("Deaths:")
                    Text("Recovered:")
                    
                }.font(Font.system(size: 20, weight: .medium, design: .rounded))
                    .padding(.top,20)
                VStack(spacing: 16){
                    Text("NEW")
                        .font(Font.system(size: 22, weight: .bold, design: .rounded))
                    Text("\(country.NewConfirmed)")
                    Text("\(country.NewDeaths)")
                    Text("\(country.NewRecovered)")
                    
                }
                VStack(spacing: 16){
                    Text("TOTAL")
                        .font(Font.system(size: 22, weight: .bold, design: .rounded))
                    Text("\(country.TotalConfirmed)")
                    Text("\(country.TotalDeaths)")
                    Text("\(country.TotalRecovered)")
                    
                }
            }
        }
        .padding(30)
        .background(Color.init(#colorLiteral(red: 0.8582246933, green: 1, blue: 0.9281178106, alpha: 1)))
        .cornerRadius(30)
    }
}


struct CountryDetailView_Previews: PreviewProvider {
    static var previews: some View {
        CountryDetailView()
    }
}
