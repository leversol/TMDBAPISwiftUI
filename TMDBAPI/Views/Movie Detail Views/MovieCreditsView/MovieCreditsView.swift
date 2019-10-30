//
//  MovieCreditsView.swift
//  TMDBAPI
//
//  Created by Ghaff Ett on 27/09/2019.
//  Copyright © 2019 GhaffMac. All rights reserved.
//

import SwiftUI
import Combine
import KingfisherSwiftUI
import class Kingfisher.ImageCache

// MARK: - Movie Credits View
struct MovieCreditsView: View {
	        
    let credits: [Credit]
    //let proxy: GeometryProxy
    
    @State private var fetcher = Fetcher()
    @State private var person = Person.placeholder
    @State private var selection: Int?
    

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                ForEach(self.credits, id:\.creditIdentifier) { credit in
                    MovieCreditRow(credit: credit).environmentObject(self.fetcher)
                        .frame(width: UIScreen.width / 4, height: (UIScreen.width / 4) / 0.7)
                }
            }//.padding(.horizontal)
        }//.padding(.horizontal, -10)
    }
}
//fileprivate
// MARK: - Movie Credit Row
extension MovieCreditsView {

    struct MovieCreditRow: View {
	
        @State var selection: Int?
        @State private var done = false
                
        let credit: Credit
        
        var body: some View {
            ZStack(alignment: .bottom) {
                NavigationLink(destination: PersonView(credit: self.credit), tag: 0, selection: self.$selection) {
                    EmptyView()
                }
                                              
                ZStack {
                    KFImage(source: TMDBAPI.imageResource(for: credit.creditProfilePath))
                        .resizable()
                        .onSuccess { (r) in
                            self.done = true
                    }
                    .cancelOnDisappear(true)
                    .opacity(self.done || ImageCache.default.isCached(forKey: credit.creditProfilePath ?? "") ? 1.0 : 0.0)
                    .animation(.linear(duration: 0.4))
                    
                    LinearGradient(gradient: Gradient(colors: [.clear, .black]),
                                   startPoint: .center,
                                   endPoint: .bottom)
                }.cornerRadius(10)
                
                VStack {
                    Text(credit.creditName)
                        .bold()
                        .font(.system(size: 13))
                        .lineLimit(1)
                    if !credit.extraInfo.isEmpty {
                        Text(credit.extraInfo)
                            .font(.system(size: 12))
                            .lineLimit(2)
                    }
                }
                .foregroundColor(.white)
                .multilineTextAlignment(.center).padding(5)
            }
            .onTapGesture {
                self.selection = 0
            }
        }
	}
}


/*.onTapGesture {
    self.fetcher.personMovies.0.removeAll()
    self.fetcher.personMovies.1.removeAll()
    self.fetcher.fetchPersonDetails(self.credit)
    self.fetcher.fetchPersonMovies(self.credit)
    self.selection = 0
}*/
