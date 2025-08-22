//
//  CustomSearchBar.swift
//  Lumen
//
//  Created by Assistant on 24/12/2024.
//

import UIKit
import RxSwift
import RxCocoa

protocol CustomSearchBarDelegate: AnyObject {
    func customSearchBar(_ searchBar: CustomSearchBar, didSearchWith text: String)
}

class CustomSearchBar: UIView {
    
    // MARK: - IBOutlets
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var searchIconImageView: UIImageView!
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var searchButton: UIButton!
    
    // MARK: - Properties
    weak var delegate: CustomSearchBarDelegate?
    private let disposeBag = DisposeBag()
    
    // MARK: - Reactive Properties
    var searchButtonTapped: Observable<String> {
        return searchButton.rx.tap
            .map { [weak self] in
                return self?.searchTextField.text ?? ""
            }
    }
    
    var textFieldText: Observable<String> {
        return searchTextField.rx.text.orEmpty.asObservable()
    }
    
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    // MARK: - Setup
    private func setupView() {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: "CustomSearchBar", bundle: bundle)
        guard let view = nib.instantiate(withOwner: self, options: nil).first as? UIView else { return }
        
        view.frame = bounds
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(view)
        
        setupUI()
        setupBindings()
    }
    
    private func setupUI() {
        // Container view styling
        containerView.backgroundColor = UIColor.systemGray6
        containerView.layer.cornerRadius = 12
        containerView.layer.masksToBounds = true
        
        // Search icon
        searchIconImageView.image = UIImage(systemName: "magnifyingglass")
        searchIconImageView.tintColor = UIColor.systemGray
        
        // Text field styling
        searchTextField.placeholder = "Search a story"
        searchTextField.borderStyle = .none
        searchTextField.backgroundColor = UIColor.clear
        searchTextField.font = UIFont.systemFont(ofSize: 16)
        searchTextField.textColor = UIColor.label
        searchTextField.returnKeyType = .search
        
        // Search button (arrow)
        searchButton.setImage(UIImage(systemName: "arrow.right"), for: .normal)
        searchButton.tintColor = UIColor.systemGray
        searchButton.backgroundColor = UIColor.clear
    }
    
    private func setupBindings() {
        // Handle search button tap
        searchButton.rx.tap
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                let searchText = self.searchTextField.text ?? ""
                self.delegate?.customSearchBar(self, didSearchWith: searchText)
                self.searchTextField.resignFirstResponder()
            })
            .disposed(by: disposeBag)
        
        // Handle return key press
        searchTextField.rx.controlEvent(.editingDidEndOnExit)
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                let searchText = self.searchTextField.text ?? ""
                self.delegate?.customSearchBar(self, didSearchWith: searchText)
                self.searchTextField.resignFirstResponder()
            })
            .disposed(by: disposeBag)
    }
    
    // MARK: - Public Methods
    func setText(_ text: String) {
        searchTextField.text = text
    }
    
    func getText() -> String {
        return searchTextField.text ?? ""
    }
    
    func clearText() {
        searchTextField.text = ""
    }
} 
