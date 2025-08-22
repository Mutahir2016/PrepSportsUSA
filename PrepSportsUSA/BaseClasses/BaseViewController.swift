//
//  BaseViewController.swift
//  Lumen
//
//  Created by Syed Mutahir Pirzada on 23/12/2024.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa

enum PrepSportsUSARouting: String {
    case signIn = "Signin"
    case forgotPassword = "ForgotPassword"
    case authVerification = "AuthVerification"
    case home = "Home"
    case storiesHome = "StoriesHome"
    case stories = "Stories"
    case more = "More"
    case topLoc = "TopLoc"
    case topOrg = "TopOrg"
    case outbound = "Outbound"
    case map = "Map"
    case network = "Network"
    case projectSheet = "ProjectSheet"
    case networkSheet = "NetworkSheet"
    case search = "Search"
    case projectStories = "ProjectStories"
    case sports = "Sports"
}

class BaseViewController: UIViewController {

  var window: UIWindow? {
       guard let scene = UIApplication.shared.connectedScenes.first,
             let windowScene = scene as? UIWindowScene else {
           return nil
       }
       return .init(windowScene: windowScene)
   }

  var timer = Timer()
  var disposeBag = DisposeBag()
  var modalView: UIViewController?
    var dismissViewTranslation = CGPoint(x: 0, y: 0)
    var baseGestureView: UIView?
  required init?(coder: NSCoder) {
    super.init(coder: coder)
    setUp()
  }
  
  override init(nibName nibNameOrNil: String?,
                bundle nibBundleOrNil: Bundle?) {
    super.init(nibName: nibNameOrNil,
               bundle: nibBundleOrNil)
    setUp()
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    callingInsideViewDidLoad()
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    timer.invalidate()
  }

  func setUp() {
    fatalError("must override setup() function")
  }
  
  func callingInsideViewDidLoad() {
    fatalError("must override setup() function")
  }
}

// MARK: extension modal view
extension BaseViewController {

    func formatPageView(_ pageView: Int) -> String {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        return numberFormatter.string(from: NSNumber(value: pageView)) ?? "0"
    }
    
    func getFormattedTime(_ seconds: Double) -> String {
        let hours = Int(seconds) / 3600
        let minutes = (Int(seconds) % 3600) / 60
        let secs = Int(seconds) % 60
        return String(format: "%02d:%02d:%02d", hours, minutes, secs)
    }
    
  func showModal() {
    guard let modal = modalView else { return }
    let tapBaseView = UITapGestureRecognizer(target: modal,
                                  action: #selector(didTapView(_:)))
    self.view.addGestureRecognizer(tapBaseView)
    present(modal, animated: true)
  }

  @objc func didTapView(_ sender: UITapGestureRecognizer) {
      print(" should modal view dismiss")
  }
}
// MARK: - extension navigation bar
extension BaseViewController {

  func customNavigationBar() {
    let leftBarBtn = UIButton()
    leftBarBtn.setImage(UIImage(named: "home_rikstoto_navigation_item"), for: .normal)
    leftBarBtn.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
    leftBarBtn.addTarget(self, action: #selector(actionBackButton), for: .touchUpInside)
    self.navigationItem.leftBarButtonItem = UIBarButtonItem.init(customView: leftBarBtn)
    self.navigationItem.setHidesBackButton(false, animated: true)
    self.navigationController?.navigationBar.barStyle = .black
    showNavigationBar(true)
  }

  @objc func actionBackButton() {
    // perform rikstoto bar button
  }

  func showNavigationBar(_ show: Bool) {
    guard let nav = self.navigationController else { return }
    nav.navigationBar.barStyle = .black
    nav.setNavigationBarHidden(!show, animated: false)
  }
}

extension BaseViewController {
    
    func setTransformForPopupView() {
        // starting hidden -> showing
        guard let dismissView = baseGestureView else { return }

        dismissView.transform = CGAffineTransformMakeTranslation(0, dismissView.bounds.height)
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.1) {
            UIView.animate(withDuration: 0.25, delay: 0) {
                dismissView.transform = .identity
            }
        }
    }
    
    @objc func handleGestureDismiss(sender: UIPanGestureRecognizer) {
        guard let dismissView = baseGestureView else { return }
        switch sender.state {
        case .changed:
            dismissViewTranslation = sender.translation(in: view)
            if dismissViewTranslation.y > 0 {
                UIView.animate(withDuration: 0.5, delay: 0,
                               usingSpringWithDamping: 0.7,
                               initialSpringVelocity: 1,
                               options: .curveEaseOut,
                               animations: {
                    dismissView.transform = CGAffineTransform(translationX: 0, y: self.dismissViewTranslation.y)
                })
            }
        case .ended:
            if sender.velocity(in: view).y > 500 || dismissViewTranslation.y > dismissView.bounds.height * 0.5 {
                dismiss(animated: true)
            } else {
                UIView.animate(withDuration: 0.5,
                               delay: 0, usingSpringWithDamping: 0.7,
                               initialSpringVelocity: 1, options: .curveEaseOut,
                               animations: {
                    dismissView.transform = .identity
                })
            }
        default:
            break
        }
    }
    
    @objc func handleTap(sender: UITapGestureRecognizer) {
        dismiss(animated: true)
    }
    
    func displayFormateDate(fromDate: Date, toDate: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM dd, yyyy"
        return dateFormatter.string(from: fromDate) + " - " + dateFormatter.string(from: toDate)
    }
}
