//
//  SheetTableCell.swift
//  Lumen
//
//  Created by Syed Mutahir Pirzada on 27/04/2025.
//

import UIKit

class SheetTableCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        titleLabel.font = UIFont.ibmRegular(size: 14.0)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

extension SheetTableCell {
    static func nib() -> UINib {
        UINib.init(nibName: "SheetTableCell", bundle: Bundle(for: SheetTableCell.self))
    }
}
