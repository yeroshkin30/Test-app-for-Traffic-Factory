//
//  MainView.swift
//  Test task
//
//  Created by oleh yeroshkin on 04.06.2024.
//

import UIKit

final class MainView: UIView {

    // MARK: - Private properties

    private let tableView: UITableView = .init()

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

        setupConstraints()
    }

    func setupConstraints() {

    }
}
