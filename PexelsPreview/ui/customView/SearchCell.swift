//
//  SearchCell.swift
//  PexelsPreview
//
//  Created by tatsuki on 2024/02/27.
//

import UIKit

class SearchCell: UICollectionViewCell {

    @IBOutlet weak var thumbnail: UIImageView!
    
    @IBOutlet weak var photographer: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func setData(thumbnailUrl: URL, photographerName: String) {
        thumbnail.load(url: thumbnailUrl)
        photographer.text = photographerName
    }
}
