//
//  BluetoothPeripheral.swift
//  BluKit_ExampleApp1
//
//  Copyright Zion Software, LLC.
//

import Foundation
import CoreBluetooth

class BluetoothPeripheral: NSObject, Identifiable, ObservableObject {
    let peripheral: CBPeripheral

    var id: UUID {
        peripheral.identifier
    }

    var name: String {
        peripheral.name ?? peripheral.identifier.uuidString
    }

    let advertisementData: [String: Any]
    let rssi: NSNumber
    @Published var isConnected: Bool = false
    @Published var discoveredServices: [ServiceDetail] = []

    var isConnectable: Bool {
        let isConnectable = advertisementData[CBAdvertisementDataIsConnectable] as? NSNumber
        return isConnectable?.boolValue ?? false
    }

    init(peripheral: CBPeripheral, advertisementData: [String : Any], rssi: NSNumber) {
        self.peripheral = peripheral
        self.advertisementData = advertisementData
        self.rssi = rssi
    }

    // Implement Equatable to prevent unnecessary redraws
    static func == (lhs: BluetoothPeripheral, rhs: BluetoothPeripheral) -> Bool {
        lhs.id == rhs.id
    }
}

class ServiceDetail: NSObject, Identifiable, ObservableObject {
    let service: CBService

    var id: CBUUID {
        service.uuid
    }

    @Published var discoveredCharacteristics: [CharacteristicDetail] = []

    var uuid: CBUUID {
        service.uuid
    }

    var name: String {
        serviceNameForUUID(uuid)
    }

    init(service: CBService) {
        self.service = service
    }

    private func serviceNameForUUID(_ uuid: CBUUID) -> String {
        // Add known service mappings
        let knownServices: [String: String] = [
            "180F": "Battery Service",
            "180A": "Device Information",
            "1800": "Generic Access",
            "1801": "Generic Attribute"
            // Add more known services as needed
        ]

        return knownServices[uuid.uuidString.prefix(4).uppercased()] ?? "Unknown Service"
    }

    // Implement Equatable to prevent unnecessary redraws
    static func == (lhs: ServiceDetail, rhs: ServiceDetail) -> Bool {
        lhs.id == rhs.id
    }
}

struct CharacteristicDetail: Identifiable {
    let characteristic: CBCharacteristic
    let id = UUID()

    var uuid: CBUUID {
        characteristic.uuid
    }

    var name: String {
        characteristicNameForUUID(uuid)
    }

    var value: Data? {
        characteristic.value
    }

    private func characteristicNameForUUID(_ uuid: CBUUID) -> String {
        // Add known characteristics mappings
        let knownCharacteristics: [String: String] = [
            "180F": "Battery Service",
            "180A": "Device Information",
            "1800": "Generic Access",
            "1801": "Generic Attribute"
            // Add more known characteristics as needed
        ]

        return knownCharacteristics[uuid.uuidString.prefix(4).uppercased()] ?? "Unknown Characteristic"
    }

    // Implement Equatable to prevent unnecessary redraws
    static func == (lhs: CharacteristicDetail, rhs: CharacteristicDetail) -> Bool {
        lhs.id == rhs.id
    }
}
