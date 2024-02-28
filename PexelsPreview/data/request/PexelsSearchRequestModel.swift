//
//  PexelsSearchRequestModel.swift
//  PexelsPreview
//
//  Created by tatsuki on 2024/02/27.
//

import Foundation

struct PexelsSearchRequestModel: Codable {
    let query: String
    let locale: String
    let page: Int
    let perPage: Int
}
