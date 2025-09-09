//
//  CharacteristicDetailView.swift
//  BluKit_ExampleApp1
//
//  Copyright Zion Software, LLC.
//

import SwiftUI

struct CharacteristicDetailView: View {
    @ObservedObject var viewModel: CharacteristicDetailViewModel

    var body: some View {
        VStack {
            Text(viewModel.name)
            Text(viewModel.uuidString)
            Text(viewModel.valueAsString)
        }
    }
}
