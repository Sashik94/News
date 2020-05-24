//
//  AllArticlesViewController.swift
//  News
//
//  Created by Александр Осипов on 19.05.2020.
//  Copyright © 2020 Александр Осипов. All rights reserved.
//

import UIKit
import SDWebImage

class AllArticlesViewController: UIViewController {
    
    var stringStackSource: String!
    var listFavoriteChannel: [Source] = []
    var listArticles: [Article] = []
    private var itemSize: CGSize?
    var listArticlesRealm: [ArticleRealm] = []
    @IBOutlet weak var articlesCollectionView: UICollectionView!
    var reload: Bool!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        reload = false
        listFavoriteChannel = PersistanceRealm.shared.downloadSources()
        if !listFavoriteChannel.isEmpty {
            stackSource()
            loadArticles()
        }
    }
    
    func stackSource() {
        stringStackSource = ""
        for (index, newsChannel) in listFavoriteChannel.enumerated() {
            let endSymbol = listFavoriteChannel.count - 1 != index ? "," : ""
            stringStackSource += newsChannel.id! + endSymbol
        }
    }
    
    func loadArticles() {
        for newsChannel in listFavoriteChannel {
            NewsAPI.shared.fetchTracksArticles(for: newsChannel.id!) { (newsResponseJSON) in
                guard let newsResponseJSON = newsResponseJSON else { return }
                for news in newsResponseJSON.articles {
                    self.listArticles.append(news)
                }
                self.reload = true
                self.listArticles = self.listArticles.sorted { $0.publishedAt! < $1.publishedAt! }
                DispatchQueue.main.async {
                    self.articlesCollectionView.reloadData()
                }
            }
        }
    }
}

extension AllArticlesViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return listArticles.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ArticlesCell", for: indexPath) as! AllArticlesCollectionCell
        if cell.nameLabel.text != nil {
            let track = listArticles[indexPath.row]

            cell.nameLabel.text = track.title
            cell.descriptionLabel.text = track.description
            if let urlToImage = track.urlToImage {
                cell.articlesImageView.sd_setImage(with: URL(string: urlToImage), completed: .none)
            }
            
            cell.activityIndicator.stopAnimating()
        }
        return cell
    }
    
    private func updateCollectionViewLayout(with size: CGSize) {
        if let layout = articlesCollectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.itemSize = size
            layout.invalidateLayout()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let w = (collectionView.bounds.width)
        return CGSize(width: w, height: w * (9/16))
    }
}

class AllArticlesCollectionCell: UICollectionViewCell {
    
    @IBOutlet weak var articlesImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
}
