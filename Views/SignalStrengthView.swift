//
//  SignalStrengthView.swift
//  BluKit_ExampleApp1
//
//  Copyright Zion Software, LLC.
//

import SwiftUI

struct SignalStrengthView: View {
    let rssi: Int

    var body: some View {
        signalStrengthImage
    }

    enum SignalStrength {
        case none
        case faint
        case weak
        case moderate
        case strong

        var image: UIImage {
            switch self {
            case .none:
                UIImage(systemName: "cellularbars", variableValue: 0.0)!
            case .faint:
                UIImage(systemName: "cellularbars", variableValue: 0.25)!
            case .weak:
                UIImage(systemName: "cellularbars", variableValue: 0.5)!
            case .moderate:
                UIImage(systemName: "cellularbars", variableValue: 0.75)!
            case .strong:
                UIImage(systemName: "cellularbars", variableValue: 1.0)!
            }
        }
    }

    var signalStrength: SignalStrength {
        // the current RSSI value in dBm. A value of 127 is reserved and indicates the RSSI was not available.
        guard rssi != 127 else { return .none }

        switch rssi {
        case -256 ..< -89: return .faint
        case -89 ..< -79:  return .weak
        case -79 ..< -59: return .moderate
        case -59 ..< 0: return .strong
        default: return .none
        }
    }

    var signalStrengthImage: some View {
        Image(uiImage: signalStrength.image)
            .renderingMode(.template)
            .foregroundColor(.accentColor)
    }

}
