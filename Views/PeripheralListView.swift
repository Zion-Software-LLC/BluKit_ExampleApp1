//
//  PeripheralListView.swift
//  BluKit_ExampleApp1
//
//  Copyright Zion Software, LLC.
//

import SwiftUI

struct PeripheralListView: View {
    @StateObject private var viewModel = PeripheralListViewModel()
    @State private var selectedPeripheral: BluetoothPeripheral?

    var body: some View {

        NavigationStack {
            List(viewModel.discoveredPeripherals) { peripheral in
                PeripheralRowView(
                    peripheral: peripheral,
                    onConnect: {
                        viewModel.connectPeripheral(peripheral)
                    },
                    onDisconnect: {
                        viewModel.disconnectPeripheral(peripheral)
                    }
                )
                .onTapGesture {
                    selectedPeripheral = peripheral
                }
            }
            .navigationTitle("Bluetooth Peripherals")
            .navigationDestination(item: $selectedPeripheral) { peripheral in
                PeripheralDetailView(peripheral: peripheral)
            }
        }
        .onAppear {
            print("*** PeripheralListView.onAppear()")
            viewModel.onAppear()
        }
        .onDisappear {
            print("*** PeripheralListView.onDisappear()")
            viewModel.onDisappear()
        }

//
//        NavigationView {
//            List(viewModel.discoveredPeripherals) { peripheral in
//                NavigationLink(destination: PeripheralDetailView(peripheral: peripheral)) {
//                    PeripheralRowView(
//                        peripheral: peripheral,
//                        onConnect: {
//                            viewModel.connectPeripheral(peripheral)
//                        },
//                        onDisconnect: {
//                            viewModel.disconnectPeripheral(peripheral)
//                        }
//                    )
//                }
//            }
//            .navigationTitle("Bluetooth Peripherals")
//            .onAppear {
//                print("*** PeripheralListView.onAppear()")
//                viewModel.onAppear()
//            }
//            .onDisappear {
//                print("*** PeripheralListView.onDisappear()")
//                viewModel.onDisappear()
//            }
//        }
    }
}
