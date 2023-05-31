//
//  ConversationsViewController.swift
//  ChatDemo
//
//  Created by Duc Canh on 17/04/2023.
//

import UIKit

class ConversationsViewController: BaseViewController {

    @IBOutlet private weak var tableView: UITableView!

    private let authentication = FirebaseAuthentication()
    private let viewModel: ConversationsViewModel
    private lazy var models: [Conversation] = [] {
        didSet {
            tableView.reloadData()
        }
    }

    init(viewModel: ConversationsViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        checkAuthentication()
        setupTableView()
    }

    override func bindingData() {
        super.bindingData()
        let input = ConversationsViewModel.Input()

        let output = viewModel.transform(input: input)

        output
            .allConversations
            .drive { [weak self] conversations in
                self?.models = conversations
            }
            .disposed(by: disposeBag)

    }
    override func setupUI() {
        super.setupUI()
        title = "Chats"
        self.navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .compose,
                                                            target: self,
                                                            action: #selector(didTapCompose))
    }

    @objc func didTapCompose() {
        let newConversation = NewConversationViewController(viewModel: NewConversationViewModel())
        newConversation.completion = { [weak self] user in
            self?.createNewConversation(with: user)
        }
        let navigation = UINavigationController(rootViewController: newConversation)
        present(navigation, animated: true)
    }

    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(nibWithCellClass: ConversationsTableViewCell.self)
        tableView.register(nibWithCellClass: BaseEmptyTableViewCell.self)
    }

    private func checkAuthentication() {
        let isLoggedIn = authentication.isCurrentUser
        if !isLoggedIn {
            let viewController = LoginViewController(viewModel: LoginViewModel())
            let navigation = NavigationController(rootViewController: viewController)
            navigation.modalPresentationStyle = .fullScreen
            self.present(navigation, animated: true)
        }
    }

    private func createNewConversation(with user: User) {
        let chatViewController = ChatViewController(viewModel: ChatViewModel(user: user, isNewConversation: true))
        navigationController?.pushViewController(chatViewController, animated: true)
    }
}

extension ConversationsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return models.isEmpty ? 1 : models.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if models.isEmpty {
            let cell = tableView.dequeueReusableCell(withClass: BaseEmptyTableViewCell.self)
            cell.config(with: "No Results")
            return cell
        } else {
            guard indexPath.row < models.count else {
                return UITableViewCell()
            }
            let cell = tableView.dequeueReusableCell(withClass: ConversationsTableViewCell.self)

            cell.config(model: models[indexPath.row])
            return cell
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard indexPath.row < models.count else {
            return
        }
        let model = models[indexPath.row]
        let chatVC = ChatViewController(viewModel: ChatViewModel(user: User(name: model.name,
                                                                            email: model.otherUserEmail), id: model.id))
        self.navigationController?.pushViewController(chatVC, animated: true)
    }
}
