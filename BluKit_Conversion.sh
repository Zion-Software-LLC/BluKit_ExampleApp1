#!/bin/zsh

# convert CB* to BluKit APIs
find . -name \*.swift -exec sed -i '' 's/CBCentralManagerDelegate/CentralManagerDelegate/g' {} +  
find . -name \*.swift -exec sed -i '' 's/CBCentralManager/CentralManager/g' {} +  
find . -name \*.swift -exec sed -i '' 's/CBPeripheralDelegate/PeripheralDelegate/g' {} +  
find . -name \*.swift -exec sed -i '' 's/CBPeripheral/Peripheral/g' {} +  
find . -name \*.swift -exec sed -i '' 's/CBService/Service/g' {} +  
#
# Use with caution as APIs may not align perfectly
#find . -name \*.swift -exec sed -i '' 's/CBCharacteristicProperties/\[CharacteristicProperty\]/g' {} +  
#
find . -name \*.swift -exec sed -i '' 's/CBCharacteristic/Characteristic/g' {} +  
find . -name \*.swift -exec sed -i '' 's/CBDescriptor/Descriptor/g' {} +  
#
# May still require import CoreBluetooth in addition to import BluKit
#
find . -name \*.swift -exec sed -i '' 's/import CoreBluetooth/import BluKit/g' {} +  
