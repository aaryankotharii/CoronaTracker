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
    var countryName : String = "India"
    var slug : String = "india"
    
    var state = ["Confirmed","Recovered","Deaths","Active"]
    
    @State var index = 0
            
    var body: some View {
        
        NavigationView {
        VStack{
            VStack{
                Picker(selection: $index, label: Text("What is your favorite color?")) {
                    Image("virus-1").resizable().tag(0)
                    Image("cross-1").resizable().tag(1)
                    Image("coffin-1").resizable().tag(2)
                    Image("bolt").resizable().tag(3)
                }.pickerStyle(SegmentedPickerStyle())
                    .padding()
            HStack{
                    LineChartView(data: country.allData?[index] ?? [], title: state[index])
            }
            }
            
            LineView(data: country.dailyNew ?? [], title: "Daily New Cases", legend: "Daily New Cases").padding()
        }.onAppear(perform: fetch)
        }.navigationBarTitle(Text(countryName), displayMode: .large).minimumScaleFactor(0.5)
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
        CountryCases()
    }
}
