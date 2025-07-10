//
//  ServiceDetailView.swift
//  BluKit_ExampleApp1
//
//  Copyright Zion Software, LLC.
//

import SwiftUI

struct ServiceDetailView: View {
    @StateObject private var viewModel: ServiceDetailViewModel

    init(peripheral: BluetoothPeripheral, serviceDetail: ServiceDetail) {
        _viewModel = StateObject(wrappedValue: ServiceDetailViewModel(peripheral: peripheral, serviceDetail: serviceDetail))
    }

    var body: some View {
        List {
            Section(header: Text("Characteristics")) {
                ForEach(viewModel.discoveredCharacteristics) { characteristicDetail in
                    NavigationLink(destination: CharacteristicDetailView(characteristicDetail: characteristicDetail)) {
                        VStack(alignment: .leading) {
                            Text(characteristicDetail.name)
                                .font(.headline)
                            Text(characteristicDetail.uuid.uuidString)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }

            }
        }
        .navigationTitle(viewModel.serviceDetail.name)
        .listStyle(InsetGroupedListStyle())
        .onAppear {
            print("*** ServiceDetailView.onAppear()")
            viewModel.onAppear()
        }
        .onDisappear {
            print("*** ServiceDetailView.onDisappear()")
            viewModel.onDisappear()
        }
    }
}
