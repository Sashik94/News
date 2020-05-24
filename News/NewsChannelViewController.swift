//
//  ViewController.swift
//  News
//
//  Created by Александр Осипов on 08.05.2020.
//  Copyright © 2020 Александр Осипов. All rights reserved.
//

import UIKit

class NewsChannelViewController: UIViewController {
    
    @IBOutlet weak var countrySegmentedControl: UISegmentedControl!
    @IBOutlet weak var newsChannelTableView: UITableView!
    
    var listNewsChannel: [Source] = []

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        loadSource()
    }
    
    func loadSource() {
        NewsAPI.shared.fetchTracksSource(for: countrySegmentedControl.titleForSegment(at: countrySegmentedControl.selectedSegmentIndex)!) { (sourcesResponseJSON) in
            guard let sourcesResponseJSON = sourcesResponseJSON else { return }
            var newSources: [Source] = []
            for source in sourcesResponseJSON.sources {
                newSources.append(source)
            }
            self.listNewsChannel = newSources
            DispatchQueue.main.async {
                self.newsChannelTableView.reloadData()
            }
        }
    }
    
    @IBAction func changeCountry(_ sender: UISegmentedControl) {
        loadSource()
    }

}

extension NewsChannelViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listNewsChannel.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NewsChannelCell", for: indexPath) as! NewsChannelTableViewCell
        let track = listNewsChannel[indexPath.row]
        cell.newsChannelImageView.image = UIImage(named: track.id!)
        cell.newsChannelNameLabel.text = track.name
        cell.newsChanneldescriptionLabel.text = track.description
        if PersistanceRealm.shared.searchSource(track) {
            cell.favoriteButton.setImage(UIImage(named: "Filling Star"), for: .normal)
        } else {
            cell.favoriteButton.setImage(UIImage(named: "Empty Star"), for: .normal)
        }
        
        cell.newsChannel = track
        return cell
    }
    
}


class NewsChannelTableViewCell: UITableViewCell {
    
    @IBOutlet weak var newsChannelImageView: UIImageView!
    @IBOutlet weak var newsChannelNameLabel: UILabel!
    @IBOutlet weak var newsChanneldescriptionLabel: UILabel!
    @IBOutlet weak var favoriteButton: UIButton!
    
    var newsChannel: Source!
    
    @IBAction func changeFavoriteStatus(_ sender: UIButton) {
        if PersistanceRealm.shared.searchSource(newsChannel) {
            PersistanceRealm.shared.deleteSource(newsChannel)
            favoriteButton.setImage(UIImage(named: "Empty Star"), for: .normal)
        } else {
            PersistanceRealm.shared.loadSources(newsChannel)
            favoriteButton.setImage(UIImage(named: "Filling Star"), for: .normal)
        }
    }
}
