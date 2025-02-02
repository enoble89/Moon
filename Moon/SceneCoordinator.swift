//
//  SceneCoordinator.swift
//  Moon
//
//  Created by Evan Noble on 6/1/17.
//  Copyright © 2017 Evan Noble. All rights reserved.
//

import UIKit
import EZSwipeController
import RxSwift
import RxCocoa

class SceneCoordinator: SceneCoordinatorType {
    
    fileprivate var window: UIWindow
    fileprivate var currentViewController: UIViewController!
    
    required init(window: UIWindow) {
        self.window = window
    }
    
    static func actualViewController(for viewController: UIViewController) -> UIViewController {
        if let navigationController = viewController as? UINavigationController {
            return navigationController.viewControllers.first!
        } else {
            return viewController
        }
    }
    
    @discardableResult
    func transition(to scene: SceneType, type: SceneTransitionType) -> Observable<Void> {
        let subject = PublishSubject<Void>()
        let viewController = scene.viewController()
        switch type {
        case .root:
            currentViewController = SceneCoordinator.actualViewController(for: viewController)
            window.replaceRootViewControllerWith(viewController, animated: true, completion: nil)
            subject.onCompleted()
            
        case .push:
            guard let navigationController = currentViewController.navigationController else {
                fatalError("Can't push a view controller without a current navigation controller")
            }
            // one-off subscription to be notified when push complete
            _ = navigationController.rx.delegate
                .sentMessage(#selector(UINavigationControllerDelegate.navigationController(_:didShow:animated:)))
                .map { _ in }
                .bind(to: subject)
            navigationController.pushViewController(viewController, animated: true)
            currentViewController = SceneCoordinator.actualViewController(for: viewController)
            
        case .modal:
            currentViewController.present(viewController, animated: true) {
                subject.onCompleted()
            }
            currentViewController = SceneCoordinator.actualViewController(for: viewController)
            
        case .popover:
            viewController.modalPresentationStyle = .popover
            print(currentViewController)
            guard let delegateViewController = currentViewController as? UIPopoverPresentationControllerDelegate else {
                fatalError("Presenting contorller does not adapt to popover delegate")
            }
            viewController.popoverPresentationController?.delegate = delegateViewController
            viewController.popoverPresentationController?.sourceView = currentViewController.view
            // Remove the arrow from the popover
            viewController.popoverPresentationController?.permittedArrowDirections = UIPopoverArrowDirection(rawValue: 0)
            viewController.popoverPresentationController?.sourceRect = CGRect(x: currentViewController.view.bounds.midX, y: currentViewController.view.bounds.midY, width: 0, height: 0)
            print(currentViewController)
            currentViewController.present(viewController, animated: true) {
                self.currentViewController = SceneCoordinator.actualViewController(for: viewController)
                print(self.currentViewController)
                subject.onCompleted()
                
            }
            
        case .searchRoot:
            guard let searchController = currentViewController as? SearchBarViewController else {
                fatalError("To change the root controller of search bar, current view controller must be of type SearchBarViewController")
            }
            searchController.transition(to: viewController, duration: 0.0, options: .curveEaseIn, animations: nil, completion: { _ in
                subject.onCompleted()
            })
        }
        return subject.asObservable()
            .take(1)
            .ignoreElements()
    }
    
    @discardableResult
    func pop(animated: Bool) -> Observable<Void> {
        let subject = PublishSubject<Void>()
        
        if let presenter = currentViewController.presentingViewController {
            if currentViewController.modalPresentationStyle == .popover, let popoverPresenter = SceneCoordinator.actualViewController(for: presenter) as? PopoverPresenterType {
                // dismiss a popover controller
                presenter.dismiss(animated: true, completion: {
                    popoverPresenter.didDismissPopover()
                    self.currentViewController = SceneCoordinator.actualViewController(for: presenter)
                    subject.onCompleted()
                })
            } else {
                // dismiss a modal controller
                currentViewController.dismiss(animated: animated) {
                    print(presenter)
                    self.currentViewController = SceneCoordinator.actualViewController(for: presenter)
                    subject.onCompleted()
                }

            }
        } else if let navigationController = currentViewController.navigationController {
            // navigate up the stack
            // one-off subscription to be notified when pop complete
            _ = navigationController.rx.delegate
                .sentMessage(#selector(UINavigationControllerDelegate.navigationController(_:didShow:animated:)))
                .map { _ in }
                .bind(to: subject)
            guard navigationController.popViewController(animated: animated) != nil else {
                fatalError("can't navigate back from \(currentViewController)")
            }
            currentViewController = SceneCoordinator.actualViewController(for: navigationController.viewControllers.last!)
        } else {
            fatalError("Not a modal, no navigation controller: can't navigate back from \(currentViewController)")
        }
        return subject.asObservable().take(1).ignoreElements()
    }
    
    @discardableResult
    func popVCOffNavStack(animated: Bool) -> Observable<Void> {
        let subject = PublishSubject<Void>()
        
        if let navigationController = currentViewController.navigationController {
            // navigate up the stack
            // one-off subscription to be notified when pop complete
            _ = navigationController.rx.delegate
                .sentMessage(#selector(UINavigationControllerDelegate.navigationController(_:didShow:animated:)))
                .map { _ in }
                .bind(to: subject)
            guard navigationController.popViewController(animated: animated) != nil else {
                fatalError("can't navigate back from \(currentViewController)")
            }
            currentViewController = SceneCoordinator.actualViewController(for: navigationController.viewControllers.last!)
        } else {
            fatalError("No navigation controller: can't navigate back from \(currentViewController)")
        }
        return subject.asObservable().take(1).ignoreElements()
    }
    
    @discardableResult
    func changeChild(To view: ChildViewType) -> Observable<Void> {
        let subject = PublishSubject<Void>()
        if let presenter = (currentViewController as? SearchBarViewController)?.rootViewController as? SearchViewController {
            presenter.showView(view: view.getViewID())
        } else if let presenter = currentViewController as? ParentType {
            presenter.showView(view: view.getViewID())
        } else {
            print("Presenting controller must conform to ParentType")
        }
        subject.onCompleted()
        return subject.asObserver().take(1).ignoreElements()
    }

}
