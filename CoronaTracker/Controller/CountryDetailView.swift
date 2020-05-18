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
        
    var hello : String = "India"
            
    var body: some View {
        VStack{
            LineChartView(data: country.current?.active ?? [], title: hello)
            
            MultiLineChartView(data: [(country.current?.active ?? [], GradientColors.green), ([90,99,78,111,70,60,77], GradientColors.purple), ([34,56,72,38,43,100,50], GradientColors.orngPink)], title: "Title")
            Button(action: fetch){
                Text("hi")
            }
        }.onAppear(perform: fetch)
    }
    
    private  func fetch(){
        print("fetching")
        self.country.fetch("India")
    }
}

struct CountryDetailView_Previews: PreviewProvider {
    static var previews: some View {
        CountryDetailView()
    }
}
