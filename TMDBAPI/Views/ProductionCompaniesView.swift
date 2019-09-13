//
//  ProductionCompaniesView.swift
//  TMDBAPI
//
//  Created by Ghaff Ett on 01/09/2019.
//  Copyright © 2019 GhaffMac. All rights reserved.
//

import SwiftUI
import KingfisherSwiftUI

struct ProductionCompaniesView: View {
    
    let productionCompanies: [ProductionCompany]
    
    var body: some View {
        
        List {
            Section(header: Color(.systemBackground).listRowInsets(.zero),
                    footer: Color(.systemBackground).listRowInsets(.zero))
            {
                ForEach(productionCompanies.sorted { $0.name < $1.name }, id: \.id) { comp in
                    ProductionCompanyView(company: comp)
                }
            }
        }.navigationBarTitle(productionCompanies.count == 1 ? Text("Production Company") : Text("Production Companies"), displayMode: .inline)
    }
}

struct ProductionCompanyView: View {
    
    let company: ProductionCompany
    
    var body: some View {
        HStack(alignment: .top) {
            
            if company.logoPath != nil {
                KFImage(TMDBAPI.getMoviePosterUrl(company.logoPath!)!)
                .resizable()
                .onFailure { err in
                        debugPrint("Error fetching production company url: \(err)")
                }
                .scaledToFit()
                .frame(width: 80, height: 100)
                .padding(2)
                .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray, lineWidth: 1).opacity(0.5))
                
            }
            else {
                ZStack {
                    Rectangle()
                        .fill(Color(#colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)))
                        .opacity(0.2)
                        .cornerRadius(8)
                        .frame(width: 80, height: 100)
                        .padding(2)
                    Image(systemName: "photo.fill")
                        .imageScale(.large)
                }
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text(company.name)
                .font(.headline)
                Text(company.originCountry.toCountryName)
                .font(.subheadline)
            }
        }
    }
}
