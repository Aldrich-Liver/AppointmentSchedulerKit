//
//  API.swift
//  AppointmentSchedulerKit
//
//  Created by ALDRICH GONZALEZ GOMEZ on 01/10/25.
//

import Foundation

public final class APIClient {
    public struct Config {
        public var baseURL: URL
        public var urlSession: URLSession
        public var jsonDecoder: JSONDecoder
        public var jsonEncoder: JSONEncoder

        public init(baseURL: URL,
                    urlSession: URLSession = .shared,
                    jsonDecoder: JSONDecoder = JSONDecoder(),
                    jsonEncoder: JSONEncoder = JSONEncoder()) {
            self.baseURL = baseURL
            self.urlSession = urlSession
            self.jsonDecoder = jsonDecoder
            self.jsonEncoder = jsonEncoder
        }
    }

    public enum APIError: Error { case invalidURL, badStatus(Int), decoding, encoding }

    public var config: Config

    public init(config: Config) {
        self.config = config
        self.config.jsonDecoder.dateDecodingStrategy = .iso8601
        self.config.jsonEncoder.dateEncodingStrategy = .iso8601
    }

    // MARK: - Endpoints demo (JSONPlaceholder)
    // Slots: GET /todos (limit) => se mapean a slots con fechas sintéticas.
    // Crear cita: POST /posts retorna id simulado.

    public func fetchSlots(limit: Int = 10) async throws -> [Slot] {
        let url = config.baseURL.appending(path: "/todos")
        var components = URLComponents(url: url, resolvingAgainstBaseURL: false)
        components?.queryItems = [URLQueryItem(name: "_limit", value: String(limit))]
        guard let finalURL = components?.url else { throw APIError.invalidURL }

        let (data, response) = try await config.urlSession.data(from: finalURL)
        guard let http = response as? HTTPURLResponse, (200..<300).contains(http.statusCode) else {
            throw APIError.badStatus((response as? HTTPURLResponse)?.statusCode ?? -1)
        }

        struct Todo: Decodable { let id: Int; let title: String; let completed: Bool }
        let todos = try config.jsonDecoder.decode([Todo].self, from: data)

        let now = Date()
        let calendar = Calendar.current

        let slots: [Slot] = todos.enumerated().map { idx, t in
            let start = calendar.date(byAdding: .minute, value: idx * 30, to: now) ?? now
            let end = calendar.date(byAdding: .minute, value: 30, to: start) ?? start.addingTimeInterval(1800)
            return Slot(id: t.id, title: t.title.capitalized, startDate: start, endDate: end, available: !t.completed)
        }
        return slots
    }

    public func createAppointment(_ request: AppointmentRequest) async throws -> AppointmentResponse {
        let url = config.baseURL.appending(path: "/posts")
        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.httpBody = try config.jsonEncoder.encode(request)

        let (data, response) = try await config.urlSession.data(for: req)
        guard let http = response as? HTTPURLResponse, (200..<300).contains(http.statusCode) else {
            throw APIError.badStatus((response as? HTTPURLResponse)?.statusCode ?? -1)
        }

        struct PostResp: Decodable { let id: Int }
        let post = try config.jsonDecoder.decode(PostResp.self, from: data)

        return AppointmentResponse(
            id: post.id,
            slotId: request.slotId,
            confirmationCode: "CONF-\(post.id)-\(Int(Date().timeIntervalSince1970))",
            createdAt: Date()
        )
    }
}
