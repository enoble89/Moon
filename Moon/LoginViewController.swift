//
//  ViewController.swift
//  Moon
//
//  Created by Evan Noble on 4/16/17.
//  Copyright © 2017 Evan Noble. All rights reserved.
//

import UIKit
import Material
import RxCocoa
import RxSwift
import SwiftOverlays

class LoginViewController: UIViewController, BindableType {
    
    var viewModel: LoginViewModel!
    private let disposeBag = DisposeBag()

    @IBOutlet weak var emailTextField: TextField!
    @IBOutlet weak var passwordTextField: TextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var emailIcon: UIImageView!
    @IBOutlet weak var keyIcon: UIImageView!
    @IBOutlet weak var orIcon: UIImageView!
    @IBOutlet weak var recoverButton: UIButton!
    
    @IBOutlet weak var googleSignInButton: UIButton!
    @IBOutlet weak var facebookSignInButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view, typically from a nib.
        setUpLoginView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
          navigationController?.navigationBar.isHidden = true
         UIApplication.shared.statusBarStyle = UIStatusBarStyle.lightContent
        googleSignInButton.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.navigationBar.isHidden = false
        UIApplication.shared.statusBarStyle = UIStatusBarStyle.lightContent
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func setUpLoginView() {
        
        //Email Text Field Set Up
        emailTextField.dividerNormalColor = .moonBlue
        emailTextField.dividerActiveColor = .moonBlue
        emailTextField.placeholder = "email"
        emailTextField.placeholderActiveColor = .moonBlue
        emailTextField.placeholderNormalColor = .lightGray
        emailTextField.textColor = .black
        
        //Password Text Field Set Up
        passwordTextField.dividerNormalColor = .moonBlue
        passwordTextField.dividerActiveColor = .moonBlue
        passwordTextField.placeholder = "password"
        passwordTextField.placeholderActiveColor = .moonBlue
        passwordTextField.placeholderNormalColor = .lightGray
        passwordTextField.isSecureTextEntry = true
        passwordTextField.textColor = .black
        
        //Login Button Set Up
        loginButton.backgroundColor = .moonBlue
        loginButton.setTitleColor(.white, for: .normal)
        loginButton.layer.cornerRadius = 5
        
        //Sign Up Button Set Up
        signUpButton.backgroundColor = .moonGreen
        signUpButton.setTitleColor(.white, for: .normal)
        signUpButton.layer.cornerRadius = 5
        
        //Recover Button Set Up
        recoverButton.setTitleColor(.moonPurple, for: .normal)
        
        emailIcon.image = emailIcon.image?.withRenderingMode(.alwaysTemplate)
        emailIcon.tintColor = .moonBlue
        
        keyIcon.image = keyIcon.image?.withRenderingMode(.alwaysTemplate)
        keyIcon.tintColor = .moonBlue
        
        orIcon.image = orIcon.image?.withRenderingMode(.alwaysTemplate)
        orIcon.tintColor = .lightGray

    }
    
    func bindViewModel() {
        signUpButton.rx.action = viewModel.onSignUp()
        
        recoverButton.rx.action = viewModel.onForgotPassword()
        
        let fbSignInAction = viewModel.onFacebookSignIn()
        facebookSignInButton.rx.action = fbSignInAction
        viewModel.showLoadingIndicator.asObservable().subscribe(onNext: {
            if $0 {
                SwiftOverlays.showBlockingWaitOverlayWithText("Signing In")
            } else {
                SwiftOverlays.removeAllBlockingOverlays()
            }
        }).addDisposableTo(disposeBag)
        
        fbSignInAction.errors.subscribe(onNext: { [weak self] actionError in
                if case let .underlyingError(error) = actionError {
                    self?.showErrorAlert(message: (error as NSError).localizedDescription)
                }
            }).addDisposableTo(disposeBag)
        
        let signInAction = viewModel.onSignIn()
        loginButton.rx.action = signInAction
        signInAction.executing.do(onNext: {
            if $0 {
                SwiftOverlays.showBlockingWaitOverlayWithText("Signing In")
            } else {
                SwiftOverlays.removeAllBlockingOverlays()
            }
        }).subscribe().addDisposableTo(disposeBag)
        
        signInAction.errors.subscribe(onNext: { [weak self] actionError in
            if case let .underlyingError(error) = actionError {
                self?.showErrorAlert(message: (error as NSError).localizedDescription)
            }
        }).addDisposableTo(disposeBag)
        
        emailTextField.rx.textInput.text.bind(to: viewModel.email).addDisposableTo(disposeBag)
        passwordTextField.rx.textInput.text.bind(to: viewModel.password).addDisposableTo(disposeBag)
    }
}
