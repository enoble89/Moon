//
//  BarProfileViewController.swift
//  Moon
//
//  Created by Evan Noble on 6/8/17.
//  Copyright © 2017 Evan Noble. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import iCarousel
import Material
import MaterialComponents.MaterialCollections

class BarProfileViewController: UIViewController, UIScrollViewDelegate, BindableType, DisplayErrorType {
    @IBOutlet weak var segmentControl: ADVSegmentedControl!

    @IBOutlet weak var toolBar: Toolbar!
    @IBOutlet weak var goingCarousel: iCarousel!
    @IBOutlet weak var pictureCarousel: iCarousel!
    @IBOutlet weak var pageController: UIPageControl!
    @IBOutlet weak var specialsCarousel: iCarousel!
    @IBOutlet weak var eventsCarousel: iCarousel!
    
    @IBOutlet weak var eventsLabel: UILabel!
    @IBOutlet weak var specialsLabel: UILabel!
    @IBOutlet weak var scrollView: UIScrollView!
    var viewModel: BarProfileViewModel!
    private let bag = DisposeBag()
    var backButton: UIBarButtonItem!
    var moreInfoButton: IconButton!
    var goButton: IconButton!
    var usersGoing: Int = 0
    
    //Constraints outlets
    @IBOutlet weak var pictureCarouselConstraint: NSLayoutConstraint!
    @IBOutlet weak var goingViewConstraint: NSLayoutConstraint!
    @IBOutlet weak var specialViewConstraint: NSLayoutConstraint!
    @IBOutlet weak var eventViewConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //prepare the UI
        prepareScrollView()
        prepareCarousels()
        prepareSegmentControl()
        prepareToolBar()
        preparePageControl()
        prepareNavigationBackButton()
        prepareLabels()
        
        //Dynamic Heights for each view
        let phoneSize = self.view.frame.size.height
        pictureCarouselConstraint.constant = phoneSize * 0.34
        goingViewConstraint.constant = phoneSize * 0.38
        specialViewConstraint.constant = phoneSize * 0.35
        //eventViewConstraint.constant = phoneSize * 0.38
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        self.navigationController?.navigationBar.barTintColor = .moonGrey
        self.navigationController?.navigationBar.barStyle = UIBarStyle.default
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.lightGray]
        viewModel.reloadDisplayUsers.onNext()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func toggleGoButtonAndNumGoing() {
        if goButton.image == #imageLiteral(resourceName: "goButton") {
            goButton.image = #imageLiteral(resourceName: "thereIcon")
            usersGoing += 1
        } else if goButton.image == #imageLiteral(resourceName: "thereIcon") {
            goButton.image = #imageLiteral(resourceName: "goButton")
            usersGoing -= 1
        }
        
        toolBar.titleLabel.attributedText = createUsersGoingString(usersGoing: usersGoing)
    }
    
    func bindViewModel() {
        backButton.rx.action = viewModel.onBack()
        moreInfoButton.rx.action = viewModel.onShowInfo()
        
        let attendAction = viewModel.onAttendBar()
        goButton.rx.action = attendAction
        
        attendAction.executionObservables.flatMap({
            return $0
                .do(onError: { [weak self] _ in
                    self?.toggleGoButtonAndNumGoing()
                }, onSubscribe: { [weak self] _ in
                    self?.toggleGoButtonAndNumGoing()
                }).catchErrorJustReturn()
        })
        .subscribe()
        .addDisposableTo(bag)

        attendAction.elements
            .subscribe(onNext: { [weak self] _ in
                self?.viewModel.reloadDisplayUsers.onNext()
            }).addDisposableTo(bag)
        
        viewModel.isAttending.subscribe(onNext: { [weak self] isAttending in
            if isAttending {
                self?.goButton.image = #imageLiteral(resourceName: "thereIcon")
            } else {
                self?.goButton.image = #imageLiteral(resourceName: "goButton")
            }
        }).addDisposableTo(bag)
        
        segmentControl.rx.controlEvent(UIControlEvents.valueChanged)
            .map({ [weak self] in
                return UsersGoingType(rawValue: self?.segmentControl.selectedIndex ?? 0) ?? .everyone
            }).bind(to: viewModel.selectedUserIndex).addDisposableTo(bag)
        
        viewModel.displayedUsers.asObservable()
            .do(onNext: { [weak self] users in
                if users.isEmpty {
                    var text = ""
                    if self?.segmentControl.selectedIndex == 0 {
                        self?.removeEmptyViewText(carousel: (self?.goingCarousel)!)
                        text = "Looks Like No People Are Going Tonight"
                    } else {
                        self?.removeEmptyViewText(carousel: (self?.goingCarousel)!)
                        text = "Looks Like No Friends Are Going Tonight"
                    }
                    self?.displayEmptyViewText(text: text, carousel: (self?.goingCarousel)!)
                } else {
                    self?.removeEmptyViewText(carousel: (self?.goingCarousel)!)
                }
            })
            .subscribe(onNext: { [weak self] _ in
                self?.goingCarousel.reloadData()
            }).addDisposableTo(bag)
        
        viewModel.barName.subscribe(onNext: { [weak self] in
            self?.title = $0
        }).addDisposableTo(bag)

        viewModel.barPics.asObservable().subscribe(onNext: { [weak self] in
            self?.pageController.numberOfPages = $0.count
            self?.pictureCarousel.reloadData()
        }).addDisposableTo(bag)
        
        viewModel.specials.asObservable().do(onNext: { [weak self] specials in
            if specials.isEmpty {
                self?.displayEmptyViewText(text: "Looks Like There Are No Specials", carousel: (self?.specialsCarousel)!)
            } else {
                self?.removeEmptyViewText(carousel: (self?.specialsCarousel)!)
            }
        }).subscribe(onNext: { [weak self] _ in
            self?.specialsCarousel.reloadData()
        }).addDisposableTo(bag)
        
        viewModel.events.asObservable().do(onNext: { [weak self] events in
            if events.isEmpty {
                self?.displayEmptyViewText(text: "Looks Like There Are No Events", carousel: (self?.eventsCarousel)!)
            } else {
                self?.removeEmptyViewText(carousel: (self?.eventsCarousel)!)
            }
        }).subscribe(onNext: { [weak self] _ in
            self?.eventsCarousel.reloadData()
        }).addDisposableTo(bag)
        
        viewModel.numPeopleAttending
            .do(onNext: { [weak self] numGoing in
                self?.usersGoing = numGoing
            })
            .map(createUsersGoingString)
            .subscribe(onNext: { [weak self] numGoing in
                self?.toolBar.titleLabel.attributedText = numGoing
            })
            .addDisposableTo(bag)
        
    }
    
    func createUsersGoingString(usersGoing: Int) -> NSAttributedString {
        let fullString = NSMutableAttributedString(string: " ")
        
        let attachment = NSTextAttachment()
        attachment.image = #imageLiteral(resourceName: "goingIcon")
        attachment.bounds = CGRect(x: 0, y: -5, width: 16, height: 16)
        
        let attachmentString = NSAttributedString(attachment: attachment)
        
        fullString.append(attachmentString)
        fullString.append(NSAttributedString(string: " " + "\(usersGoing)"))
        
        return fullString
    }
    
    func prepareScrollView() {
        scrollView.delegate = self
        scrollView.isScrollEnabled = true
        scrollView.contentSize = CGSize(width: self.view.frame.size.width, height: 1100.0)
    }
    
    func prepareNavigationBackButton() {
        backButton = UIBarButtonItem()
        backButton.image = Icon.cm.arrowDownward
        backButton.tintColor = .lightGray
        self.navigationItem.leftBarButtonItem = backButton
    }
    
    func prepareSegmentControl() {
        //segment set up
        segmentControl.items = ["People Going", "Friends Going"]
        segmentControl.selectedLabelColor = .moonPurple
        segmentControl.borderColor = .clear
        segmentControl.backgroundColor = .clear
        segmentControl.selectedIndex = 0
        segmentControl.unselectedLabelColor = .lightGray
        segmentControl.thumbColor = .moonPurple
    }
    
    func prepareCarousels() {
        goingCarousel.isPagingEnabled = true
        goingCarousel.type = .linear
        goingCarousel.bounces = false
        goingCarousel.tag = 0
        goingCarousel.reloadData()
       
        eventsCarousel.isPagingEnabled = true
        eventsCarousel.type = .coverFlow
        eventsCarousel.bounces = false
        eventsCarousel.tag = 1
        eventsCarousel.reloadData()
        
        pictureCarousel.isPagingEnabled = true
        pictureCarousel.type = .linear
        pictureCarousel.bounces = false
        pictureCarousel.tag = 2
        pictureCarousel.reloadData()
        pictureCarousel.bringSubview(toFront: toolBar)
        pictureCarousel.bringSubview(toFront: pageController)
        
        specialsCarousel.isPagingEnabled = true
        specialsCarousel.type = .linear
        specialsCarousel.bounces = false
        specialsCarousel.tag = 3
        specialsCarousel.reloadData()
    }
    
    func preparePageControl() {
        pageController.numberOfPages = viewModel.barPics.value.count
        pageController.currentPageIndicatorTintColor = .white
        pageController.pageIndicatorTintColor = .lightGray
        pageController.currentPage = 0
    }
    
    func prepareToolBar() {
        
        toolBar.titleLabel.textColor = .white
        toolBar.backgroundColor = .clear
    
        // It the attributed isn't set to something here, then it doesn't show up when you
        // set it with the real value after the bar profile is loaded
        toolBar.titleLabel.attributedText = NSAttributedString(string: "0")
        moreInfoButton = IconButton(image: Icon.cm.moreHorizontal, tintColor: .white)
        goButton = IconButton(image: #imageLiteral(resourceName: "goButton"))
        toolBar.leftViews = [moreInfoButton]
        toolBar.rightViews = [goButton]
    }
    
    func prepareLabels() {
        specialsLabel.textColor = .moonBlue
        specialsLabel.dividerColor = .moonBlue
        specialsLabel.dividerThickness = 1.8
        
        eventsLabel.textColor = .moonRed
        eventsLabel.dividerColor = .moonRed
        eventsLabel.dividerThickness = 1.8
    }

}

extension BarProfileViewController: iCarouselDataSource, iCarouselDelegate {
    
    func carousel(_ carousel: iCarousel, valueFor option: iCarouselOption, withDefault value: CGFloat) -> CGFloat {
        
        if carousel == pictureCarousel {
            return value
        } else {
            if option == .spacing {
                return value * 1.2
            }
        }
        
        return value
    }
        
    func numberOfItems(in carousel: iCarousel) -> Int {
        
        if carousel.tag == 0 {
            return viewModel.displayedUsers.value.count //returns number of people going
        } else if carousel.tag == 1 {
            return viewModel.events.value.count //returns number of fake events
        } else if carousel.tag == 2 {
            return viewModel.barPics.value.count //returns number of bar pictures
        } else if carousel.tag == 3 {
            return viewModel.specials.value.count //returns number of specials
        }
        
        return 0
    }

    func carouselCurrentItemIndexDidChange(_ carousel: iCarousel) {
        
        if carousel == pictureCarousel {
            pageController.currentPage = pictureCarousel.currentItemIndex
        }
      
    }
    
    func carousel(_ carousel: iCarousel, viewForItemAt index: Int, reusing view: UIView?) -> UIView {
        
        if carousel == pictureCarousel {
            return setUpPictureView(index: index)
        } else if carousel == specialsCarousel {
            return setUpSpecialView(index: index)
        } else if carousel == goingCarousel {
            return setUpGoingView(index: index)
        } else if carousel == eventsCarousel {
            return setUpEventView(index: index)
        }
        
        return UIView(frame: carousel.frame)
    }
    
    func setUpGoingView(index: Int) -> UIView {
        let size = (self.view.frame.size.height * 0.325) - 50
        let frame = CGRect(x: goingCarousel.frame.size.width / 2, y: goingCarousel.frame.size.height / 2, width: size, height: size)
        let view = PeopleGoingCarouselView()
        view.frame = frame
        view.initializeView()
        populateGoing(peopleGoingView: view, index: index)
        
        return view
    }
    
    func setUpSpecialView(index: Int) -> UIView {
        let view = SpecialCarouselView()
        let size = (self.view.frame.size.height * 0.298) - 50
        let frame = CGRect(x: specialsCarousel.frame.size.width / 2, y: specialsCarousel.frame.size.height / 2, width: size + 20, height: size)
        view.frame = frame
        view.initializeView()
        populate(specialView: view, index: index)
        
        return view
    }
     
    func setUpEventView(index: Int) -> UIView {
        let view = FeaturedEventView()
        let size = (self.view.frame.size.height * 0.513) - 60
        view.frame = CGRect(x: eventsCarousel.frame.size.width / 2, y: eventsCarousel.frame.size.height / 2, width: size + 60, height: size)
        view.backgroundColor = .clear
        view.initializeCell()
        populate(eventView: view, index: index)
        
        return view
    }
    
    func setUpPictureView(index: Int) -> UIView {
        let barPic = BottomGradientImageView(frame: pictureCarousel.frame)
        barPic.image = viewModel.barPics.value[index]
        
        return barPic
    }
    
    func displayEmptyViewText(text: String, carousel: iCarousel) {
        // Remove label before adding a new one
        removeEmptyViewText(carousel: carousel)
        
        let frame = CGRect(x: 0, y: carousel.frame.size.height / 2, width: carousel.frame.size.width, height: 30)
        let label = UILabel(frame: frame)
        label.textAlignment = .center
        label.textColor = .lightGray
        label.font = UIFont(name: "Roboto", size: 16)
        label.text = text
        label.tag = 5
        
        carousel.addSubview(label)
        carousel.bringSubview(toFront: label)
    }
    
    func removeEmptyViewText(carousel: iCarousel) {
        if let viewWithTag = carousel.viewWithTag(5) {
            viewWithTag.removeFromSuperview()
        }
    }

}

extension BarProfileViewController: UIPopoverPresentationControllerDelegate {
    func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        
        return UIModalPresentationStyle.none
    }
    
    func popoverPresentationControllerShouldDismissPopover(_ popoverPresentationController: UIPopoverPresentationController) -> Bool {
        return false
    }
}
