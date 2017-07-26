//
//  CreateEditGroupViewController.swift
//  Moon
//
//  Created by Evan Noble on 7/23/17.
//  Copyright © 2017 Evan Noble. All rights reserved.
//

import UIKit
import Material
import Action
import Fusuma

class CreateEditGroupViewController: UIViewController, BindableType, FusumaDelegate, UITextFieldDelegate, UIScrollViewDelegate {
    
    // MARK: - Global
    var viewModel: CreateEditGroupViewModel!
    var backButton: UIBarButtonItem!
    let imagePicker = UIImagePickerController()
    let fusuma = FusumaViewController()
    let tap = UITapGestureRecognizer()
    var offSet: CGFloat!
    var keyboardHeight: CGFloat!
    var addMemberTextFieldIsActive = false

    @IBOutlet weak var suggestedMembersView: UIView!
    @IBOutlet weak var groupPicture: UIImageView!
    @IBOutlet weak var groupNameTextField: TextField!
    @IBOutlet weak var addMemberTextField: TextField!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var suggestedMemberViewHeightConstraint: NSLayoutConstraint!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        prepareNavigationBackButton()
        prepareGroupNameTextField()
        prepareAddMemberTextField()
        prepareGroupPicture()
        prepareAddButton()
        prepareSaveButton()
        prepareScrollView()
        prepareSuggestedMemberView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
    }
    
    func keyboardWillShow(notification: NSNotification) {
        
        if addMemberTextFieldIsActive {
            animateViewUp()
            let userInfo: NSDictionary = notification.userInfo! as NSDictionary
            let keyboardFrame: NSValue = (userInfo.value(forKey: UIKeyboardFrameEndUserInfoKey) as? NSValue)!
            let keyboardRectangle = keyboardFrame.cgRectValue
            keyboardHeight = keyboardRectangle.height
            calculateOffset()
            moveScrollViewUP()
        }
        
    }
    
    func calculateOffset() {
        let screenHeight = self.view.frame.size.height
        let bioY = screenHeight - suggestedMembersView.y
        let keyboardShift = keyboardHeight - bioY
        let extraShift = CGFloat(10) + suggestedMembersView.frame.size.height
        
        offSet = extraShift + keyboardShift
    }
    
    func bindViewModel() {
        backButton.rx.action = viewModel.onBack()
        backButton.image = viewModel.showBackArrow ? Icon.cm.arrowBack : Icon.cm.arrowDownward
    }
    
    func prepareNavigationBackButton() {
        self.navigationItem.hidesBackButton = true
        backButton = UIBarButtonItem()
        backButton.tintColor = .lightGray
        self.navigationItem.leftBarButtonItem = backButton
    }
    
    func prepareSuggestedMemberView() {
        suggestedMembersView.layer.borderWidth = 1
        suggestedMembersView.layer.cornerRadius = 5
        suggestedMembersView.layer.borderColor = UIColor.lightGray.cgColor
    }
    
    func prepareGroupNameTextField() {
        groupNameTextField.placeholder = "Group Name"
        groupNameTextField.isClearIconButtonEnabled = true
        groupNameTextField.placeholderActiveColor = .moonBlue
        groupNameTextField.dividerActiveColor = .moonBlue
        groupNameTextField.dividerNormalColor = .moonBlue
            
        let leftView = UIImageView()
        leftView.image = Icon.cm.pen
        groupNameTextField.leftView = leftView
        groupNameTextField.leftViewActiveColor = .moonBlue
        groupNameTextField.delegate = self
    }
    
    func prepareAddMemberTextField() {
        addMemberTextField.placeholder = "Member Name"
        addMemberTextField.isClearIconButtonEnabled = true
        addMemberTextField.placeholderActiveColor = .moonBlue
        addMemberTextField.dividerActiveColor = .moonBlue
        addMemberTextField.dividerNormalColor = .moonBlue
        
        let leftView = UIImageView()
        leftView.image = Icon.cm.pen
        addMemberTextField.leftView = leftView
        addMemberTextField.leftViewActiveColor = .moonBlue
        addMemberTextField.delegate = self
    }
    
    func prepareAddButton() {
        addButton.backgroundColor = .moonGreen
        addButton.tintColor = .white
        addButton.layer.cornerRadius = 5
    }
    
    func prepareSaveButton() {
        saveButton.backgroundColor = .moonGreen
        saveButton.tintColor = .white
        saveButton.layer.cornerRadius = 5
    }
    
    func prepareScrollView() {
        scrollView.delegate = self
        scrollView.isUserInteractionEnabled = true
        scrollView.isScrollEnabled = false
        scrollView.bounces = false
        scrollView.keyboardDismissMode = .interactive
        scrollView.contentSize = CGSize(width: self.view.frame.size.width, height: 700)
    }
    
    func prepareFusuma() {
        fusuma.delegate = self
        fusuma.hasVideo = false
        fusumaTintColor = .moonPurple
        fusumaBaseTintColor = .moonPurple
        fusumaBackgroundColor = .white
        fusumaCropImage = true
        fusuma.cropHeightRatio = CGFloat(1)
        fusuma.allowMultipleSelection = false
    }
    
    @objc fileprivate func imageTouched() {
        prepareFusuma()
        self.present(fusuma, animated: true, completion: nil)
    }
    
    func prepareGroupPicture() {
        groupPicture.isUserInteractionEnabled = true
        tap.addTarget(self, action: #selector(imageTouched))
        groupPicture.addGestureRecognizer(tap)
        groupPicture.layer.cornerRadius = groupPicture.frame.size.height  / 2
        groupPicture.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        groupPicture.contentMode = UIViewContentMode.scaleAspectFill
        groupPicture.clipsToBounds = true
    }
    
    // MARK: FUSUMA DELEGATES for image cropping
    // Return the image which is selected from camera roll or is taken via the camera.
    func fusumaImageSelected(_ image: UIImage, source: FusumaMode) {
        //let i  = image.crop(toWidth: 200, toHeight: 200) // circle image
        groupPicture.image = image
    }
    
    func fusumaMultipleImageSelected(_ images: [UIImage], source: FusumaMode) {
        print("Multiple Images Selected")
    }
    
    // Return the image but called after is dismissed.
    func fusumaDismissedWithImage(image: UIImage) {
        
        print("Called just after FusumaViewController is dismissed.")
    }
    
    func fusumaVideoCompleted(withFileURL fileURL: URL) {
        
        print("Called just after a video has been selected.")
    }
    
    // When camera roll is not authorized, this method is called.
    func fusumaCameraRollUnauthorized() {
        
        print("Camera roll unauthorized")
    }
    
    func animateViewUp() {
        UIView.animate(withDuration: Double(0.3), animations: {
            self.suggestedMemberViewHeightConstraint.constant = 150
            self.view.layoutIfNeeded()
        })
        
    }
    
    func animateViewDown() {
        UIView.animate(withDuration: Double(0.3), animations: {
            self.suggestedMemberViewHeightConstraint.constant = 0
            self.view.layoutIfNeeded()
        })
        
    }
    
    func moveScrollViewUP() {
        UIView.animate(withDuration: Double(0.3), animations: {
            self.scrollView.contentOffset.y = self.offSet
            self.view.layoutIfNeeded()
        })
    }
    
    func moveScrollViewDown() {
        UIView.animate(withDuration: Double(0.3), animations: {
            self.scrollView.contentOffset.y = 0 //self.scrollView.y
            self.scrollView.layoutIfNeeded()
        })
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == addMemberTextField {
             addMemberTextFieldIsActive = true
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextFieldDidEndEditingReason) {
        if textField == addMemberTextField {
             addMemberTextFieldIsActive = false
            animateViewDown()
            moveScrollViewDown()
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        addMemberTextField.resignFirstResponder()
        groupNameTextField.resignFirstResponder()
        self.moveScrollViewDown()
        self.animateViewDown()
        
        return true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        addMemberTextField.resignFirstResponder()
        groupNameTextField.resignFirstResponder()
    }
    
}
