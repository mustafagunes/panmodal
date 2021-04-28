//
//  BasicViewController.swift
//  PanModal
//
//  Created by Stephen Sowole on 2/26/19.
//  Copyright © 2019 PanModal. All rights reserved.
//

import UIKit

class BasicViewController: UIViewController {
    
    var stackView: UIStackView = {
        let sv = UIStackView()
        sv.axis = .vertical
        sv.distribution = .equalSpacing
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }()
    
    var label: UILabel = {
        let label = UILabel()
        label.text = "Lorem ipsum dolor sit amet Lorem ipsum dolor sit amet Lorem ipsum dolor sit amet Lorem ipsum dolor sit amet Lorem ipsum dolor sit amet"
        label.textColor = .white
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let textField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "test"
        textField.backgroundColor = .white
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    var keyboardHeight: CGFloat = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = #colorLiteral(red: 0.1019607843, green: 0.1137254902, blue: 0.1294117647, alpha: 1)
        
        view.addSubview(label)
        view.addSubview(textField)
        
        NSLayoutConstraint.activate([
            label.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 16),
            label.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -16),
            label.topAnchor.constraint(equalTo: view.topAnchor, constant: 16),
            textField.leftAnchor.constraint(equalTo: label.leftAnchor),
            textField.rightAnchor.constraint(equalTo: label.rightAnchor),
            textField.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 20),
            bottomLayoutGuide.topAnchor.constraint(
                greaterThanOrEqualTo: textField.bottomAnchor,
                constant: 16
            )
        ])
//        stackView.addArrangedSubview(label)
//        stackView.addArrangedSubview(textField)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow(notification:)),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide(notification:)),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        keyboardHeight = (notification.userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue.height
        panModalSetNeedsLayoutUpdate()
        panModalTransition(to: .longForm, animated: false)
    }

    @objc func keyboardWillHide(notification: NSNotification) {
        keyboardHeight = (notification.userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue.height
        panModalSetNeedsLayoutUpdate()
        panModalTransition(to: .longForm, animated: false)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        panModalSetNeedsLayoutUpdate()
        //panModalTransition(to: .longForm, animated: false)
    }
}

extension BasicViewController: PanModalPresentable {

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    var panScrollable: UIScrollView? {
        return nil
    }

    var longFormHeight: PanModalHeight {
        let insets = UIEdgeInsets(top: 0, left: 0, bottom: keyboardHeight, right: 0)
        return .intrinsicHeightWithInsets(insets: insets)
    }

    var anchorModalToLongForm: Bool {
        return false
    }
    
    var indicatorBackgroundColor: UIColor {
        return view.backgroundColor ?? .white
    }
}
