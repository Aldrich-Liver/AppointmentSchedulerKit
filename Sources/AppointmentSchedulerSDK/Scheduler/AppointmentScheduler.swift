//
//  AppointmentScheduler.swift
//  AppointmentSchedulerSDK
//
//  Created by ALDRICH GONZALEZ GOMEZ on 01/10/25.
//

import Foundation

public final class AppointmentScheduler: ObservableObject {
    @Published public private(set) var slots: [Slot] = []
    @Published public private(set) var isLoading: Bool = false
    @Published public private(set) var lastResponse: AppointmentResponse?

    private let api: APIClient

    public init(apiClient: APIClient) {
        self.api = apiClient
    }

    public func refreshSlots(limit: Int = 10) async {
        isLoading = true
        defer { isLoading = false }
        do {
            let result = try await api.fetchSlots(limit: limit)
            await MainActor.run { self.slots = result }
        } catch {
            await MainActor.run { self.slots = [] }
            print("[AppointmentScheduler] Error fetching slots: \(error)")
        }
    }

    @discardableResult
    public func book(slot: Slot, client: ClientInfo, notes: String? = nil) async -> AppointmentResponse? {
        do {
            let req = AppointmentRequest(slotId: slot.id, client: client, notes: notes)
            let resp = try await api.createAppointment(req)
            await MainActor.run { self.lastResponse = resp }
            return resp
        } catch {
            print("[AppointmentScheduler] Error creating appointment: \(error)")
            return nil
        }
    }
}
