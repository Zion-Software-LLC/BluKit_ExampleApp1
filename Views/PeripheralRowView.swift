//
//  PeripheralRowView.swift
//  BluKit_ExampleApp1
//
//  Copyright Zion Software, LLC.
//

import SwiftUI

struct PeripheralRowView: View {
    let peripheral: BluetoothPeripheral
    let onConnect: () -> Void
    let onDisconnect: () -> Void

    var body: some View {

        HStack {
            // Signal Strength Indicator
            SignalStrengthView(rssi: peripheral.rssi.intValue)

            VStack(alignment: .leading) {
                Text(peripheral.name)
                    .font(.headline)
            }

            Spacer()

            // show Connection Button if Connectable
            if peripheral.isConnectable {
                if peripheral.peripheral.state != .connected {
                    Button("Connect") {
                        onConnect()
                    }
                    .buttonStyle(PlainButtonStyle()) // separately tappable within a NavigationLink
                    .foregroundStyle(.blue)

                } else {
                    Button("Disconnect") {
                        onDisconnect()
                    }
                    .buttonStyle(PlainButtonStyle()) // separately tappable within a NavigationLink
                    .foregroundStyle(.blue)
                }
            }
        }

    }

}
