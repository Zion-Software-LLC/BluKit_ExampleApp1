//
//  BluetoothManager.swift
//  BluKit_ExampleApp1
//
//  Copyright Zion Software, LLC.
//

import Foundation
import CoreBluetooth
import Combine

class BluetoothManager: NSObject, ObservableObject {
    private var centralManager: CBCentralManager!
    @Published var discoveredPeripherals: [BluetoothPeripheral] = []
    private var cancellables = Set<AnyCancellable>()

    override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: .main)
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

extension BluetoothManager: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == .poweredOn {
            startScanning()
        }
    }

    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        let bluetoothPeripheral = BluetoothPeripheral(peripheral: peripheral, advertisementData: advertisementData, rssi: RSSI)
        updatePeripheral(bluetoothPeripheral)
    }

    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        if let updatedPeripheral = discoveredPeripherals.first(where: { $0.peripheral.identifier == peripheral.identifier }) {
            updatedPeripheral.isConnected = true
            peripheral.delegate = self
            peripheral.discoverServices(nil)
        }
    }

    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: (any Error)?) {
        if let updatedPeripheral = discoveredPeripherals.first(where: { $0.peripheral.identifier == peripheral.identifier }) {
            updatedPeripheral.isConnected = false
            peripheral.delegate = nil
        }
    }

}

extension BluetoothManager: CBPeripheralDelegate {
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard let services = peripheral.services else { return }

        DispatchQueue.main.async { [weak self] in
            if let updatedPeripheral = self?.discoveredPeripherals.first(where: { $0.peripheral.identifier == peripheral.identifier }) {
                updatedPeripheral.discoveredServices = services.map { service in
                    ServiceDetail(service: service)
                }
            }
        }
    }

    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
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
