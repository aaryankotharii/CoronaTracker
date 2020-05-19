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
        
   // var countryTotalData = CountryStruct()
        
    var hello : String = "India"
    var slug : String = "india"
            
    var body: some View {
        VStack{
            CountryCases(country: worldData, name: hello)
            LineView(data: country.dailyNew ?? [], title: "Line chart", legend: "Full screen").padding()
            
//            LineChartView(data: country.active ?? [], title: hello)
//
            MultiLineChartView(data: [(country.current?.active ?? [], GradientColors.green), (country.current?.deaths ?? [], GradientColors.purple), (country.current?.recovered ?? [], GradientColors.orngPink)], title: "Title",legend: "Full screen")
            Button(action: fetch){
                Text("hi")
            }
        }.onAppear(perform: fetch)
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
