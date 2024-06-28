//
//  Model.swift
//  PaginationDemo
//
//  Created by Arpit iOS Dev. on 28/06/24.
//

// MARK: - Welcome
struct Welcome: Codable {
    let count, totalCount, page, totalPages: Int
    let lastItemIndex: Int?
    let results: [QuoteResult]
}

// MARK: - QuoteResult
struct QuoteResult: Codable {
    let id: String
    let author: String
    let content: String
    let tags: [String]
    let authorSlug: String
    let length: Int
    let dateAdded, dateModified: String

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case author, content, tags, authorSlug, length, dateAdded, dateModified
    }
}
