//
//  PeripheralListViewModel.swift
//  BluKit_ExampleApp1
//
//  Copyright Zion Software, LLC.
//

import Foundation
import Combine

class PeripheralListViewModel: ObservableObject {
    var bluetoothManager: BluetoothManager
    @Published var discoveredPeripherals: [BluetoothPeripheral] = []

    var isVisible = false
    var cancellable: AnyCancellable?

    init(bluetoothManager: BluetoothManager = BluetoothManager()) {
        self.bluetoothManager = bluetoothManager
    }

    func onAppear() {
        isVisible = true
        self.discoveredPeripherals = bluetoothManager.discoveredPeripherals
        cancellable = bluetoothManager.$discoveredPeripherals.sink(receiveValue: discoveredPeripherals(_:))
    }

    func onDisappear() {
        isVisible = false

        cancellable?.cancel()
        cancellable = nil
    }

    func discoveredPeripherals(_ discoveredPeripherals: [BluetoothPeripheral]) {
        if isVisible { // only publish changes if isVisible
            self.discoveredPeripherals = discoveredPeripherals
        }
    }

    func connectPeripheral(_ peripheral: BluetoothPeripheral) {
        bluetoothManager.connect(peripheral: peripheral)
    }

    func disconnectPeripheral(_ peripheral: BluetoothPeripheral) {
        bluetoothManager.disconnect(peripheral: peripheral)
    }
}
