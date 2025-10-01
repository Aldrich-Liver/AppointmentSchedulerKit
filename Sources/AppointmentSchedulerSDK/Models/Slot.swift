//
//  Appoinment.swift
//  AppointmentSchedulerKit
//
//  Created by ALDRICH GONZALEZ GOMEZ on 01/10/25.
//

import Foundation

public struct Slot: Identifiable, Codable, Equatable {
    public let id: Int
    public let title: String
    public let startDate: Date
    public let endDate: Date
    public let available: Bool

    public init(id: Int, title: String, startDate: Date, endDate: Date, available: Bool) {
        self.id = id
        self.title = title
        self.startDate = startDate
        self.endDate = endDate
        self.available = available
    }
}
