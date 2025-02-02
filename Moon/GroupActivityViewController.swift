//
//  GroupActivityViewController.swift
//  Moon
//
//  Created by Evan Noble on 7/23/17.
//  Copyright © 2017 Evan Noble. All rights reserved.
//

import UIKit
import Material
import RxSwift
import RxCocoa
import RxDataSources
import Action

class GroupActivityViewController: UIViewController, BindableType, UICollectionViewDelegateFlowLayout {

    // MARK: - Global
    var viewModel: GroupActivityViewModel!
    var bag = DisposeBag()
    var backButton: UIBarButtonItem!
    var groupMembersDataSource = RxCollectionViewSectionedReloadDataSource<ActivitySection>()
    private let membersCollectionCellResuseIdenifier = "MemberSnapshotCell"
    
    @IBOutlet weak var goButton: UIButton!
    @IBOutlet weak var groupPic: UIImageView!
    @IBOutlet weak var groupNameLabel: UILabel!
    @IBOutlet weak var planButton: UIButton!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var likersButton: UIButton!
    @IBOutlet weak var groupMembersCollectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        prepareNavigationBackButton()
        prepareGroupPicture()
        prepareLikesButton()
        preparePlanButton()
        prepareGroupNameLabel()
        configureDataSource()
        
        groupMembersCollectionView.delegate = self
    }
    
    func prepareGroupNameLabel() {
        groupNameLabel.text = "Group Name"
        groupNameLabel.textColor = .lightGray
    }
    
    func bindViewModel() {
        backButton.rx.action = viewModel.onBack()
        
        viewModel.showGoButton.map(!).bind(to: goButton.rx.isHidden).addDisposableTo(bag)
        viewModel.groupName.bind(to: groupNameLabel.rx.text).addDisposableTo(bag)
        viewModel.barName.bind(to: planButton.rx.title()).addDisposableTo(bag)
        viewModel.numberOfLikes.bind(to: likersButton.rx.title()).addDisposableTo(bag)
        viewModel.hasLikedGroupPlan
            .subscribe(onNext: { [weak self] hasLiked in
                self?.likeButton.tintColor = hasLiked ? .red : .lightGray
            })
            .addDisposableTo(bag)
        viewModel.displayUsers.bind(to: groupMembersCollectionView.rx.items(dataSource: groupMembersDataSource)).addDisposableTo(bag)
        
        viewModel.groupPicture.bind(to: groupPic.rx.image).addDisposableTo(bag)
        
        likeButton.rx.action = viewModel.onLikeGroupActivity()
        likersButton.rx.action = viewModel.onViewGroupLikers()
        planButton.rx.action = viewModel.onViewBar()
        
        let attendAction = viewModel.onChangeAttendance()
        goButton.rx.action = attendAction
        
        attendAction.executionObservables.flatMap({
            return $0
                .do(onError: { [weak self] _ in
                    self?.toggleGoButton()
                    }, onSubscribe: { [weak self] _ in
                        self?.toggleGoButton()
                }).catchErrorJustReturn()
        })
            .subscribe()
            .addDisposableTo(bag)
        
        attendAction.elements
            .subscribe(onNext: { [weak self] _ in
                self?.viewModel.reloadUsers.onNext()
            }).addDisposableTo(bag)
        
        viewModel.isAttending.subscribe(onNext: { [weak self] isAttending in
            if isAttending {
                self?.goButton.setImage(#imageLiteral(resourceName: "thereIconGray"), for: .normal)
            } else {
                self?.goButton.setImage(#imageLiteral(resourceName: "goButtonGray"), for: .normal)
            }
        }).addDisposableTo(bag)
        
    }
    
    private func toggleGoButton() {
        if goButton.imageView?.image == #imageLiteral(resourceName: "goButtonGray") {
            goButton.setImage(#imageLiteral(resourceName: "thereIconGray"), for: .normal)
        } else if goButton.imageView?.image == #imageLiteral(resourceName: "thereIconGray") {
            goButton.setImage(#imageLiteral(resourceName: "goButtonGray"), for: .normal)
        }
    }
    
    func prepareNavigationBackButton() {
        backButton = UIBarButtonItem()
        backButton.image = Icon.cm.arrowDownward
        backButton.tintColor = .lightGray
        self.navigationItem.leftBarButtonItem = backButton
    }
    
    func preparePlanButton() {
        planButton.tintColor = .lightGray
        planButton.titleLabel?.font = UIFont(name: "Roboto", size: 15)
    }
    
    func prepareLikesButton() {
        likersButton.titleLabel?.font = UIFont(name: "Roboto", size: 14)
        likersButton.tintColor = .lightGray
        likersButton.setTitle("0", for: .normal)
        
        let image =  Icon.favorite
        likeButton.setBackgroundImage(image, for: .normal)
    }
    
    func prepareGroupPicture() {
        groupPic.isUserInteractionEnabled = true
        groupPic.layer.cornerRadius = groupPic.frame.size.height  / 2
        groupPic.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        groupPic.contentMode = UIViewContentMode.scaleAspectFill
        groupPic.clipsToBounds = true
    }
    
    fileprivate func cellsPerRowVertical(cells: Int, collectionView: UICollectionView) -> UICollectionViewFlowLayout {
        let numberOfCellsPerRow: CGFloat = CGFloat(cells)
        
        let flowLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout
        
        let horizontalSpacing = flowLayout?.scrollDirection == .vertical ? flowLayout?.minimumInteritemSpacing: flowLayout?.minimumLineSpacing
        
        let cellWidth = ((self.view.frame.width) - max(0, numberOfCellsPerRow - 1) * horizontalSpacing!)/numberOfCellsPerRow
        
        flowLayout?.itemSize = CGSize(width: cellWidth, height: cellWidth)
        
        return flowLayout!
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var cellSize = CGFloat(0.0)
        cellSize = collectionView.frame.size.height * 0.95

        return CGSize(width: 160, height: 170)
    }
    
    func configureDataSource() {
        groupMembersDataSource.configureCell = {
            [weak self] dataSource, collectionView, indexPath, item in
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "GroupMemeberCollectionViewCell", for: indexPath)
            
            collectionView.collectionViewLayout = (self?.cellsPerRowVertical(cells: 2, collectionView: collectionView))!
            
            let width = cell.frame.width - 10
            let height = cell.frame.size.height - 20
            
            let view = PeopleGoingCarouselView()
            
            view.frame = CGRect(x: (cell.frame.size.width / 2) - (width / 2), y: (cell.frame.size.width / 2) - (height / 2), width: width, height: height)
            view.backgroundColor = .clear
            
            if let strongSelf = self {
                view.initializeView()
                strongSelf.populateGoing(peopleGoingView: view, activity: item)
            }
            
            // Remove the last view from the cell if there is one
            for view in cell.subviews {
                if let subview = view as? UserCollectionView {
                    subview.removeFromSuperview()
                }
            }
            cell.layoutIfNeeded()
            
            cell.addSubview(view)
            return cell
        }
    }
    
    func populateGoing(peopleGoingView: PeopleGoingCarouselView, activity: Activity) {
        
        // Bind actions
        if let userID = activity.userID {
            
            let likeAction = viewModel.onLikeUserActivity(userID: userID)
            peopleGoingView.likeButton.rx.action = likeAction
            likeAction.elements.do(onNext: {
                peopleGoingView.toggleColorAndNumber()
            }).subscribe().addDisposableTo(peopleGoingView.bag)
            
            let hasLiked = viewModel.hasLikedActivity(activityID: userID)
            hasLiked.elements.do(onNext: { hasLiked in
                if hasLiked {
                    peopleGoingView.likeButton.tintColor = .red
                }
            }).subscribe().addDisposableTo(peopleGoingView.bag)
            hasLiked.execute()
            
            peopleGoingView.numberOfLikesButton.rx.action = viewModel.onViewUserActivityLikes(userID: userID)
            
            peopleGoingView.imageView.gestureRecognizers?.first?.rx.event.subscribe(onNext: { [weak self] _ in
                self?.viewModel.onShowProfile(userID: userID).execute()
            }).addDisposableTo(peopleGoingView.bag)
            
            let downloader = viewModel.getProfileImage(id: userID)
            downloader.elements.bind(to: peopleGoingView.imageView.rx.image).addDisposableTo(peopleGoingView.bag)
            downloader.execute()
        } else {
            peopleGoingView.imageView.image = #imageLiteral(resourceName: "DefaultProfilePic")
        }
        
        // Bind labels
        peopleGoingView.numberOfLikesButton.title = "\(activity.numLikes ?? 0)"
        let nameLabel = peopleGoingView.bottomToolbar.leftViews[0] as? UILabel
        nameLabel?.text = activity.userName
        
    }

}

extension GroupActivityViewController: UIPopoverPresentationControllerDelegate, PopoverPresenterType {
    func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        
        return UIModalPresentationStyle.none
    }
    
    func popoverPresentationControllerShouldDismissPopover(_ popoverPresentationController: UIPopoverPresentationController) -> Bool {
        viewModel.onBack().execute()
        return false
    }
    
    func didDismissPopover() {
        
    }
}
