//
//  MainView.swift
//  Test task
//
//  Created by oleh yeroshkin on 04.06.2024.
//

import UIKit

final class MainView: UIView {

    var isLoading = false {
        didSet {
            isLoading ? loadingView.startAnimating() : loadingView.stopAnimating()
        }
    }
    let tableView: UITableView = .init()

    // MARK: - Private properties

    private let loadingView: UIActivityIndicatorView = .init(style: .large)

    // MARK: - Initialisers

    init() {
        super.init(frame: .zero)
        setupView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Private properties

private extension MainView {
    func setupView() {
        backgroundColor = .white
        loadingView.hidesWhenStopped = true
        loadingView.color = .gray

        setupTableView()
        setupConstraints()
    }
    
    func setupTableView() {
        tableView.register(CustomCell.self, forCellReuseIdentifier: CustomCell.identifier)
    }

    func setupConstraints() {
        tableView.layout(in: self) {
            $0.top == topAnchor
            $0.leading == leadingAnchor
            $0.trailing == trailingAnchor
            $0.bottom == bottomAnchor
        }
        addSubview(loadingView)
        loadingView.layout(in: self) {
            $0.centerX == centerXAnchor
            $0.centerY == centerYAnchor
            $0.width == 30
            $0.height == $0.width
        }
        loadingView.startAnimating()
    }
}
