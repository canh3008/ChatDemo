//
//  NewConversationViewController.swift
//  ChatDemo
//
//  Created by Duc Canh on 17/04/2023.
//

import UIKit

class NewConversationViewController: BaseViewController {

    @IBOutlet private weak var tableView: UITableView!

    private var models: [String] = []

    private let searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.placeholder = "Search for Users..."
        return searchBar
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.delegate = self
        setupTableView()
    }

    override func setupUI() {
        super.setupUI()
        navigationController?.navigationBar.topItem?.titleView = searchBar
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Cancel",
                                                            style: .done,
                                                            target: self,
                                                            action: #selector(didTapCancel))
        searchBar.becomeFirstResponder()
    }

    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(nibWithCellClass: BaseEmptyTableViewCell.self)
    }

    @objc func didTapCancel() {
        dismiss(animated: true)
    }

}

extension NewConversationViewController: UISearchBarDelegate {

}

extension NewConversationViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return models.isEmpty ? 1 : models.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        if models.isEmpty {
            let cell = tableView.dequeueReusableCell(withClass: BaseEmptyTableViewCell.self)
            cell.config(with: "No Result")
            return cell
        } else {
            return UITableViewCell()
        }

    }
}
