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
        Text(hello)
            LineChartView(data: country.deathList, title: hello)
        MultiLineChartView(data: [(getCOuntryArray(), GradientColors.green), ([90,99,78,111,70,60,77], GradientColors.purple), ([34,56,72,38,43,100,50], GradientColors.orngPink)], title: "Title")
        }.onAppear(perform: fetch)
    }
    
    private func fetch(){
        print("fetching")
        self.country.fetch("India")}
    func getCOuntryArray()->[Double]{
        let array = country.current?.countries.map{Double($0.Active)}
        return array ?? []
    }
}

struct CountryDetailView_Previews: PreviewProvider {
    static var previews: some View {
        CountryDetailView()
    }
}
