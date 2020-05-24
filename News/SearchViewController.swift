//
//  SearchViewController.swift
//  News
//
//  Created by Александр Осипов on 24.05.2020.
//  Copyright © 2020 Александр Осипов. All rights reserved.
//

import UIKit
import SDWebImage

protocol SearchViewControllerCellDelegate {
    func reloadCollectionView(url: String)
}

class SearchViewController: UIViewController {
    
    @IBOutlet weak var searchCollectionView: UICollectionView!
    
    
    var listArticles: [Article] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func searchTapGestureRecognizer(_ sender: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }
}

extension SearchViewController: SearchViewControllerCellDelegate {
    func reloadCollectionView(url: String) {
        NewsAPI.shared.fetchSearchTracksArticles(for: url) { (newsResponseJSON) in
            guard let newsResponseJSON = newsResponseJSON else { return }
            for news in newsResponseJSON.articles {
                self.listArticles.append(news)
            }
            self.listArticles = self.listArticles.sorted { $0.publishedAt! < $1.publishedAt! }
            DispatchQueue.main.async {
                self.searchCollectionView.reloadData()
            }
        }
        searchCollectionView.reloadData()
    }
}

extension SearchViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let headerView = collectionView.dequeueReusableSupplementaryView(
            ofKind: kind,
            withReuseIdentifier: "SearchCell",
            for: indexPath) as! SearchCollectionReusableView
        headerView.delegate = self
        return headerView
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return listArticles.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SearchArticlesCell", for: indexPath) as! SearchCollectionViewCell
        let track = listArticles[indexPath.row]
        
        cell.nameLabel.text = track.title
        cell.descriptionLabel.text = track.description
        if let urlToImage = track.urlToImage {
            cell.searchImageView.sd_setImage(with: URL(string: urlToImage), completed: .none)
        }
        cell.searchActivityIndicatorView.stopAnimating()
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView,
                            layout collectionViewLayout: UICollectionViewLayout,
                            sizeForItemAt indexPath: IndexPath) -> CGSize {
            let w = (collectionView.bounds.width)
            return CGSize(width: w, height: w * (9/16))
        }
    
}

class SearchCollectionReusableView: UICollectionReusableView {
    
    @IBOutlet weak var searchTextField: UITextField!
    var delegate: SearchViewControllerCellDelegate?
    
    @IBAction func searchButton(_ sender: UIButton) {
        if let searchText = searchTextField.text {
        delegate?.reloadCollectionView(url: searchText)
        }
    }
    
}

class SearchCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var searchActivityIndicatorView: UIActivityIndicatorView!
    @IBOutlet weak var searchImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    
}
