//
//  API.swift
//  AppointmentSchedulerKit
//
//  Created by ALDRICH GONZALEZ GOMEZ on 01/10/25.
//

import Foundation

public actor APIClient {
    public struct Config: Sendable {
        public let baseURL: URL
        // URLSession y JSONEncoder/Decoder son thread-safe para uso típico,
        // pero para evitar que tengan que ser Sendable, los mantenemos internos del actor.
        public init(baseURL: URL) { self.baseURL = baseURL }
    }

    public enum APIError: Error { case invalidURL, badStatus(Int), decoding, encoding }

    private let baseURL: URL
    private let session: URLSession
    private let decoder: JSONDecoder
    private let encoder: JSONEncoder

    public init(config: Config,
                session: URLSession = .shared,
                decoder: JSONDecoder = JSONDecoder(),
                encoder: JSONEncoder = JSONEncoder()) {
        self.baseURL = config.baseURL
        self.session = session
        self.decoder = decoder
        self.encoder = encoder
        self.decoder.dateDecodingStrategy = .iso8601
        self.encoder.dateEncodingStrategy = .iso8601
    }

    // MARK: - Endpoints demo (JSONPlaceholder)

    public func fetchSlots(limit: Int = 10) async throws -> [Slot] {
        let url = baseURL.appendingPathComponent(path: "/todos")
        var components = URLComponents(url: url, resolvingAgainstBaseURL: false)
        components?.queryItems = [URLQueryItem(name: "_limit", value: String(limit))]
        guard let finalURL = components?.url else { throw APIError.invalidURL }

        let (data, response) = try await session.data(from: finalURL)
        guard let http = response as? HTTPURLResponse, (200..<300).contains(http.statusCode) else {
            throw APIError.badStatus((response as? HTTPURLResponse)?.statusCode ?? -1)
        }

        struct Todo: Decodable { let id: Int; let title: String; let completed: Bool }
        let todos = try decoder.decode([Todo].self, from: data)

        // Genera fechas sintéticas
        let now = Date()
        let calendar = Calendar.current

        return todos.enumerated().map { idx, t in
            let start = calendar.date(byAdding: .minute, value: idx * 30, to: now) ?? now
            let end = calendar.date(byAdding: .minute, value: 30, to: start) ?? start.addingTimeInterval(1800)
            return Slot(id: t.id, title: t.title.capitalized, startDate: start, endDate: end, available: !t.completed)
        }
    }

    public func createAppointment(_ request: AppointmentRequest) async throws -> AppointmentResponse {
        let url = baseURL. appendingPathComponent(path: "/posts")
        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.httpBody = try encoder.encode(request)

        let (data, response) = try await session.data(for: req)
        guard let http = response as? HTTPURLResponse, (200..<300).contains(http.statusCode) else {
            throw APIError.badStatus((response as? HTTPURLResponse)?.statusCode ?? -1)
        }

        struct PostResp: Decodable { let id: Int }
        let post = try decoder.decode(PostResp.self, from: data)

        return AppointmentResponse(
            id: post.id,
            slotId: request.slotId,
            confirmationCode: "CONF-\(post.id)-\(Int(Date().timeIntervalSince1970))",
            createdAt: Date()
        )
    }
}
