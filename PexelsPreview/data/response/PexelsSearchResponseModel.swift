//
//  PexelsSearchResponseModel.swift
//  PexelsPreview
//
//  Created by tatsuki on 2024/02/27.
//

import Foundation

struct PexelsSearchResponseModel: Codable {
    let photos: [Photos]
    
    struct Photos: Codable {
        let src: Src
        let photographer: String
    }
    
    struct Src: Codable {
        let medium: URL
        let small: URL
    }
}
