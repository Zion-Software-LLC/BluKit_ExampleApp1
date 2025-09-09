//
//  PeripheralRowView.swift
//  BluKit_ExampleApp1
//
//  Copyright Zion Software, LLC.
//

import SwiftUI

struct PeripheralRowView: View {
    @ObservedObject var peripheral: BluetoothPeripheral
    let onConnect: () -> Void
    let onDisconnect: () -> Void
    let onTap: () -> Void

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
                if peripheral.isConnected {
                    if peripheral.isAttemptingToDisconnect {
                        Text("Disconnecting...")
                    } else {
                        Button("Disconnect") {
                            peripheral.isAttemptingToConnect = false
                            peripheral.isAttemptingToDisconnect =  true
                            onDisconnect()
                        }
                        .buttonStyle(PlainButtonStyle()) // separately tappable within a NavigationLink
                        .foregroundStyle(.blue)
                    }
                }
                else {
                    if peripheral.isAttemptingToConnect {
                        Text("Connecting...")
                    } else {
                        Button("Connect") {
                            peripheral.isAttemptingToConnect = true
                            peripheral.isAttemptingToDisconnect = false
                            onConnect()
                        }
                        .buttonStyle(PlainButtonStyle()) // separately tappable within a NavigationLink
                        .foregroundStyle(.blue)
                    }
                }
            }
        }
        .contentShape(Rectangle()) // ensure full view is tappable
        .onTapGesture {
            onTap()
        }

    }

}
