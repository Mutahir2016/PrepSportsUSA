//
//  OutBoundTableCell.swift
//  Lumen
//
//  Created by Syed Mutahir Pirzada on 06/01/2025.
//

import UIKit

class OutBoundTableCell: UITableViewCell {

    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var detailLabel: UILabel!
    @IBOutlet var separatorView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        titleLabel.font = UIFont.ibmMedium(size: 14.0)
        detailLabel.font = UIFont.ibmMedium(size: 16.0)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configView(_ outLinkData: OutlinkData) {
        self.titleLabel.text = outLinkData.attributes.outlinkDomain ?? ""
        let pageviewsInt = Int(outLinkData.attributes.clicks ?? 0)
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        let formattedPageViews = numberFormatter.string(from: NSNumber(value: pageviewsInt)) ?? "0"
        self.detailLabel.text = formattedPageViews
    }
}
