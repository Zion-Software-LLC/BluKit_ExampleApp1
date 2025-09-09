//
//  PeripheralDetailView.swift
//  BluKit_ExampleApp1
//
//  Copyright Zion Software, LLC.
//

import SwiftUI

struct PeripheralDetailView: View {
    @ObservedObject var viewModel: PeripheralDetailViewModel
    @State private var selectedServiceDetail: ServiceDetail?
    @State private var showServiceDetail = false

    var body: some View {
        VStack {
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
                        HStack {
                            VStack(alignment: .leading) {
                                Text(serviceDetail.name)
                                    .font(.headline)
                                Text(serviceDetail.uuid.uuidString)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            selectedServiceDetail = serviceDetail
                            showServiceDetail = true
                        }
                    }

                }
            }
            .navigationTitle(viewModel.peripheral.name)
            .listStyle(InsetGroupedListStyle())
        }
        .navigationDestination(isPresented: $showServiceDetail) {
            // a SwiftUI bug that this closure is called
            // even when showServiceDetail is false after it is set to true once
            if showServiceDetail, let selectedServiceDetail {
                ServiceDetailView(viewModel: ServiceDetailViewModel(peripheral: viewModel.peripheral, serviceDetail: selectedServiceDetail))
            }
        }
        .onAppear {
            viewModel.onAppear()
        }
        .onDisappear {
            viewModel.onDisappear()
        }
    }
}
