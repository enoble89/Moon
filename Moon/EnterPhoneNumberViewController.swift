//
//  EnterPhoneNumberViewController.swift
//  Moon
//
//  Created by Evan Noble on 6/15/17.
//  Copyright © 2017 Evan Noble. All rights reserved.
//

import UIKit
import Material
import RxCocoa
import RxSwift

class EnterPhoneNumberViewController: UIViewController, BindableType {

    var viewModel: EnterPhoneNumberViewModel!
    var navBackButton: UIBarButtonItem!
    private let bag = DisposeBag()
    
    @IBOutlet weak var changeCountryCodeButton: UIButton!
    @IBOutlet weak var phoneNumberTextField: TextField!
    @IBOutlet weak var sendCodeButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        prepareNavigationBackButton()
        prepareSendCodeButton()
        preparePhoneNumberTextField()
        prepareCountryCodeButton()
    }
    
    func bindViewModel() {
        navBackButton.rx.action = viewModel.onBack()
        
        changeCountryCodeButton.rx.action = viewModel.editCountryCode()
        sendCodeButton.rx.action = viewModel.onShowEnterCode()
        viewModel.enableEnterCode.bind(to: sendCodeButton.rx.isEnabled).addDisposableTo(bag)
        
        phoneNumberTextField.rx.textInput.text.orEmpty.bind(to: viewModel.phoneNumber).addDisposableTo(bag)
        viewModel.phoneNumberString.bind(to: phoneNumberTextField.rx.text).addDisposableTo(bag)
        
        viewModel.countryCode.asObservable().subscribe(onNext: { [weak self] code in
            let title = code.description
            self?.changeCountryCodeButton.setTitle(title, for: .normal)
        })
        .addDisposableTo(bag)
        
    }
    
    fileprivate func prepareNavigationBackButton() {
        navBackButton = UIBarButtonItem()
        navBackButton.image = Icon.cm.arrowBack
        navBackButton.tintColor = .lightGray
        self.navigationItem.leftBarButtonItem = navBackButton
    }
    
    fileprivate func preparePhoneNumberTextField() {
        phoneNumberTextField.placeholder = "Phone Number"
        phoneNumberTextField.isClearIconButtonEnabled = true
        phoneNumberTextField.placeholderActiveColor = .moonBlue
        phoneNumberTextField.dividerActiveColor = .moonBlue
        phoneNumberTextField.dividerNormalColor = .moonBlue
        phoneNumberTextField.placeholderNormalColor = .lightGray
    }
    
    fileprivate func prepareSendCodeButton() {
        sendCodeButton.backgroundColor = .moonGreen
        sendCodeButton.tintColor = .white
        sendCodeButton.layer.cornerRadius = 5
    }
    
    fileprivate func prepareCountryCodeButton() {
        changeCountryCodeButton.tintColor = .moonBlue
    }
}

extension Reactive where Base: UIButton {
    
}
