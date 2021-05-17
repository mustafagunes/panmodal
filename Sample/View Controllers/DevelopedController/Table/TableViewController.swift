//
//  TableViewController.swift
//  PanModalDemo
//
//  Created by Mustafa Gunes on 25.04.2021.
//  Copyright © 2021 Detail. All rights reserved.
//

import UIKit

#warning(
"""
    * Burada modellerin bulunduğu array, class init olduğunda hazır olduğu için longFormHeight'ta
    tableView contentSize düzgün çalıyor. Api requestten sonra response geldiğinde tableView reload edildiği anda
    panModalSetNeedsLayoutUpdateWithTransition() methodu çağırılınca sorun çözülecektir.
"""
)

class TableViewController: UIViewController {
    
    // MARK: - Data
    var members: [UserGroupMemberPresentable] = []
        
    // MARK: - UI Components
    lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.backgroundColor = #colorLiteral(red: 0.1019607843, green: 0.1137254902, blue: 0.1294117647, alpha: 1)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(UserGroupMemberCell.self, forCellReuseIdentifier: "cell")
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setConfigurationNavBar()
        makeUserInterfaceComponents()
    }
    
    private func setConfigurationNavBar() {
        title = "Navbar TableView"
        
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.titleTextAttributes = [
            .font: UIFont(name: "Lato-Bold", size: 17)!,
            .foregroundColor: #colorLiteral(red: 0.7019607843, green: 0.7058823529, blue: 0.7137254902, alpha: 1)
        ]
        navigationController?.navigationBar.tintColor = #colorLiteral(red: 0.7019607843, green: 0.7058823529, blue: 0.7137254902, alpha: 1)
        navigationController?.navigationBar.barTintColor = #colorLiteral(red: 0.1294117647, green: 0.1411764706, blue: 0.1568627451, alpha: 1)

        navigationItem.backBarButtonItem = UIBarButtonItem(title:"", style: .plain, target: nil, action: nil)
    }
    
    private func makeUserInterfaceComponents() {
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.leftAnchor.constraint(equalTo: view.leftAnchor),
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.rightAnchor.constraint(equalTo: view.rightAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        tableView.reloadData()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(1300)) {
            self.members = [
                UserGroupMemberPresentable(name: "Naida Schill ✈️", role: "Staff Engineer - Mobile DevXP", avatarBackgroundColor: #colorLiteral(red: 0.7215686275, green: 0.9098039216, blue: 0.5607843137, alpha: 1)),
                UserGroupMemberPresentable(name: "Annalisa Doty", role: "iOS Engineer - NewXP", avatarBackgroundColor: #colorLiteral(red: 0.7176470588, green: 0.8784313725, blue: 0.9882352941, alpha: 1)),
                UserGroupMemberPresentable(name: "Petra Gazaway 🏡", role: "Senior iOS Product Engineer - Enterprise", avatarBackgroundColor: #colorLiteral(red: 0.9725490196, green: 0.937254902, blue: 0.4666666667, alpha: 1)),
                UserGroupMemberPresentable(name: "Jermaine Gill ⛷", role: "Staff Engineer - Mobile Infra", avatarBackgroundColor: #colorLiteral(red: 0.9490196078, green: 0.7568627451, blue: 0.9803921569, alpha: 1)),
                UserGroupMemberPresentable(name: "Juana Brooks 🚌", role: "Staff Software Engineer", avatarBackgroundColor: #colorLiteral(red: 0.9960784314, green: 0.8823529412, blue: 0.6980392157, alpha: 1)),
                UserGroupMemberPresentable(name: "Stacey Francis 🛳", role: "Senior iOS Engineer", avatarBackgroundColor: #colorLiteral(red: 0.8784313725, green: 0.8745098039, blue: 0.9921568627, alpha: 1)),
                UserGroupMemberPresentable(name: "Juana Brooks 🚌", role: "Staff Software Engineer", avatarBackgroundColor: #colorLiteral(red: 0.9960784314, green: 0.8823529412, blue: 0.6980392157, alpha: 1)),
                UserGroupMemberPresentable(name: "Stacey Francis 🛳", role: "Senior iOS Engineer", avatarBackgroundColor: #colorLiteral(red: 0.8784313725, green: 0.8745098039, blue: 0.9921568627, alpha: 1)),
                UserGroupMemberPresentable(name: "Petra Gazaway 🏡", role: "Senior iOS Product Engineer - Enterprise", avatarBackgroundColor: #colorLiteral(red: 0.9725490196, green: 0.937254902, blue: 0.4666666667, alpha: 1)),
                UserGroupMemberPresentable(name: "Jermaine Gill ⛷", role: "Staff Engineer - Mobile Infra", avatarBackgroundColor: #colorLiteral(red: 0.9490196078, green: 0.7568627451, blue: 0.9803921569, alpha: 1)),
                UserGroupMemberPresentable(name: "Juana Brooks 🚌", role: "Staff Software Engineer", avatarBackgroundColor: #colorLiteral(red: 0.9960784314, green: 0.8823529412, blue: 0.6980392157, alpha: 1)),
                UserGroupMemberPresentable(name: "Stacey Francis 🛳", role: "Senior iOS Engineer", avatarBackgroundColor: #colorLiteral(red: 0.8784313725, green: 0.8745098039, blue: 0.9921568627, alpha: 1)),
                UserGroupMemberPresentable(name: "Juana Brooks 🚌", role: "Staff Software Engineer", avatarBackgroundColor: #colorLiteral(red: 0.9960784314, green: 0.8823529412, blue: 0.6980392157, alpha: 1)),
                UserGroupMemberPresentable(name: "Stacey Francis 🛳", role: "Senior iOS Engineer", avatarBackgroundColor: #colorLiteral(red: 0.8784313725, green: 0.8745098039, blue: 0.9921568627, alpha: 1))
            ]
            
            self.tableView.reloadData()
            self.tableView.layoutIfNeeded()
            
            self.panModalSetNeedsLayoutUpdateWithTransition(to: .longForm, animated: true)
        }
    }
}

// MARK: - UITableViewDataSource
extension TableViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return members.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? UserGroupMemberCell
        else {
            return UITableViewCell()
        }

        cell.configure(with: members[indexPath.row])
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60.0
    }
}

// MARK: - PanModalPresentable
extension TableViewController: YSPanModalPresentable {
    
    var panScrollable: UIScrollView? {
        return tableView
    }

    var anchorModalToLongForm: Bool {
        return false
    }
    
    var longFormHeight: YSPanModalHeight {
        return .contentHeight(tableView.contentSize.height)
    }
    
    var indicatorBackgroundColor: UIColor {
        return tableView.backgroundColor ?? .white
    }
    
    var controllerTitle: String {
        return "Table"
    }
}
