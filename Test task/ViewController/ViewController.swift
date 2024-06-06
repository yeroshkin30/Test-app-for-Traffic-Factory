//
//  ViewController.swift
//  Test task
//
//  Created by oleh yeroshkin on 04.06.2024.
//

import UIKit

final class ViewController: UIViewController {

    // MARK: - Private properties

    private let mainView: MainView = .init()
    private var items: [Item] = []
    private let networkController: NetworkController
    private var imageTasks: [IndexPath: Task<Void, Never>] = [:]

    // MARK: - Initialisers

    init(network: NetworkController = .init()) {
        self.networkController = network
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Overrides

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }

    override func loadView() {
        super.loadView()
        view = mainView
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        fetchInitialData()
    }
}

// MARK: - Private properties

private extension ViewController {
    func setup() {
        mainView.tableView.dataSource = self
        mainView.tableView.delegate = self
    }

    func fetchInitialData() {
        mainView.isLoading = true
        let url: URL = .init(string: "https://496.ams3.cdn.digitaloceanspaces.com/data/test.json")!
        Task {
            try? await Task.sleep(for: .seconds(3))
            items = try await networkController.fetch(from: url)
            mainView.tableView.reloadData()
            mainView.isLoading = false
        }
    }
}

extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: CustomCell = tableView.dequeueCell(for: indexPath)
        let item = items[indexPath.row]
        cell.configuration = .init(title: item.title, subtitle: item.description, imageState: .loading)
        cell.onReloadImage = { [unowned self, weak cell] in
            guard let cell else { return }
            getImage(from: item.imageURL, for: cell, indexPath: indexPath)
        }

        getImage(from: item.imageURL, for: cell, indexPath: indexPath)

        return cell
    }

    func getImage(from url: URL, for cell: CustomCell, indexPath: IndexPath) {
        cell.configuration?.imageState = .loading
        imageTasks[indexPath] = Task {
            defer { imageTasks[indexPath] = nil }
            var image: UIImage?

            do {
                image = try await networkController.fetchImage(from: url)
            } catch {
                print(error)
            }
            
            if !Task.isCancelled {
                cell.configuration?.imageState = image.map { .loaded($0) } ?? .failed
            }

            imageTasks.removeValue(forKey: indexPath)
        }
    }
}

extension ViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        imageTasks[indexPath]?.cancel()
        imageTasks.removeValue(forKey: indexPath)
    }
}
