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
            LineChartView(data: country.active ?? [], title: hello)
            
            MultiLineChartView(data: [(country.current?.active ?? [], GradientColors.green), (country.current?.deaths ?? [], GradientColors.purple), (country.current?.recovered ?? [], GradientColors.orngPink)], title: "Title")
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
