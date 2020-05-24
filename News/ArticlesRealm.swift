//
//  ArticlesRealm.swift
//  News
//
//  Created by Александр Осипов on 13.05.2020.
//  Copyright © 2020 Александр Осипов. All rights reserved.
//

import Foundation
import RealmSwift

class NewsResponseRealm: Object {
    @objc dynamic var status: String = ""
    @objc dynamic var totalResults: Int = 0
    var articles = List<ArticleRealm>()
}

class ArticleRealm: Object {
    @objc dynamic var title: String? = ""
    @objc dynamic var descriptionArticle: String? = ""
    @objc dynamic var author: String? = ""
    @objc dynamic var url: String? = ""
    @objc dynamic var urlToImage: String? = ""
    @objc dynamic var publishedAt: String? = ""
    @objc dynamic var content: String? = ""
    @objc dynamic var source: SourceInArticleRealm? = nil
}

class SourceInArticleRealm: Object {
    @objc dynamic var id: String = ""
}

class SourcesResponseRealm: Object {
    @objc dynamic var status: String = ""
    var sources = List<SourceRealm>()
}

class SourceRealm: Object {
    @objc dynamic var id: String = ""
    @objc dynamic var name: String = ""
    @objc dynamic var descriptionSource: String = ""
    @objc dynamic var country: String = ""
    @objc dynamic var category: String = ""
    @objc dynamic var url: String = ""
}
