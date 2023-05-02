//
//  ProfileViewController.swift
//  ChatDemo
//
//  Created by Duc Canh on 17/04/2023.
//

import UIKit
import RxDataSources
import RxCocoa
import RxSwift

class ProfileViewController: BaseViewController {

    @IBOutlet private weak var tableView: UITableView!
    private let viewModel: ProfileViewModel

    init(viewModel: ProfileViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
    }

    override func setupUI() {
        super.setupUI()
        title = "Profile"
        self.navigationController?.navigationBar.prefersLargeTitles = true
    }

    override func bindingData() {
        super.bindingData()
        let input = ProfileViewModel.Input(selectedItem: tableView.rx.modelSelected(Profile.self).asObservable())

        let output = viewModel.transform(input: input)

        output
            .logOutSuccess
            .drive { [weak self] _ in
                let viewController = LoginViewController(viewModel: LoginViewModel())
                let navigation = UINavigationController(rootViewController: viewController)
                navigation.modalPresentationStyle = .fullScreen
                navigation.modalTransitionStyle = .crossDissolve
                self?.present(navigation, animated: true)
            }
            .disposed(by: disposeBag)

        output
            .error
            .drive(rx.showMessageError)
            .disposed(by: disposeBag)

        output
            .models
            .drive(tableView.rx.items(dataSource: getDataSourceAnimated()))
            .disposed(by: disposeBag)

    }

    private func setupTableView() {
        tableView.register(nibWithCellClass: ProfileTableViewCell.self)
    }

    private func getDataSourceAnimated() -> RxTableViewSectionedAnimatedDataSource<ProfileSection> {
        let datasource = RxTableViewSectionedAnimatedDataSource<ProfileSection> { _, tableView, _, item in
            let cell = tableView.dequeueReusableCell(withClass: ProfileTableViewCell.self)
            switch  item {
            case .logout(title: let title):
                cell.config(with: title)
            }
            return cell
        }
        return datasource
    }
}
