//
//  UIView+Nib.swift
//  PrepSportsUSA
//
//  Created by PrepSportsUSA on 25/08/2025.
//

import UIKit

extension UIView {
    static func fromNib<T: UIView>() -> T? {
        let bundle = Bundle(for: T.self)
        let nib = UINib(nibName: String(describing: T.self), bundle: bundle)
        return nib.instantiate(withOwner: nil, options: nil).first as? T
    }
}
