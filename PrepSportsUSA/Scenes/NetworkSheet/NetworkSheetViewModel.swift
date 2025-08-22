//
//  NetworkSheetViewModel.swift
//  Lumen
//
//  Created by Syed Mutahir Pirzada on 27/04/2025.
//

import Foundation
import RxSwift
import RxCocoa
import UIKit

protocol NetworkSheetViewModelDelegate: AnyObject {
    func networkSheet(_ controller: UIViewController, didSelectNetwork network: NetworkDatum)
    func projectSheet(_ controller: UIViewController, didSelectProject project: NetworkDatum, projectArr: [NetworkDatum])
}

class NetworkSheetViewModel: BaseViewModel {
    
    var useCase: NetworkUseCase?
    var networkRelay = BehaviorRelay<[NetworkDatum]?>(value: nil)
    weak var delegate: NetworkSheetViewModelDelegate?

    init(useCase: NetworkUseCase = NetworkUseCase(), networkList: [NetworkDatum]?, delegate: StoriesHomeViewModelDelegate? = nil) {
        super.init()
        self.networkRelay.accept(networkList)
        self.useCase = useCase
    }
}
