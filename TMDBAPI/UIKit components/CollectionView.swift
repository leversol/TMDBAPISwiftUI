//
//  CollectionView.swift
//  UICollectionViewSwiftUI
//
//  Created by Ghaff Ett on 06/09/2019.
//  Copyright © 2019 Ghaff Ett. All rights reserved.
//

import SwiftUI
import Kingfisher

// MARK: - Collection View Coordinator
class Coordinator: NSObject, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
        
    var dataSource: UICollectionViewDiffableDataSource<Int, MovieImage>?
    
    // MARK: Collection Delegate
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let dataSource = self.dataSource else { return }
        guard let selectedMovieImage = dataSource.itemIdentifier(for: indexPath) else { return }
        
        ImageCache.default.retrieveImage(forKey: selectedMovieImage.filePath) { res in
            do {
                let img = try res.get().image
               
                DispatchQueue.main.async {
                    NotificationCenter.default.post(name: NSNotification.Name.DidSelectImage,
                                                    object: (img, CGFloat(selectedMovieImage.aspectRatio)))
                }
                
            } catch {
                debugPrint("Error getting cached image: \(error)")
            }
        }
    }
    
    // MARK: Collection Flow Delegate
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard let dataSource = self.dataSource else { return .zero }
        guard let selectedMovieImage = dataSource.itemIdentifier(for: indexPath) else { return .zero }
        
        var itemWidth: CGFloat {
            let _itemWidth = (collectionView.frame.width / 3) - 10
            return _itemWidth
        }
        
        return CGSize(width: itemWidth, height: itemWidth / CGFloat(selectedMovieImage.aspectRatio))
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
    }
}

// MARK: - Collection View
struct CollectionView: UIViewRepresentable {
    
    typealias UIViewType = UICollectionView
    
    let arr: [MovieImage]
    let images = [UIImage]()
    
    var urls = [URL]()
    
    init(data: [MovieImage]) {
        self.arr = data
        urls = data.compactMap { TMDBAPI.getMoviePosterUrl($0.filePath) }
    }
        
    func makeUIView(context: UIViewRepresentableContext<CollectionView>) -> UICollectionView {
        
        let coll = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        coll.register(MovieImageCell.self, forCellWithReuseIdentifier: "Cell")
        coll.backgroundColor = .systemBackground
        coll.delegate = context.coordinator
        
        let dataSource = UICollectionViewDiffableDataSource<Int, MovieImage>(collectionView: coll) { (collectionView, indexPath, movieImage)  in
            
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as? MovieImageCell else { return nil }
            
            let imageUrl = self.urls[indexPath.row]
            
            let resource = ImageResource(downloadURL: imageUrl, cacheKey: movieImage.filePath)
            cell.imageView.kf.setImage(with: resource, options: [.transition(.fade(0.9))])
            
            return cell
        }
        
        populate(dataSource: dataSource)
        context.coordinator.dataSource = dataSource
        
        return coll
    }
    
    func updateUIView(_ uiView: UICollectionView, context: UIViewRepresentableContext<CollectionView>) {
        guard let dataSource = context.coordinator.dataSource else { return }
        self.populate(dataSource: dataSource)
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    private func populate(dataSource: UICollectionViewDiffableDataSource<Int, MovieImage>) {
        var snapshot = NSDiffableDataSourceSnapshot<Int, MovieImage>()
        snapshot.appendSections([0])
        snapshot.appendItems(arr)
        dataSource.apply(snapshot, animatingDifferences: true)
    }
}



