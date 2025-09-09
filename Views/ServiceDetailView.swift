//
//  ServiceDetailView.swift
//  BluKit_ExampleApp1
//
//  Copyright Zion Software, LLC.
//

import SwiftUI

struct ServiceDetailView: View {
    @ObservedObject var viewModel: ServiceDetailViewModel
    @State private var selectedCharacteristicDetail: CharacteristicDetail?
    @State private var showCharacteristicDetail = false

    var body: some View {
        VStack {
            List {
                Section(header: Text("Characteristics")) {
                    ForEach(viewModel.discoveredCharacteristics) { characteristicDetail in
                        HStack {
                            VStack(alignment: .leading) {
                                Text(characteristicDetail.name)
                                    .font(.headline)
                                Text(characteristicDetail.uuid.uuidString)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            selectedCharacteristicDetail = characteristicDetail
                            showCharacteristicDetail = true
                        }
                    }
                }
            }
            .navigationTitle(viewModel.serviceDetail.name)
            .listStyle(InsetGroupedListStyle())
        }
        .navigationDestination(isPresented: $showCharacteristicDetail) {
            // a SwiftUI bug that this closure is called
            // even when showCharacteristicDetail is false after it is set to true once
            if showCharacteristicDetail, let selectedCharacteristicDetail {
                CharacteristicDetailView(viewModel: CharacteristicDetailViewModel(characteristicDetail: selectedCharacteristicDetail))
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
