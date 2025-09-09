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

    func listenForDiscoveredPeripheralsChanges() {
        isVisible = true
        self.discoveredPeripherals = bluetoothManager.discoveredPeripherals
        cancellable = bluetoothManager.$discoveredPeripherals.sink(receiveValue: discoveredPeripherals(_:))
    }

    func stopListeningForDiscoveredPeripheralsChanges() {
        isVisible = false
        cancellable?.cancel()
        cancellable = nil
    }

    func handleShowPeripheralDetailChange(_ showPeripheralDetail: Bool) {
        if showPeripheralDetail { // peripheral detail is showing, stop listening for changes for now
            stopListeningForDiscoveredPeripheralsChanges()
        } else { // peripheral detail is not showing, start listening for changes again
            listenForDiscoveredPeripheralsChanges()
        }
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
