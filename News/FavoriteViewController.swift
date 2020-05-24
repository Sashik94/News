//
//  FavoriteViewController.swift
//  News
//
//  Created by Александр Осипов on 13.05.2020.
//  Copyright © 2020 Александр Осипов. All rights reserved.
//

import UIKit

class FavoriteViewController: UIViewController {
    
    @IBOutlet weak var favoriteChannelTableView: UITableView!
    
    var listFavoriteChannel: [Source] = []
    var stringStackSource: String!
    var listArticles: [Article] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        listFavoriteChannel = PersistanceRealm.shared.downloadSources()
        favoriteChannelTableView.reloadData()
    }
}

extension FavoriteViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listFavoriteChannel.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FavoriteChannelCell", for: indexPath) as! FavoriteTableViewCell
        cell.delegate = self
        let track = listFavoriteChannel[indexPath.row]
        cell.favoriteChannelImageView.image = UIImage(named: track.id!)
        cell.favoriteChannelNameLabel.text = track.name
        cell.favoriteChannelDescriptionLabel.text = track.description
        let starButton = UIButton()
        starButton.setTitle(String(indexPath.row), for: .normal)
        starButton.setImage(UIImage(named: "Filling Star"), for: .normal)
        cell.favoriteButton = starButton
        cell.newsChannel = track
        return cell
    }
    
}

extension FavoriteViewController: FavoriteTableViewCellDelegate {
    func reloadTabelView() {
        listFavoriteChannel = PersistanceRealm.shared.downloadSources()
        favoriteChannelTableView.reloadData()
    }
}

protocol FavoriteTableViewCellDelegate {
    func reloadTabelView()
}

class FavoriteTableViewCell: UITableViewCell {
    
    @IBOutlet weak var favoriteChannelImageView: UIImageView!
    @IBOutlet weak var favoriteChannelNameLabel: UILabel!
    @IBOutlet weak var favoriteChannelDescriptionLabel: UILabel!
    @IBOutlet weak var favoriteButton: UIButton!
    
    var newsChannel: Source!
    
    var delegate: FavoriteTableViewCellDelegate?
    
    @IBAction func changeFavoriteStatus(_ sender: UIButton) {
        if PersistanceRealm.shared.searchSource(newsChannel) {
            PersistanceRealm.shared.deleteSource(newsChannel)
            delegate?.reloadTabelView()
        }
    }
    
}
