//
//  NewConversationViewController.swift
//  ChatDemo
//
//  Created by Duc Canh on 17/04/2023.
//

import UIKit
import RxSwift

class NewConversationViewController: BaseViewController {

    @IBOutlet private weak var tableView: UITableView!

    var completion: ((User) -> Void)?
    private lazy var models: [User] = [] {
        didSet {
            tableView.reloadData()
        }
    }
    private var textSearchSubject = PublishSubject<String>()
    private let viewModel: NewConversationViewModel

    init(viewModel: NewConversationViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

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

    override func bindingData() {
        super.bindingData()
        let input = NewConversationViewModel.Input(textSearch: textSearchSubject)

        let output = viewModel.transform(input: input)

        output
            .allUsers
            .drive { [weak self] users in
                guard let self = self else {
                    return
                }
                self.models = users
            }
            .disposed(by: disposeBag)
    }

    override func setupUI() {
        super.setupUI()
        navigationController?.navigationBar.topItem?.titleView = searchBar
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Cancel",
                                                            style: .done,
                                                            target: self,
                                                            action: #selector(didTapCancel))
    }

    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(nibWithCellClass: BaseEmptyTableViewCell.self)
        tableView.register(nibWithCellClass: NewConversationTableViewCell.self)
    }

    @objc func didTapCancel() {
        dismiss(animated: true)
    }

}

extension NewConversationViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let text = searchBar.text else {
            return
        }
        self.textSearchSubject.onNext(text)
    }
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
            guard indexPath.row < models.count else {
                return UITableViewCell()
            }
            let cell = tableView.dequeueReusableCell(withClass: NewConversationTableViewCell.self)
            cell.config(with: models[indexPath.row].name)
            return cell
        }

    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard indexPath.row < models.count else {
            return
        }
        self.dismiss(animated: true) { [weak self] in
            guard let self = self else {
                return
            }
            self.completion?(self.models[indexPath.row])
        }
    }
}
