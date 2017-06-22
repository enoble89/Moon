//
//  SettingsViewController.swift
//  Moon
//
//  Created by Evan Noble on 6/8/17.
//  Copyright © 2017 Evan Noble. All rights reserved.
//

import UIKit
import RxCocoa
import Material
import RxSwift

class SettingsViewController: UITableViewController, BindableType {
    
    var viewModel: SettingsViewModel!
    private let disposeBag = DisposeBag()
    var navBackButton: UIBarButtonItem!

    @IBOutlet weak var settingsTableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()

        prepareNavigationBackButton()
    }

    func bindViewModel() {
        navBackButton.rx.action = viewModel.onBack()
        
        self.tableView.rx.itemSelected
            .map(settingFrom)
            .filter({ $0 != nil })
            .map({ $0! })
            .subscribe(viewModel.showNextScreen.inputs)
            .addDisposableTo(disposeBag)
    }
    
    fileprivate func prepareNavigationBackButton() {
        navBackButton = UIBarButtonItem()
        navBackButton.image = Icon.cm.arrowBack
        navBackButton.tintColor = .lightGray
        self.navigationItem.leftBarButtonItem = navBackButton
    }
    
    fileprivate func settingFrom(indexPath: IndexPath) -> Setting? {
        switch indexPath.section {
        case 0:
            guard let setting = SettingSections.MyAccount(rawValue: indexPath.row) else {
                return nil
            }
            return Setting.myAccount(option: setting)
        case 1:
            guard let setting = SettingSections.MoreInformation(rawValue: indexPath.row) else {
                return nil
            }
            return Setting.moreInformation(option: setting)
        case 2:
            guard let setting = SettingSections.AccountActions(rawValue: indexPath.row) else {
                return nil
            }
            return Setting.accountActions(option: setting)
        default: return nil
        }
    }

}
