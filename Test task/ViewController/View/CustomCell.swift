//
//  CustomCell.swift
//  Test task
//
//  Created by oleh yeroshkin on 04.06.2024.
//

import UIKit

final class CustomCell: UITableViewCell {

    var onReloadImage: (() -> Void)?
    var configuration: Configuration? {
        didSet {
            configurationDidChange(with: configuration)
        }
    }

    // MARK: - Private properties

    private let customImage: UIImageView = .init()
    private let titleLabel: UILabel = .init()
    private let descriptionLabel: UILabel = .init()
    private let loaderView: UIActivityIndicatorView = .init()
    private let retryButton: UIButton = .init(configuration: .bordered())

    // MARK: - Initialisers

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Overrides

    override func prepareForReuse() {
        super.prepareForReuse()
        customImage.image = nil
        titleLabel.text = nil
        descriptionLabel.text = nil
        retryButton.isHidden = true
        loaderView.stopAnimating()
    }
}

// MARK: - Private properties

private extension CustomCell {
    func setupView() {
        selectionStyle = .none
        customImage.layer.cornerRadius = 10
        customImage.clipsToBounds = true
        loaderView.hidesWhenStopped = true

        setupLabels()
        setupButton()
        setupConstraints()
    }

    func setupLabels() {
        titleLabel.font = .systemFont(ofSize: 16, weight: .bold)
        descriptionLabel.font = .systemFont(ofSize: 14)
        descriptionLabel.numberOfLines = 0
    }

    func setupButton() {
        retryButton.configuration?.title = "Retry"
        retryButton.isHidden = true
        retryButton.addAction(
            UIAction { [unowned self] _ in
                onReloadImage?()
            },
            for: .touchUpInside
        )
    }

    func setupConstraints() {
        [customImage, loaderView, retryButton, titleLabel, descriptionLabel].forEach {
            contentView.addSubview($0)
        }

        let margin: CGFloat = 8
        customImage.layout {
            $0.top == contentView.topAnchor + margin
            $0.leading == contentView.leadingAnchor + margin
            $0.trailing == contentView.trailingAnchor - margin
            $0.height == $0.width
        }

        loaderView.layout {
            $0.centerX == customImage.centerXAnchor
            $0.centerY == customImage.centerYAnchor
            $0.width == 20
            $0.height == $0.width
        }

        retryButton.layout {
            $0.centerX == customImage.centerXAnchor
            $0.centerY == customImage.centerYAnchor
        }

        titleLabel.layout {
            $0.top == customImage.bottomAnchor + margin / 2
            $0.leading == contentView.leadingAnchor + margin
            $0.trailing == contentView.trailingAnchor - margin
        }

        descriptionLabel.layout {
            $0.top == titleLabel.bottomAnchor + margin / 2
            $0.leading == contentView.leadingAnchor + margin
            $0.trailing == contentView.trailingAnchor - margin
            $0.bottom == contentView.bottomAnchor - margin
        }
    }
}

extension CustomCell {
    func configurationDidChange(with configuration: Configuration?) {
        guard let configuration else { return }

        titleLabel.text = configuration.title
        descriptionLabel.text = configuration.subtitle

        switch configuration.imageState {
        case .loading:
            retryButton.isHidden = true
            loaderView.startAnimating()
        case .loaded(let image):
            loaderView.stopAnimating()
            customImage.image = image
        case .failed:
            loaderView.stopAnimating()
            retryButton.isHidden = false
        }
    }

    struct Configuration {
        let title: String?
        let subtitle: String?
        var imageState: ImageLoadingState
    }

    enum ImageLoadingState {
        case loading
        case loaded(UIImage)
        case failed
    }
}
