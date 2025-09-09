//
//  BluKit_ExampleApp1.swift
//  BluKit_ExampleApp1
//
//  Copyright Zion Software, LLC.
//

import SwiftUI

@main
struct BluKit_ExampleApp1: App {
    let viewModel = PeripheralListViewModel(bluetoothManager: BluetoothManager())

    var body: some Scene {
        WindowGroup {
            PeripheralListView(viewModel: viewModel)
        }
    }
}
