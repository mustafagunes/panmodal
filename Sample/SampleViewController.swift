//
//  SampleViewController.swift
//  PanModal
//
//  Created by Stephen Sowole on 10/9/18.
//  Copyright © 2018 PanModal. All rights reserved.
//

import UIKit

class SampleViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }

    private func setupView() {
        title = "PanModal"

        navigationController?.navigationBar.titleTextAttributes = [
            .font: UIFont(name: "Lato-Bold", size: 17)!
        ]

        tableView.register(UITableViewCell.self, forCellReuseIdentifier: String(describing: UITableViewCell.self))
        tableView.tableFooterView = UIView()
        tableView.separatorInset = .zero
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60.0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return RowType.allCases.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: UITableViewCell.self), for: indexPath)

        guard let rowType = RowType(rawValue: indexPath.row) else {
            return cell
        }
        cell.textLabel?.textAlignment = .center
        cell.textLabel?.text = rowType.presentable.string
        cell.textLabel?.font = UIFont(name: "Lato-Regular", size: 17.0)
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        guard let rowType = RowType(rawValue: indexPath.row) else {
            return
        }
        
        dismiss(animated: true, completion: nil)
        presentPanModal(rowType.presentable.rowVC)
    }
}

protocol RowPresentable {
    var string: String { get }
    var rowVC: UIViewController & PanModalPresentable { get }
}

private extension SampleViewController {

    enum RowType: Int, CaseIterable {
        case basic
        case table
        case navController

        var presentable: RowPresentable {
            switch self {
            case .basic: return Basic()
            case .table: return Table()
            case .navController: return Navigation()
            }
        }

        struct Basic: RowPresentable {
            let string: String = "Basic"
            let rowVC: PanModalPresentable.LayoutType = BasicViewController()
        }
        
        struct Table: RowPresentable {
            let string: String = "Table"
            let rowVC: PanModalPresentable.LayoutType = TableViewController()
        }

        struct Navigation: RowPresentable {
            let string: String = "NavigationController"
            let rowVC: PanModalPresentable.LayoutType = NavigationController()
        }
    }
}
