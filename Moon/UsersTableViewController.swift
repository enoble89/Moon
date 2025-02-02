//
//  UsersTableViewController.swift
//  Moon
//
//  Created by Evan Noble on 6/13/17.
//  Copyright © 2017 Evan Noble. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Action
import Material
import RxDataSources

class UsersTableViewController: UIViewController, BindableType {

    var viewModel: UsersTableViewModel!
    private let bag = DisposeBag()
    @IBOutlet weak var userTableView: UITableView!
   // @IBOutlet weak var showContactsButton: UIButton!
    var backButton: UIBarButtonItem!
    let dataSource = RxTableViewSectionedReloadDataSource<UserSectionModel>()
    var refreshControl: UIRefreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        prepareNavigationBackButton()
        self.view.backgroundColor = UIColor.lightGray
        configureDataSource()
        // Add the refresh control
        userTableView.refreshControl = refreshControl
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        viewModel.reload.onNext()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    
    }
    
    func bindViewModel() {
        
        viewModel.users.do(onNext: { [weak self] _ in
            self?.refreshControl.endRefreshing()
        }).bind(to: userTableView.rx.items(dataSource: dataSource)).addDisposableTo(bag)
        
        userTableView.rx.modelSelected(UserSectionModel.Item.self)
            .do(onNext: { [weak self] _ in
                guard let selectedIndexPath = self?.userTableView.indexPathForSelectedRow else {
                    return
                }
                self?.userTableView.deselectRow(at: selectedIndexPath, animated: true)
            })
            .bind(to: viewModel.onShowUser.inputs)
            .addDisposableTo(bag)
        
        backButton.rx.action = viewModel.onBack()
        
        refreshControl.rx.controlEvent(.valueChanged).bind(to: viewModel.reload).addDisposableTo(bag)
        viewModel.users.map {_ in return false}.bind(to: refreshControl.rx.isRefreshing).addDisposableTo(bag)
    }
    
    fileprivate func configureDataSource() {
        
        dataSource.titleForHeaderInSection = { ds, index in
            return ds.sectionModels[index].titles
        }
        
        dataSource.configureCell = {
            [weak self] dataSource, tableView, indexPath, item in
            
            if let strongSelf = self {
                switch item {
                case .friend(let snap):
                    
                    //swiftlint:disable force_cast
                    let cell = tableView.dequeueReusableCell(withIdentifier: "UsersTableCell", for: indexPath) as! UsersTableViewCell
                    
                    cell.profilePicture.image = nil
                    cell.profilePicture.backgroundColor = .moonGrey
                    cell.profilePicture.cornerRadius = cell.profilePicture.frame.size.width / 2
                    cell.profilePicture.clipsToBounds = true
                    
                    if let id = snap.id {
                        let downloadAction = strongSelf.viewModel.getProfileImage(id: id)
                        downloadAction
                            .elements
                            .bind(to: cell.profilePicture.rx.image)
                            .addDisposableTo(cell.bag)
                        downloadAction.execute()
                    }
                    
                    cell.name.text = snap.name
                    cell.name.textColor = .lightGray
                    
                    return cell
                    
                case .friendRequest(let snap):
                    //swiftlint:disable force_cast
                    let cell = tableView.dequeueReusableCell(withIdentifier: "FriendRequest", for: indexPath) as! FriendRequestTableViewCell
                    
                    cell.profilePicture.image = nil
                    cell.profilePicture.backgroundColor = .moonGrey
                    cell.profilePicture.cornerRadius = cell.profilePicture.frame.size.width / 2
                    cell.profilePicture.clipsToBounds = true
                    
                    if let id = snap.id {
                        let downloadAction = strongSelf.viewModel.getProfileImage(id: id)
                        downloadAction
                            .elements
                            .bind(to: cell.profilePicture.rx.image)
                            .addDisposableTo(cell.bag)
                        downloadAction.execute()
                    }
                    
                    cell.name.text = snap.name
                    cell.name.textColor = .lightGray
                    
                    cell.acceptButton.titleLabel?.text = nil
                    cell.acceptButton.setImage(Icon.cm.check, for: .normal)
                    cell.acceptButton.tintColor = UIColor.moonGreen
                    
                    cell.declineButton.titleLabel?.text = nil
                    cell.declineButton.setImage(Icon.cm.close, for: .normal)
                    cell.declineButton.tintColor = UIColor.moonRed
                    
                    if let userID = snap.id {
                        cell.acceptButton.rx.action = self?.viewModel.onAcceptFriendRequest(userID:userID)
                        cell.declineButton.rx.action = self?.viewModel.onDeclineFriendRequest(userID:userID)
                    }
                    
                    return cell
            
                }
            }
            
            return UITableViewCell()

        }
    }
    
    func prepareNavigationBackButton() {
        backButton = UIBarButtonItem()
        backButton.image = Icon.cm.arrowDownward
        backButton.tintColor = .lightGray
        self.navigationItem.leftBarButtonItem = backButton
    }
    
}

extension UsersTableViewController: UIPopoverPresentationControllerDelegate, PopoverPresenterType {
    func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        
        return UIModalPresentationStyle.none
    }
    
    func popoverPresentationControllerShouldDismissPopover(_ popoverPresentationController: UIPopoverPresentationController) -> Bool {
        viewModel.onBack().execute()
        return false
    }
    
    func didDismissPopover() {
        viewModel.reload.onNext()
    }
}
