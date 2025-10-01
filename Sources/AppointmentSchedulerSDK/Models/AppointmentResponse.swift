//
//  AppointmentResponse.swift
//  AppointmentSchedulerSDK
//
//  Created by ALDRICH GONZALEZ GOMEZ on 01/10/25.
//

import Foundation

public struct AppointmentResponse: Codable, Equatable {
    public let id: Int
    public let slotId: Int
    public let confirmationCode: String
    public let createdAt: Date

    public init(id: Int, slotId: Int, confirmationCode: String, createdAt: Date) {
        self.id = id
        self.slotId = slotId
        self.confirmationCode = confirmationCode
        self.createdAt = createdAt
    }
}
