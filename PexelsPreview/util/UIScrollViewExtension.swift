//
//  UIScrollViewExtension.swift
//  PexelsPreview
//
//  Created by tatsuki on 2024/02/28.
//

import UIKit

extension UIScrollView {
    func isNearBottomEdge(edgeOffset: CGFloat = 0) -> Bool {
        return contentOffset.y + frame.size.height + edgeOffset > contentSize.height
    }
}
