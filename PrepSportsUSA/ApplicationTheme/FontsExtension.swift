//
//  FontsExtension.swift
//  Lumen
//
//  Created by Syed Mutahir Pirzada on 23/12/2024.
//

import UIKit

extension UIFont {
    
    class func ibmRegular(size: CGFloat) -> UIFont {
        return UIFont(name: "IBMPlexSans-Regular", size: size)!
    }
    
    class func ibmMedium(size: CGFloat) -> UIFont {
        return UIFont(name: "IBMPlexSans-Medium", size: size)!
    }
    
    class func ibmSemiBold(size: CGFloat) -> UIFont {
        return UIFont(name: "IBMPlexSans-SemiBold", size: size)!
    }
    
    class func ibmBold(size: CGFloat) -> UIFont {
        return UIFont(name: "IBMPlexSans-Bold", size: size)!
    }
}
