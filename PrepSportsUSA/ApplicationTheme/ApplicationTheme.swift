//
//  ApplicationTheme.swift
//  Lumen
//
//  Created by Syed Mutahir Pirzada on 26/11/2024.
//
import UIKit

extension UIFont {
    class var h1: UIFont {
        return UIFont(name: "Helvetica-Medium", size: 26.0)!
    }
}

extension UIColor {
    class var appErrorRedColor: UIColor {
        return UIColor(red: 179/155, green: 38/255, blue: 30/255, alpha: 1)
    }
    
    class var outLineColor: UIColor {
        return UIColor(red: 30/255, green: 33/255, blue: 38/255, alpha: 1)
    }
    
    class var appBlueColor: UIColor {
        return UIColor(red: 0/255, green: 122/255, blue: 255/255, alpha: 1)
    }
    
    class var appBtnBlueColor: UIColor {
        return UIColor(red: 55/255, green: 141/255, blue: 255/255, alpha: 1)
    }
    
    class var appBtnDisabledColor: UIColor {
        return UIColor(red: 29/255, green: 27/255, blue: 32/255, alpha: 0.12)
    }
    
    class var appBtnDisabledTitleColor: UIColor {
        return UIColor(red: 29/255, green: 27/255, blue: 32/255, alpha: 0.38)
    }
    
    class var tabBarUnSelectedColor: UIColor {
        return UIColor(red: 106/255, green: 106/255, blue: 106/255, alpha: 0.38)
    }
    
    class var tabBarSelectedColor: UIColor {
        return UIColor(red: 95/255, green: 164/255, blue: 255/255, alpha: 1)
    }
    
    class var appGrayColor: UIColor {
        return UIColor(red: 117/255, green: 117/255, blue: 117/255, alpha: 1)
    }
    
    class var appOrangeColor: UIColor {
        return UIColor(red: 255/255, green: 174/255, blue: 52/255, alpha: 1)
    }
}
