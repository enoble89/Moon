//
//  PasswordsViewModel.swift
//  Moon
//
//  Created by Evan Noble on 5/31/17.
//  Copyright © 2017 Evan Noble. All rights reserved.
//

import Foundation
import RxSwift
import Action
import FirebaseAuth
import FirebaseStorage

struct PasswordsViewModel: NetworkingInjected, AuthNetworkingInjected, StorageNetworkingInjected {
    
    // Dependencies
    private let newUser: NewUser
    private let sceneCoordinator: SceneCoordinatorType
    private let disposeBag = DisposeBag()
    
    // Inputs
    var passwordText = BehaviorSubject<String>(value: "")
    var retypePasswordText = BehaviorSubject<String>(value: "")
    
    // Outputs
    var showPasswordsMatchError: Observable<Bool> {
        let passwordsMatch = Observable.combineLatest(passwordText, retypePasswordText).map(==)
        return Observable.combineLatest(passwordsMatch, retypePasswordText).map({
            return !$0 && $1 != ""
        })
    }
    var showAcceptablePasswordError: Observable<Bool> {
        let validPassword = passwordText.map(ValidationUtility.validPassword)
        return Observable.combineLatest(validPassword, passwordText).map({
            return !$0 && $1 != ""
        })
    }
    var allValid: Observable<Bool> {
        return Observable.combineLatest(passwordText, retypePasswordText)
            .map({ (password1, password2) in
                return ValidationUtility.validPassword(password: password1) && password1 == password2
            })
    }
    
    var showLoadingIndicator = Variable(false)
    
    func createUser() -> CocoaAction {
        return CocoaAction(enabledIf: self.allValid, workFactory: {_ in
            return self.authAPI.createAccount(newUser: self.newUser)
                .flatMap({
                    return self.authAPI.login(credentials: .email(credentials: EmailCredentials(email:self.newUser.email!, password: self.newUser.password!)))
                })
                .flatMap({ id -> Observable<Void> in
                    if let photoData = self.newUser.image {
                        return self.storageAPI.uploadProfilePictureFrom(data: photoData, forUser: id)
                    } else {
                        return Observable.just()
                    }
                })
                .flatMap({
                    return self.loginAction()
                })
        })
    }

    func loginAction() -> Observable<Void> {
        let mainVM = MainViewModel(coordinator: self.sceneCoordinator)
        let searchVM = SearchBarViewModel(coordinator: self.sceneCoordinator)
        return self.sceneCoordinator.transition(to: Scene.Master.searchBarWithMain(searchBar: searchVM, mainView: mainVM), type: .root)
    }
    
    init(coordinator: SceneCoordinatorType, user: NewUser) {
        self.sceneCoordinator = coordinator
        self.newUser = user
        subscribeToInputs()
    }
    
    private func subscribeToInputs() {
        passwordText
            .subscribe(onNext: {
                self.newUser.password = $0
            })
            .addDisposableTo(disposeBag)
    }
    
    func onBack() -> CocoaAction {
        return CocoaAction {
            self.sceneCoordinator.pop()
        }
    }
}
