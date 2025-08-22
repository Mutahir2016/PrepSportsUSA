//
//  TopLocationTableCell.swift
//  Lumen
//
//  Created by Syed Mutahir Pirzada on 06/01/2025.
//

import UIKit

class TopLocationTableCell: UITableViewCell {
    
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var detailLabel: UILabel!
    @IBOutlet var pgvsLabel: UILabel!
    
    @IBOutlet var separatorView: UIView!
    @IBOutlet var leadingConstraint: NSLayoutConstraint!
    @IBOutlet var trailingConstraint: NSLayoutConstraint!

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
    
    func configView(_ geography: GeographyData) {
        self.titleLabel.text = geography.attributes?.city
        
        if let pageviewsInt = Int(geography.attributes?.pageviews ?? "0") {
            let numberFormatter = NumberFormatter()
            numberFormatter.numberStyle = .decimal
            let formattedPageViews = numberFormatter.string(from: NSNumber(value: pageviewsInt)) ?? "0"
            self.detailLabel.text = formattedPageViews
        } else {
            self.detailLabel.text = "0" // Fallback in case of invalid number
        }
    }
    
    func configView(_ topOrganization: TopOrganizationsData) {
        self.titleLabel.text = topOrganization.attributes.name
        
        // Convert pageViews string to an integer
        if let pageviewsInt = Int(topOrganization.attributes.pageViews ?? "0") {
            let numberFormatter = NumberFormatter()
            numberFormatter.numberStyle = .decimal
            let formattedPageViews = numberFormatter.string(from: NSNumber(value: pageviewsInt)) ?? "0"
            self.detailLabel.text = formattedPageViews
        } else {
            self.detailLabel.text = "0" // Fallback for invalid values
        }
    }
    
    func configView(_ outboundClicks: OutlinkData) {
        pgvsLabel.isHidden = true
        self.titleLabel.text = outboundClicks.attributes.outlinkDomain
        
        // Convert pageViews string to an integer
        let pageviewsInt = outboundClicks.attributes.clicks ?? 0
            let numberFormatter = NumberFormatter()
            numberFormatter.numberStyle = .decimal
            let formattedPageViews = numberFormatter.string(from: NSNumber(value: pageviewsInt)) ?? "0"
            self.detailLabel.text = formattedPageViews
    }
}
