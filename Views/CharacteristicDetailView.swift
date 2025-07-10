//
//  CharacteristicDetailView.swift
//  BluKit_ExampleApp1
//
//  Copyright Zion Software, LLC.
//

import SwiftUI

struct CharacteristicDetailView: View {
    @StateObject private var viewModel: CharacteristicDetailViewModel

    init(characteristicDetail: CharacteristicDetail) {
        _viewModel = StateObject(wrappedValue: CharacteristicDetailViewModel(characteristicDetail: characteristicDetail))
    }

    var body: some View {
        VStack {
            Text(viewModel.characteristicDetail.name)
            Text(viewModel.characteristicDetail.uuid.uuidString)
            Text(viewModel.characteristicDetail.value?.base64EncodedString() ?? "--")
        }
    }
}
