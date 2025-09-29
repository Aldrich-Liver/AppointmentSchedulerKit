//
//  SlotModels.swift
//  AppointmentSchedulerKit
//
//  Created by ALDRICH GONZALEZ GOMEZ on 29/09/25.
//

import Foundation

public struct TimeSlot: Identifiable, Hashable, Sendable {
  public let id: UUID
  public let start: Date
  public let end: Date
  public let isAvailable: Bool

  public init(id: UUID = .init(), start: Date, end: Date, isAvailable: Bool) {
    self.id = id
    self.start = start
    self.end = end
    self.isAvailable = isAvailable
  }
}

public struct Appointment: Identifiable, Sendable {
  public let id: UUID
  public let slot: TimeSlot
  public let notes: String?

  public init(id: UUID = .init(), slot: TimeSlot, notes: String?) {
    self.id = id
    self.slot = slot
    self.notes = notes
  }
}

