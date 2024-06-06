//
//  NetworkController.swift
//  Test task
//
//  Created by oleh yeroshkin on 04.06.2024.
//

import UIKit

enum Errors: Error {
    case dataNotFound
    case photoDataNotFound
    case cantCreateImageFromData
}

class NetworkController {

    // MARK: - Private properties

    private let session: URLSession

    // MARK: - Initialisers

    init() {
        let configuration = URLSessionConfiguration.default
        configuration.urlCache = URLCache(
            memoryCapacity: 50 * 1024 * 1024,
            diskCapacity: 150 * 1024 * 1024,
            diskPath: "customCache"
        )
        configuration.requestCachePolicy = .useProtocolCachePolicy

        self.session =  URLSession(configuration: configuration)
    }

    // MARK: - Public methods

    func fetch<Response: Codable>(from url: URL) async throws -> Response {
        let (data, response) = try await session.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw Errors.dataNotFound
        }
        let searchResults = try JSONDecoder().decode(Response.self, from: data)

        return searchResults
    }

    func fetchImage(from url: URL) async throws -> UIImage {
        let (data, response) = try await session.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw Errors.photoDataNotFound
        }

        guard let image = UIImage(data: data) else {
            throw Errors.cantCreateImageFromData
        }

        return image
    }
}
