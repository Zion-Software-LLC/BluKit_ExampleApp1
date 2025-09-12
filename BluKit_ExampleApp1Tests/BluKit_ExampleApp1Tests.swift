//
//  BluKit_ExampleApp1Tests.swift
//  BluKit_ExampleApp1Tests
//
//  Copyright Zion Software, LLC.
//

import Testing
import BluKit
@testable import BluKit_ExampleApp1

// BluKit Framework supports Virtual Peripherals. Virtual Peripherals open up new possibilities for Application Developers.
// Among other benefits, Virtual Peripherals enable ability to interact with a virtual peripheral without requiring a physical device.
// Virtual Peripherals allow application developers to write repeatable tests related to the Virtual Peripheral.

//@Suite(.serialized)
class BluKit_ExampleApp1Tests: NSObject, CentralManagerDelegate, PeripheralDelegate {

    // used to bridge delegate callbacks to completion handler Swift APIs
    // which can be bridged to Swift async continuation APIs
    var updatedCentralState: ((Bool) -> Void)?
    var updatedDiscoverPeripheral: ((Peripheral, [String : Any], NSNumber) -> Void)?
    var updatedPeripheralConnected: ((Peripheral) -> Void)?
    var updatedPeripheralDiscoveredServices: (([Service]?) -> Void)?
    var updatedServiceDiscoveredCharacteristics: (([Characteristic]?) -> Void)?
    var updatedCharacteristicNotificationState: ((Bool) -> Void)?
    var updatedCharacteristicValue: ((Characteristic) -> Void)?

    // MARK: - bridging delegate callbacks to completion handler funcs

    func didUpdateCentralState(completion: @escaping (Bool) -> Void) {
        updatedCentralState = completion
    }

    func didUpdateDiscoveredPeripherals(completion: @escaping (Peripheral, [String: Any], NSNumber) -> Void) {
        updatedDiscoverPeripheral = completion
    }

    func didUpdatePeripheralConnected(completion: @escaping (Peripheral) -> Void) {
        updatedPeripheralConnected = completion
    }

    func didUpdatePeripheralDiscoveredServices(completion: @escaping ([Service]?) -> Void) {
        updatedPeripheralDiscoveredServices = completion
    }

    func didUpdateServiceDiscoveredCharacteristics(completion: @escaping ([Characteristic]?) -> Void) {
        updatedServiceDiscoveredCharacteristics = completion
    }

    func didUpdateCharacteristicNotificationState(completion: @escaping (Bool) -> Void) {
        updatedCharacteristicNotificationState = completion
    }

    func didUpdateCharacteristicValue(completion: @escaping (Characteristic) -> Void) {
        updatedCharacteristicValue = completion
    }

    // MARK: - CentralManagerDelegate optional funcs

    func centralManagerDidUpdateState(_ centralManager: CentralManager) {
        print("CentralManagerDelegate.centralManagerDidUpdateState()")
        updatedCentralState?(true)
    }

    func centralManager(_ centralManager: CentralManager, didDiscover peripheral: Peripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        print("CentralManagerDelegate.centralManager(_ centralManager: CentralManager, didDiscover peripheral: Peripheral, advertisementData: [String : Any], rssi RSSI: NSNumber)")
        updatedDiscoverPeripheral?(peripheral, advertisementData, RSSI)
    }

    func centralManager(_ centralManager: CentralManager, didConnect peripheral: Peripheral) {
        updatedPeripheralConnected?(peripheral)
    }

    // MARK: - PeripheralDelegate optional funcs

    func peripheral(_ peripheral: Peripheral, didDiscoverServices error: (any Error)?) {
        updatedPeripheralDiscoveredServices?(peripheral.services)
    }

    func peripheral(_ peripheral: Peripheral, didDiscoverCharacteristicsFor service: Service, error: (any Error)?) {
        updatedServiceDiscoveredCharacteristics?(service.characteristics)
    }

    func peripheral(_ peripheral: Peripheral, didUpdateNotificationStateFor characteristic: Characteristic, error: (any Error)?) {
        updatedCharacteristicNotificationState?(characteristic.isNotifying)
    }

    func peripheral(_ peripheral: Peripheral, didUpdateValueFor characteristic: Characteristic, error: (any Error)?) {
        updatedCharacteristicValue?(characteristic)
    }

    // MARK: - Tests

    // Simply load a Virtual Peripheral.json file created from BluKitWorkbench app!
    // See: https://apps.apple.com/us/app/blukit-workbench/id6747599806

    /// Load a Virtual Peripheral from ExampleApp1_VirtualPeripheral.json, connect and interact with the Virtual Peripheral, verify various attributes
    ///
    /// Multiple async tests are grouped into a single @Test based on how the CoreBluetooth system is designed:
    ///
    /// - Setup CentralManager
    /// - Listen for CentralState delegate
    /// - Discover Peripheral(s)
    /// - Connect Peripheral(s)
    /// - Discover Services of Connected Peripheral
    /// - Discover Characteristics of Device Information Service
    /// - Discover Characteristics of Heart Rate Service
    /// - Notify Heart Rate Measurement Characteristic
    /// - Listen for Characteristic Value Changes
    /// - Disconnect Peripheral
    ///

    @Test func checksOnSpecificVirtualPeripheral() async throws {

        // NOTE: Just like CoreBluetooth, most BluKit APIs are an asynchronous activity...

        // MARK: - Setup CentralManager
        let central = CentralManager(delegate: nil, queue: .main)
        central.delegate = self

        // MARK: - Listen for CentralState delegate state
        await confirmation("didUpdateCentralState confirmation") { confirmation in

            // bridge from delegate APIs to Swift Continuation APIs
            let _ = await withCheckedContinuation { continuation in
                didUpdateCentralState { isSuccess in
                    continuation.resume(returning: isSuccess)
                    confirmation()
                }
            }
        }

        // MARK: - Discover Peripheral
        var discoveredPeripheralResult: (Peripheral, [String: Any], NSNumber)?
        await confirmation("didUpdateDiscoveredPeripherals confirmation") { confirmation in

            // BluKit supports Virtual Peripherals in Xcode Simulators
            // Simply load a Virtual Peripheral.json file created from BluKitWorkbench app!
            // See: https://apps.apple.com/us/app/blukit-workbench/id6747599806
            if let exampleVirtualPeripheralURL = Bundle.main.url(forResource: "ExampleApp1_VirtualPeripheral", withExtension: "json") {
                try? central.loadVirtualPeripherals(fileURL: exampleVirtualPeripheralURL)
            }

            // bridge from delegate APIs to Swift Continuation APIs
            discoveredPeripheralResult = await withCheckedContinuation { continuation in
                didUpdateDiscoveredPeripherals { (peripheral, advertisementData, rssi) in
                    continuation.resume(returning: (peripheral, advertisementData, rssi))
                    confirmation()
                }
            }
        }

        // expecting the discovered peripheral not to be nil
        guard let discoveredPeripheralResult else {
            #expect(Bool(false), "discoveredPeripheralResult must be non-nil")
            return
        }

        // expecting discovered peripheral to have a specific identifier
        let discoveredPeripheral = discoveredPeripheralResult.0
        #expect(discoveredPeripheral.identifier.uuidString == "35779A42-E516-4392-A95A-8E0780067BC4", "discoveredPeripheral should have expected identifier")

        // expecting discovered peripheral to be connectable
        #expect(discoveredPeripheral.isConnectable, "discoveredPeripheral expected to be connectable")

        // MARK: - Connect Peripheral
        var connectedPeripheral: Peripheral?
        await confirmation("didUpdatePeripheralConnected confirmation") { confirmation in

            // request central to connect peripheral...listen for CentralManagerDelegate connection callback
            central.connect(discoveredPeripheral)

            // bridge from delegate APIs to Swift Continuation APIs
            connectedPeripheral = await withCheckedContinuation { continuation in
                didUpdatePeripheralConnected { peripheral in
                    continuation.resume(returning: peripheral)
                    confirmation()
                }
            }
        }

        // expecting connected peripheral not to be nil
        guard let connectedPeripheral else {
            #expect(Bool(false), "expecting peripheral must not be nil")
            return
        }

        // expecting connectedPeripheral to be connected
        #expect(connectedPeripheral.isConnected, "expecting peripheral.isConnected be true")

        // set delegate to receive PeripheralDelegate callbacks...
        connectedPeripheral.delegate = self

        // MARK: - Discover Services of Connected Peripheral
        var discoveredServices: [Service]?
        await confirmation("didUpdatePeripheralDiscoveredServices confirmation") { confirmation in

            // request peripheral to discover services...
            connectedPeripheral.discoverServices()

            // bridge from delegate APIs to Swift Continuation APIs
            discoveredServices = await withCheckedContinuation { continuation in
                didUpdatePeripheralDiscoveredServices { services in
                    continuation.resume(returning: services)
                    confirmation()
                }
            }
        }

        // expecting discoveredServices not to be nil
        guard let discoveredServices else {
            #expect(Bool(false), "discoveredServices must be non-nil")
            return
        }

        // expecting discoveredServices to have exactly two services
        #expect(discoveredServices.count == 2, "discoveredServices expected to have two services")

        // expect to find Device Information GATTService in discoveredServices
        let deviceInformationService = discoveredServices.first {
            GATTService(cbuuid: $0.uuid) == .device_information
        }

        // expecting deviceInformationService not to be nil
        guard let deviceInformationService else {
            #expect(Bool(false), "deviceInformationService must be non-nil")
            return
        }

        // MARK: - Discover Characteristics of a Device Information Service
        var deviceInformationDiscoveredCharacteristics: [Characteristic]?
        await confirmation("didUpdateServiceDiscoveredCharacteristics Device Information confirmation") { confirmation in

            // request peripheral to discover Characteristics for Device Information Service...
            discoveredPeripheral.discoverCharacteristics(nil, for: deviceInformationService)

            // bridge from delegate APIs to Swift Continuation APIs
            deviceInformationDiscoveredCharacteristics = await withCheckedContinuation { continuation in
                didUpdateServiceDiscoveredCharacteristics { characteristics in
                    continuation.resume(returning: characteristics)
                    confirmation()
                }
            }
        }

        // expecting deviceInformationDiscoveredCharacteristics not to be nil
        guard let deviceInformationDiscoveredCharacteristics else {
            #expect(Bool(false), "deviceInformationDiscoveredCharacteristics must be non-nil")
            return
        }

        // expect to find Manufacturer Name String GATTCharacteristic in deviceInformationDiscoveredCharacteristics
        let manufacturerNameStringCharacteristic = deviceInformationDiscoveredCharacteristics.first {
            $0.gattCharacteristic == .manufacturer_name_string
        }

        // expecting manufacturerNameStringCharacteristic not to be nil
        guard let manufacturerNameStringCharacteristic else {
            #expect(Bool(false), "manufacturerNameStringCharacteristic must be non-nil")
            return
        }

        // remove possible null terminated Bluetooth String before comparison
        let manufacturerNameString = manufacturerNameStringCharacteristic.description.trimmingNullTerminator()
        #expect(manufacturerNameString == "NordicSemiconductor", "expecting manufacturerNameString to be 'NordicSemiconductor'")


        // MARK: - Discover Characteristics of a Heart Rate Service

        // expect to find Heart Rate GATTService in discoveredServices
        let heartRateService = discoveredServices.first {
            GATTService(cbuuid: $0.uuid) == .heart_rate
        }

        // expecting heartRateService not to be nil
        guard let heartRateService else {
            #expect(Bool(false), "heartRateService must be non-nil")
            return
        }

        var heartRateDiscoveredCharacteristics: [Characteristic]?
        await confirmation("didUpdateServiceDiscoveredCharacteristics Heart Rate confirmation") { confirmation in

            // request peripheral to discover Characteristics for Heart Rate Service...
            discoveredPeripheral.discoverCharacteristics(nil, for: heartRateService)

            // bridge from delegate APIs to Swift Continuation APIs
            heartRateDiscoveredCharacteristics = await withCheckedContinuation { continuation in
                didUpdateServiceDiscoveredCharacteristics { characteristics in
                    continuation.resume(returning: characteristics)
                    confirmation()
                }
            }
        }

        // expecting heartRateDiscoveredCharacteristics not to be nil
        guard let heartRateDiscoveredCharacteristics else {
            #expect(Bool(false), "heartRateDiscoveredCharacteristics must be non-nil")
            return
        }

        let heartRateMeasurementCharacteristic = heartRateDiscoveredCharacteristics.first {
            $0.gattCharacteristic == .heart_rate_measurement
        }

        // expecting heartRateMeasurementCharacteristic not to be nil
        guard let heartRateMeasurementCharacteristic else {
            #expect(Bool(false), "heartRateMeasurementCharacteristic must be non-nil")
            return
        }

        #expect(heartRateMeasurementCharacteristic.supportsNotifyOrIndicate, "expecting heartRateMeasurementCharacteristic to support notify or indicate")

        // MARK: - Notify Heart Rate Measurement Characteristic

        var isHeartRateMeasurementCharacteristicNotifying = false
        await confirmation("didUpdateCharacteristicNotificationState Heart Rate Measurement") { confirmation in

            // request peripheral to change notification to true on heartRateMeasurementCharacteristic...
            connectedPeripheral.setNotifyValue(true, for: heartRateMeasurementCharacteristic)

            // bridge from delegate APIs to Swift Continuation APIs
            isHeartRateMeasurementCharacteristicNotifying = await withCheckedContinuation { continuation in
                didUpdateCharacteristicNotificationState { isNotifying in
                    continuation.resume(returning: isNotifying)
                    confirmation()
                }
            }
        }

        #expect(isHeartRateMeasurementCharacteristicNotifying, "expecting isHeartRateMeasurementCharacteristicNotifying to be true")

        var heartRateMeasurementCharacteristicWithValueChanges: Characteristic?
        await confirmation("didUpdateCharacteristicValue Heart Rate Measurement") { confirmation in

            // after setNotifyValue(true) above, heartRateMeasurementCharacteristic value changes are already being published...

            // bridge from delegate APIs to Swift Continuation APIs
            heartRateMeasurementCharacteristicWithValueChanges = await withCheckedContinuation { continuation in
                didUpdateCharacteristicValue { characteristic in
                    continuation.resume(returning: characteristic)
                    confirmation()
                }
            }
        }

        // expecting heartRateMeasurementCharacteristicWithValueChanges to be a HeartRateMeasurement and not to be nil
        guard let heartRateMeasurement =  heartRateMeasurementCharacteristicWithValueChanges as? HeartRateMeasurement else {
            #expect(Bool(false), "heartRateMeasurementCharacteristicWithValueChanges must be non-nil HeartRateMeasurement")
            return
        }

        guard let bpmUInt = heartRateMeasurement.bpm else {
            #expect(Bool(false), "heartRateMeasurement.bpm to be non-nil")
            return
        }

        let bpm = Int(bpmUInt)
        #expect(bpm > 40 && bpm < 210, "expecting bpm to be in expected range")

        // MARK: - clean up

        // these are also async operations, but we do not need to listen for their results...

        // request peripheral to change notification to false on heartRateMeasurementCharacteristic...
        connectedPeripheral.setNotifyValue(false, for: heartRateMeasurementCharacteristic)

        // disconnect peripheral
        central.cancelPeripheralConnection(connectedPeripheral)

    }

}

// MARK: - helper funcs

extension String {

    // Bluetooth strings are often null terminated
    func trimmingNullTerminator() -> String {
        var possiblyNullTerminated = self
        if possiblyNullTerminated.last == "\0" {
            possiblyNullTerminated.removeLast()
        }

        return possiblyNullTerminated
    }

}
