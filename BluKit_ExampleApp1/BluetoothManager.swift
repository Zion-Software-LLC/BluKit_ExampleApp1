//
//  BluetoothManager.swift
//  BluKit_ExampleApp1
//
//  Copyright Zion Software, LLC.
//

import Foundation
import BluKit
import Combine

class BluetoothManager: NSObject, ObservableObject {
    private var centralManager: CentralManager!
    @Published var discoveredPeripherals: [BluetoothPeripheral] = []
    private var cancellables = Set<AnyCancellable>()

    override init() {
        super.init()
        centralManager = CentralManager(delegate: self, queue: .main)
    }

    func startScanning() {
        guard centralManager.state == .poweredOn else { return }
        centralManager.scanForPeripherals(withServices: nil, options: nil)
    }

    func connect(peripheral: BluetoothPeripheral) {
        centralManager.connect(peripheral.peripheral, options: nil)
    }

    func disconnect(peripheral: BluetoothPeripheral) {
        centralManager.cancelPeripheralConnection(peripheral.peripheral)
    }

    private func updatePeripheral(_ updatedPeripheral: BluetoothPeripheral) {
        DispatchQueue.main.async { [weak self] in
            if let index = self?.discoveredPeripherals.firstIndex(where: { $0.peripheral.identifier == updatedPeripheral.peripheral.identifier }) {
                self?.discoveredPeripherals[index] = updatedPeripheral
            } else {
                self?.discoveredPeripherals.append(updatedPeripheral)
            }
        }
    }

}

extension BluetoothManager: CentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CentralManager) {
        if central.state == .poweredOn {
            startScanning()
        }
    }

    func centralManager(_ central: CentralManager, didDiscover peripheral: Peripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        let bluetoothPeripheral = BluetoothPeripheral(peripheral: peripheral, advertisementData: advertisementData, rssi: RSSI)
        updatePeripheral(bluetoothPeripheral)
    }

    func centralManager(_ central: CentralManager, didConnect peripheral: Peripheral) {
        if let updatedPeripheral = discoveredPeripherals.first(where: { $0.peripheral.identifier == peripheral.identifier }) {
            updatedPeripheral.isConnected = true
            peripheral.delegate = self
            peripheral.discoverServices(nil)
        }
    }

    func centralManager(_ central: CentralManager, didDisconnectPeripheral peripheral: Peripheral, error: (any Error)?) {
        if let updatedPeripheral = discoveredPeripherals.first(where: { $0.peripheral.identifier == peripheral.identifier }) {
            updatedPeripheral.isConnected = false
            peripheral.delegate = nil
        }
    }

}

extension BluetoothManager: PeripheralDelegate {
    func peripheral(_ peripheral: Peripheral, didDiscoverServices error: Error?) {
        guard let services = peripheral.services else { return }

        DispatchQueue.main.async { [weak self] in
            if let updatedPeripheral = self?.discoveredPeripherals.first(where: { $0.peripheral.identifier == peripheral.identifier }) {
                updatedPeripheral.discoveredServices = services.map { service in
                    ServiceDetail(service: service)
                }
            }
        }
    }

    func peripheral(_ peripheral: Peripheral, didDiscoverCharacteristicsFor service: Service, error: Error?) {
        guard let characteristics = service.characteristics else { return }

        DispatchQueue.main.async { [weak self] in
            if let updatedPeripheral = self?.discoveredPeripherals.first(where: { $0.peripheral.identifier == peripheral.identifier }),
               let updatedService = updatedPeripheral.discoveredServices.first(where: { $0.uuid == service.uuid }) {
                updatedService.discoveredCharacteristics = characteristics.map { characteristic in
                    CharacteristicDetail(characteristic: characteristic)
                }
            }
        }
    }

}
