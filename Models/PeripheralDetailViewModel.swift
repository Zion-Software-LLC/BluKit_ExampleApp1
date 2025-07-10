//
//  PeripheralDetailViewModel.swift
//  BluKit_ExampleApp1
//
//  Copyright Zion Software, LLC.
//

import Foundation
import Combine
import CoreBluetooth

class PeripheralDetailViewModel: ObservableObject {
    let peripheral: BluetoothPeripheral
    @Published var discoveredServices: [ServiceDetail] = []

    var isVisible = false
    var cancellable: AnyCancellable?

    init(peripheral: BluetoothPeripheral) {
        print("*** PeripheralDetailViewModel(\(peripheral.name))")
        self.peripheral = peripheral
    }

    deinit {
        print("*** PeripheralDetailViewModel.deinit")
    }

    func onAppear() {
        isVisible = true
        self.discoveredServices = peripheral.discoveredServices
        cancellable = peripheral.$discoveredServices.sink(receiveValue: discoveredServices(_:))
    }

    func onDisappear() {
        isVisible = false

        // cancel publisher to allow deinit
        cancellable?.cancel()
        cancellable = nil
    }

    func discoveredServices(_ discoveredServices: [ServiceDetail]) {
        if isVisible { // only publish changes if isVisible
            print("*** PeripheralDetailViewModel.discoveredServices: \(discoveredServices.count)")
            self.discoveredServices = discoveredServices
        }
    }

    var advertisementDataItems: [(key: String, value: String)] {
        return peripheral.advertisementData.map { (key: $0.key, value: String(describing: $0.value)) }
    }

}
