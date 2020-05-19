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
    
   // var countryTotalData = CountryStruct()
        
    var hello : String = "India"
    var slug : String = "india"
            
    var body: some View {
        VStack{
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

struct CountryCases : View {
    @State var hello = "India"
    var body: some View {
        VStack{
            Text(hello)
        }
    }
}

struct CountryDetailView_Previews: PreviewProvider {
    static var previews: some View {
        CountryCases()
    }
}
