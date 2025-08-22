//
//  StoriesTableViewCell.swift
//  Lumen
//
//  Created by Syed Mutahir Pirzada on 12/01/2025.
//

import UIKit

class StoriesTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    @IBOutlet weak var pageViewLabel: UILabel!
    @IBOutlet weak var placeNameLabel: UILabel!
    @IBOutlet weak var leadingConstraint: NSLayoutConstraint!
    var shouldSetLeading: Bool = false
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
        // Initialization code
    }
    
    private func setupUI() {
        titleLabel.font = UIFont.ibmBold(size: 14.0)
        dateLabel.font = UIFont.ibmRegular(size: 10.0)
        pageViewLabel.font = UIFont.ibmSemiBold(size: 22.0)
        placeNameLabel.font = UIFont.ibmRegular(size: 10.0)
    }
    
    func configViewWith(_ data: Story) {
        if shouldSetLeading {
            leadingConstraint.constant = 0
        }
        self.titleLabel.text = data.attributes.headline
          let numberFormatter = NumberFormatter()
          numberFormatter.numberStyle = .decimal
          let pageViews = numberFormatter.string(from: NSNumber(value: data.attributes.pageviews ?? 0)) ?? "0"
        self.pageViewLabel.text = pageViews
        self.placeNameLabel.isHidden = true
        
        let formattedDate = data.attributes.publishedAt?.formatted(dateFormat: "MMM dd, YYYY") ?? ""
        let project = data.attributes.project ?? ""
        if !project.isEmpty {
            self.dateLabel.text = "\(formattedDate) | \(project)"
        } else {
            self.dateLabel.text = formattedDate
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

extension StoriesTableViewCell {
    static func nib() -> UINib {
        UINib.init(nibName: "StoriesTableViewCell", bundle: Bundle(for: StoriesTableViewCell.self))
    }
}
