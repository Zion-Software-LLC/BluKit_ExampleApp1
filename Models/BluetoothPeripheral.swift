//
//  BluetoothPeripheral.swift
//  BlueKit_ExampleApp1
//
//  Copyright Zion Software, LLC.
//

import Foundation
import CoreBluetooth
import BluKit

class BluetoothPeripheral: NSObject, Identifiable, ObservableObject {
    let peripheral: Peripheral

    var id: UUID {
        peripheral.identifier
    }

    var name: String {
        peripheral.name ?? peripheral.identifier.uuidString
    }

    let advertisementData: [String: Any]
    let rssi: NSNumber
    @Published var isConnected: Bool = false {
        didSet {
            isAttemptingToConnect = false
            isAttemptingToDisconnect = false
        }
    }
    @Published var isAttemptingToConnect: Bool = false
    @Published var isAttemptingToDisconnect: Bool = false
    @Published var discoveredServices: [ServiceDetail] = []

    var isConnectable: Bool {
        let isConnectable = advertisementData[CBAdvertisementDataIsConnectable] as? NSNumber
        return isConnectable?.boolValue ?? false
    }

    init(peripheral: Peripheral, advertisementData: [String : Any], rssi: NSNumber) {
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
    let service: Service

    var id: CBUUID {
        service.uuid
    }

    @Published var discoveredCharacteristics: [CharacteristicDetail] = []

    var uuid: CBUUID {
        service.uuid
    }

    var name: String {
        service.displayName
    }

    init(service: Service) {
        self.service = service
    }

    // Implement Equatable to prevent unnecessary redraws
    static func == (lhs: ServiceDetail, rhs: ServiceDetail) -> Bool {
        lhs.id == rhs.id
    }
}

struct CharacteristicDetail: Identifiable {
    let characteristic: Characteristic
    let id = UUID()

    var uuid: CBUUID {
        characteristic.uuid
    }

    var name: String {
        characteristic.displayName
    }

    var value: Data? {
        characteristic.value
    }

    var valueAsString: String {
        characteristic.description
    }

    // Implement Equatable to prevent unnecessary redraws
    static func == (lhs: CharacteristicDetail, rhs: CharacteristicDetail) -> Bool {
        lhs.id == rhs.id
    }
}
