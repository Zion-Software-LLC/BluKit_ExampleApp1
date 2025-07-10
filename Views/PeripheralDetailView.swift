//
//  PeripheralDetailView.swift
//  BluKit_ExampleApp1
//
//  Copyright Zion Software, LLC.
//

import SwiftUI

struct PeripheralDetailView: View {
    @StateObject private var viewModel: PeripheralDetailViewModel

    init(peripheral: BluetoothPeripheral) {
        print("*** PeripheralDetailView(\(peripheral.name))")
        _viewModel = StateObject(wrappedValue: PeripheralDetailViewModel(peripheral: peripheral))
    }

    var body: some View {
        List {
            Section(header: Text("Advertisement Data")) {
                ForEach(viewModel.advertisementDataItems.indices, id: \.self) { index in
                    VStack(alignment: .leading) {
                        Text(viewModel.advertisementDataItems[index].value)
                            .font(.headline)
                        Text(viewModel.advertisementDataItems[index].key)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }

            Section(header: Text("Services")) {
                ForEach(viewModel.discoveredServices) { serviceDetail in
                    NavigationLink(destination: ServiceDetailView(peripheral: viewModel.peripheral, serviceDetail: serviceDetail)) {
                        VStack(alignment: .leading) {
                            Text(serviceDetail.name)
                                .font(.headline)
                            Text(serviceDetail.uuid.uuidString)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
        }
        .navigationTitle(viewModel.peripheral.name)
        .listStyle(InsetGroupedListStyle())
        .onAppear {
            print("*** PeripheralDetailView.onAppear()")
            viewModel.onAppear()
        }
        .onDisappear {
            print("*** PeripheralDetailView.onDisappear()")
            viewModel.onDisappear()
        }
    }
}
