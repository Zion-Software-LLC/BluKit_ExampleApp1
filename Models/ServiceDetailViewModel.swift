//
//  ServiceDetailViewModel.swift
//  BluKit_ExampleApp1
//
//  Copyright Zion Software, LLC.
//

import Foundation
import Combine
import CoreBluetooth

class ServiceDetailViewModel: ObservableObject {
    let serviceDetail: ServiceDetail
    weak var peripheral: BluetoothPeripheral?

    @Published var discoveredCharacteristics: [CharacteristicDetail] = []

    var isVisible = false
    var cancellable: AnyCancellable?

    init(peripheral: BluetoothPeripheral, serviceDetail: ServiceDetail) {
        self.peripheral = peripheral
        self.serviceDetail = serviceDetail
    }

    deinit {
        print("*** ServiceDetailViewModel.deinit")
    }

    func onAppear() {
        isVisible = true
        self.discoveredCharacteristics = serviceDetail.discoveredCharacteristics

        // on-demand fetch characteristics
        if let peripheral, peripheral.isConnected, let cbPeripheral = serviceDetail.service.peripheral {
            cbPeripheral.discoverCharacteristics(nil, for: serviceDetail.service)
        }

        cancellable = serviceDetail.$discoveredCharacteristics.sink(receiveValue: discoveredCharacteristics(_:))
    }

    func onDisappear() {
        isVisible = false

        // cancel publisher to allow deinit
        cancellable?.cancel()
        cancellable = nil
    }

    func discoveredCharacteristics(_ discoveredCharacteristics: [CharacteristicDetail]) {
        if isVisible { // only publish changes if isVisible
            print("*** ServiceDetailViewModel.discoveredCharacteristics: \(discoveredCharacteristics.count)")
            self.discoveredCharacteristics = discoveredCharacteristics
        }
    }
}
