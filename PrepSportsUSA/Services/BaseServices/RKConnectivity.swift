//
//  Connectivity.swift
//

import Foundation
import Alamofire

class RKConnectivity {
    class func isConnectedToInternet() -> Bool {
        return NetworkReachabilityManager()!.isReachable
    }
}
