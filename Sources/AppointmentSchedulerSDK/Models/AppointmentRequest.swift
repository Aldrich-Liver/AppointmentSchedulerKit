//
//  AppointmentRequest.swift
//  AppointmentSchedulerSDK
//
//  Created by ALDRICH GONZALEZ GOMEZ on 01/10/25.
//

import Foundation

public struct AppointmentRequest: Codable {
    public let slotId: Int
    public let client: ClientInfo
    public let notes: String?

    public init(slotId: Int, client: ClientInfo, notes: String? = nil) {
        self.slotId = slotId
        self.client = client
        self.notes = notes
    }
}
