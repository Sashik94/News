//
//  Articles.swift
//  News
//
//  Created by Александр Осипов on 08.05.2020.
//  Copyright © 2020 Александр Осипов. All rights reserved.
//

import Foundation

struct NewsResponse: Codable {
    var status: String?
    var totalResults: Int?
    var articles: [Article]
}

struct Article: Codable {
    var title: String?
    var description: String?
    var author: String?
    var url: String?
    var urlToImage: String?
    var publishedAt: String?
    var content: String?
    var source: Source
}

struct SourcesResponse: Codable {
    var status: String
    var sources: [Source]
}

struct Source: Codable {
    var id: String?
    var name: String?
    var description: String?
    var country: String?
    var category: String?
    var url: String?
}
