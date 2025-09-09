//
//  CharacteristicDetailViewModel.swift
//  BluKit_ExampleApp1
//
//  Copyright Zion Software, LLC.
//

import Foundation
import Combine
import BluKit

class CharacteristicDetailViewModel: ObservableObject {
    let characteristicDetail: CharacteristicDetail

    init(characteristicDetail: CharacteristicDetail) {
        self.characteristicDetail = characteristicDetail
    }

    var name: String {
        characteristicDetail.name
    }

    var uuidString: String {
        characteristicDetail.uuid.uuidString
    }

    var valueAsString: String {
        characteristicDetail.valueAsString
    }

}
