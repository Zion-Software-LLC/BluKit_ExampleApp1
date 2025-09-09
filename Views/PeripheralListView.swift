//
//  PeripheralListView.swift
//  BluKit_ExampleApp1
//
//  Copyright Zion Software, LLC.
//

import SwiftUI

struct PeripheralListView: View {
    @ObservedObject var viewModel: PeripheralListViewModel
    @State private var selectedPeripheral: BluetoothPeripheral?
    @State private var showPeripheralDetail = false

    var body: some View {

        NavigationStack {
            VStack {
                List(viewModel.discoveredPeripherals) { peripheral in
                    PeripheralRowView(
                        peripheral: peripheral,
                        onConnect: {
                            viewModel.connectPeripheral(peripheral)
                        },
                        onDisconnect: {
                            viewModel.disconnectPeripheral(peripheral)
                        },
                        onTap: {
                            selectedPeripheral = peripheral
                            showPeripheralDetail = true
                        }
                    )
                }
            }
            .navigationTitle("BluKit Example App")
            .navigationDestination(isPresented: $showPeripheralDetail) {
                // a SwiftUI bug that this closure is called
                // even when showPeripheralDetail is false after it is set to true once
                if showPeripheralDetail, let selectedPeripheral {
                    PeripheralDetailView(viewModel: PeripheralDetailViewModel(peripheral: selectedPeripheral))
                }
            }
        }
        .onAppear {
            viewModel.listenForDiscoveredPeripheralsChanges()
        }
        .onChange(of: showPeripheralDetail) {
            viewModel.handleShowPeripheralDetailChange(showPeripheralDetail)
        }
    }
}
