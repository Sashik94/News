//
//  Persistance.swift
//  News
//
//  Created by Александр Осипов on 13.05.2020.
//  Copyright © 2020 Александр Осипов. All rights reserved.
//

import UIKit
import Foundation
import RealmSwift
import SDWebImage

class PersistanceRealm {
    static var shared = PersistanceRealm()
    private let realm = try! Realm()
    
    // MARK: - Source
    
    func searchSource(_ sources: Source) -> Bool {
        if realm.objects(SourceRealm.self).filter("id == '\(sources.id ?? "")'").first != nil {
            return true
        } else {
            return false
        }
    }
    
    func loadSources(_ sources: Source) {
        try! realm.write {
            let newSourceRealm = SourceRealm()
            newSourceRealm.id = sources.id!
            newSourceRealm.name = sources.name!
            newSourceRealm.descriptionSource = sources.description!
            newSourceRealm.country = sources.country!
            newSourceRealm.category = sources.category!
            newSourceRealm.url = sources.url!
            
            realm.add(newSourceRealm)
            
            realm.refresh()
        }
    }

    func downloadSources() -> [Source] {
        
        var sources: [Source] = []
        let sourcesRealm = realm.objects(SourceRealm.self).array
        
        for sourceRealm in sourcesRealm {
            var source = Source()
            source.id = sourceRealm.id
            source.name = sourceRealm.name
            source.description = sourceRealm.descriptionSource
            source.country = sourceRealm.country
            source.category = sourceRealm.category
            source.url = sourceRealm.url
            sources.append(source)
        }
        return sources
    }
    
    
    
    func deleteSource(_ source: Source) {
        let sourceRecord = realm.objects(SourceRealm.self).filter("id == '\(source.id ?? "")'").first
        let articlesInSource = realm.objects(ArticleRealm.self).filter("source.id == '\(source.id ?? "")'")
        try! realm.write {
            for article in articlesInSource {
                realm.delete(article, cascading: true)
            }
            realm.delete(sourceRecord!, cascading: true)
        }
    }
    
    // MARK: - Article
    
    func searchArticle(_ article: Article) -> Bool {
        
        if realm.objects(ArticleRealm.self).filter("url == '\(article.url ?? "")'").first != nil {
            return true
        } else {
            return false
        }
    }
    
    func loadArticle(_ article: Article) {
        try! realm.write {
            let newArticleRealm = ArticleRealm()
            newArticleRealm.title = article.title
            newArticleRealm.descriptionArticle = article.description
            newArticleRealm.url = article.url
            newArticleRealm.urlToImage = article.urlToImage
            newArticleRealm.publishedAt = article.publishedAt
            newArticleRealm.author = article.author
            newArticleRealm.content = article.content
            let newSourceInArticleRealm = SourceInArticleRealm()
            newSourceInArticleRealm.id = article.source.id ?? ""
            
            newArticleRealm.source = newSourceInArticleRealm
            
            realm.add(newArticleRealm)
            
            realm.refresh()
        }
    }
    
    func downloadArticle() -> [ArticleRealm] {
        
        return realm.objects(ArticleRealm.self).array
        
    }
    
    func deleteArticle(_ article: ArticleRealm) {
        let record = realm.objects(ArticleRealm.self).filter("source.id == '\(article.source?.id ?? "")'").first
        try! realm.write {
            realm.delete(record!)
        }
    }
    
    func deleteAll() {
        try! realm.write {
            realm.deleteAll()
        }
    }
}

extension Results {
    var array: [Element] {
        return self.count > 0 ? self.map { $0 } : []
    }
}

extension List {
    var array: [Element] {
        return self.count > 0 ? self.map { $0 } : []
    }
    
    func toArray<T>(ofType: T.Type) -> [T] {
            var array = [T]()
            for i in 0 ..< count {
                if let result = self[i] as? T {
                    array.append(result)
                }
            }
            return array
        }
}
