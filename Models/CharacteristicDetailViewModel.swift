//
//  CharacteristicDetailViewModel.swift
//  BluKit_ExampleApp1
//
//  Copyright Zion Software, LLC.
//

import Foundation
import Combine
import CoreBluetooth

class CharacteristicDetailViewModel: ObservableObject {
    let characteristicDetail: CharacteristicDetail

    init(characteristicDetail: CharacteristicDetail) {
        self.characteristicDetail = characteristicDetail
    }

    deinit {
        print("*** CharacteristicDetailViewModel.deinit")
    }

}
