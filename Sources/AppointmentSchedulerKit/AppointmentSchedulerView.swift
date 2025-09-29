//
//  AppointmentSchedulerView.swift
//  AppointmentSchedulerKit
//
//  Created by ALDRICH GONZALEZ GOMEZ on 29/09/25.
//

import SwiftUI

@MainActor
public struct AppointmentSchedulerView: View {
  private let config: SchedulerConfig
  private let provider: SlotProvider
  private let onBooked: (Appointment) -> Void

  @State private var selectedDate: Date = .init()
  @State private var slots: [TimeSlot] = []
  @State private var isLoading = false
  @State private var selectedSlot: TimeSlot?
  @State private var notes: String = ""
  @State private var errorMessage: String?

  public init(
    config: SchedulerConfig = .init(),
    provider: SlotProvider,
    onBooked: @escaping (Appointment) -> Void
  ) {
    self.config = config
    self.provider = provider
    self.onBooked = onBooked
  }

  public var body: some View {
    NavigationView {
      VStack(spacing: 12) {
        DatePicker("Fecha", selection: $selectedDate, displayedComponents: .date)
          .datePickerStyle(.compact)
          .padding(.horizontal)

        content

        if config.canAddNotes {
          TextField("Notas (opcional)", text: $notes)
            .textFieldStyle(.roundedBorder)
            .padding(.horizontal)
        }

        Button(action: book) {
          Text("Confirmar cita").frame(maxWidth: .infinity)
        }
        .buttonStyle(.borderedProminent)
        .disabled(selectedSlot == nil)
        .padding(.horizontal)
        .padding(.bottom)
      }
      .navigationTitle(config.title)
      .toolbar {
        ToolbarItem(placement: .topBarTrailing) {
          Button("Actualizar", action: loadSlots)
        }
      }
      .onAppear(perform: loadSlots)
      .onChange(of: selectedDate) { _ in loadSlots() }
    }
  }

  @ViewBuilder
  private var content: some View {
    if isLoading {
      ProgressView("Cargando horarios…").padding()
    } else if let errorMessage {
      VStack(spacing: 8) {
        Text(errorMessage).foregroundStyle(.red)
        Button("Reintentar", action: loadSlots)
      }
      .padding(.horizontal)
    } else if slots.isEmpty {
      Text("No hay horarios disponibles para esta fecha.").padding()
    } else {
      List(slots) { slot in
        Button {
          selectedSlot = slot
        } label: {
          HStack {
            VStack(alignment: .leading) {
              Text(hourRange(slot)).font(.headline)
              if !slot.isAvailable {
                Text("No disponible").font(.caption).foregroundStyle(.secondary)
              }
            }
            Spacer()
            if selectedSlot == slot {
              Image(systemName: "checkmark.circle.fill")
            }
          }
        }
        .disabled(!slot.isAvailable)
      }
      .listStyle(.insetGrouped)
    }
  }

  private func hourRange(_ slot: TimeSlot) -> String {
    let fmt = DateFormatter()
    fmt.timeStyle = .short
    return "\(fmt.string(from: slot.start)) – \(fmt.string(from: slot.end))"
  }

  private func loadSlots() {
    isLoading = true
    errorMessage = nil
    Task {
      do {
        let fetched = try await provider.fetchSlots(for: selectedDate)
        slots = fetched
        isLoading = false
      } catch {
        isLoading = false
        errorMessage = "No se pudieron cargar horarios."
      }
    }
  }

  private func book() {
    guard let slot = selectedSlot else { return }
    isLoading = true
    errorMessage = nil
    Task {
      do {
        let appt = try await provider.book(slot: slot, notes: notes.isEmpty ? nil : notes)
        isLoading = false
        onBooked(appt)
      } catch {
        isLoading = false
        errorMessage = "No se pudo crear la cita."
      }
    }
  }
}
