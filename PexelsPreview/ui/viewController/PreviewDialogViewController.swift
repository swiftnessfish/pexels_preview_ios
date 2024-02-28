//
//  PreviewDialogViewController.swift
//  PexelsPreview
//
//  Created by tatsuki on 2024/02/27.
//

import Foundation
import UIKit

class PreviewDialogViewController: UIViewController {
    
    @IBOutlet weak var thumbnail: UIImageView!
    
    @IBOutlet weak var photographer: UILabel!
    
    var url: URL? = nil
    var photographerName: String? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        thumbnail.load(url: url!)
        photographer.text = photographerName
    }


}
