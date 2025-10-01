//
//  AppointmentScheduler.swift
//  AppointmentSchedulerSDK
//
//  Created by ALDRICH GONZALEZ GOMEZ on 01/10/25.
//

import SwiftUI

public struct AppointmentSchedulerView: View {
    @ObservedObject private var scheduler: AppointmentScheduler
    private let prefilledClient: ClientInfo?

    public init(scheduler: AppointmentScheduler, prefilledClient: ClientInfo? = nil) {
        self.scheduler = scheduler
        self.prefilledClient = prefilledClient
    }

    public var body: some View {
        List {
            if scheduler.isLoading {
                ProgressView("Cargando slots...")
            }
            ForEach(scheduler.slots) { slot in
                VStack(alignment: .leading, spacing: 6) {
                    Text(slot.title).font(.headline)
                    Text(dateRange(slot)).font(.subheadline).foregroundStyle(.secondary)
                    HStack {
                        if slot.available {
                            Button("Reservar") {
                                Task { await reservar(slot) }
                            }
                            .buttonStyle(.borderedProminent)
                        } else {
                            Text("No disponible").font(.footnote).foregroundStyle(.secondary)
                        }
                        Spacer()
                    }
                }
                .padding(.vertical, 6)
            }
            if let resp = scheduler.lastResponse {
                Section("Última confirmación") {
                    Text("Código: \(resp.confirmationCode)")
                    Text("Creado: \(resp.createdAt.formatted(date: .abbreviated, time: .shortened))")
                }
            }
        }
        .task { await scheduler.refreshSlots() }
        .navigationTitle("Agendar cita")
    }

    private func dateRange(_ slot: Slot) -> String {
        let s = slot.startDate.formatted(date: .abbreviated, time: .shortened)
        let e = slot.endDate.formatted(date: .omitted, time: .shortened)
        return "\(s) – \(e)"
    }

    private func reservar(_ slot: Slot) async {
        let client = prefilledClient ?? ClientInfo(name: "Invitado", email: "guest@example.com")
        _ = await scheduler.book(slot: slot, client: client, notes: "Demo SDK")
    }
}
