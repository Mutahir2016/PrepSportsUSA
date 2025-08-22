//
//  InfoCollectionViewCell.swift
//  Lumen
//
//  Created by Syed Mutahir Pirzada on 31/12/2024.
//

import UIKit

class InfoCollectionViewCell: UICollectionViewCell {

    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var iconView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}

struct InfoDataClass {
    let title: String
    let detail: String
    let subtitle: String
    let icon: String
    
    init(title: String, detail: String, subtitle: String, icon: String) {
        self.title = title
        self.detail = detail
        self.subtitle = subtitle
        self.icon = icon
    }
    
    
}
