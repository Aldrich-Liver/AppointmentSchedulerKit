//
//  SlotProvider.swift
//  AppointmentSchedulerKit
//
//  Created by ALDRICH GONZALEZ GOMEZ on 29/09/25.
//

import Foundation

public enum SchedulerError: Error {
  case network
  case unavailable
  case unknown
}

public protocol SlotProvider: Sendable {
  /// Devuelve slots disponibles para una fecha dada
  func fetchSlots(for date: Date) async throws -> [TimeSlot]

  /// Intenta crear la cita con el slot seleccionado
  func book(slot: TimeSlot, notes: String?) async throws -> Appointment
}
