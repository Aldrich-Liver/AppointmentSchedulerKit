//
//  SchedulerConfig.swift
//  AppointmentSchedulerKit
//
//  Created by ALDRICH GONZALEZ GOMEZ on 29/09/25.
//

import Foundation

public struct SchedulerConfig: Sendable {
  public let title: String
  public let canAddNotes: Bool

  public init(title: String = "Agendar cita", canAddNotes: Bool = true) {
    self.title = title
    self.canAddNotes = canAddNotes
  }
}

