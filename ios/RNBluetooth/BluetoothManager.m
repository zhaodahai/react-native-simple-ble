//
//  BluetoothManager.m
//  RNBluetooth
//
//  Created by dahai on 2017/2/16.
//  Copyright © 2017年 dahai. All rights reserved.
//


#import "BluetoothManager.h"
#import <React/RCTLog.h>

@implementation BluetoothManager

static BluetoothManager *blutoothManager = nil;
+ (instancetype)sharedInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        blutoothManager = [[self alloc]init];
    });
    return blutoothManager;
}

- (void)scanCBPeripheralsWithServiceUUIDs:(NSArray *)UUIDs allowDuplicates:(BOOL)allowDuplicates showPowerAlert:(BOOL)showPowerAlert
{
    serviceUUIDs = nil;
    if (UUIDs.count > 0) {
        serviceUUIDs = [NSMutableArray array];
        for (NSString *uuid in UUIDs) {
            [serviceUUIDs addObject:[CBUUID UUIDWithString:uuid]];
        }
    }
    discoverPeripherals = [NSMutableArray array];
    scanOption = @{CBCentralManagerScanOptionAllowDuplicatesKey:@(allowDuplicates)};
    if (_cbPeripheral.state == CBPeripheralStateConnecting || _cbPeripheral.state == CBPeripheralStateConnected) {
        [_cbManager scanForPeripheralsWithServices:serviceUUIDs options:scanOption];//搜索周围蓝牙设备
    }else{
        _cbManager = [[CBCentralManager alloc]initWithDelegate:self queue:dispatch_get_main_queue() options:@{CBCentralManagerOptionShowPowerAlertKey:@(showPowerAlert)}];
    }

}

- (void)stopScanCBPeripherals
{
    if (_cbManager) {
        [_cbManager stopScan];
    }
}

- (void)connectToCBPeripheral:(NSString *)identifier
{
    writeCharacteristics = [NSMutableDictionary dictionary];
    readCharacteristics = [NSMutableDictionary dictionary];
    for (NSDictionary *item in discoverPeripherals) {
        if ([identifier isEqualToString:item[@"identifier"]]) {
            CBPeripheral *peripheral = item[@"peripheral"];
            CBCentralManager *perCentarl = [peripheral valueForKey:@"centralManager"];
            if (_cbPeripheral.state != CBPeripheralStateConnecting && _cbPeripheral.state != CBPeripheralStateConnected) {
                if (perCentarl == _cbManager) {
                    _cbPeripheral = peripheral;
                    _cbPeripheral.delegate = self;
                    [_cbManager connectPeripheral:peripheral options:nil];
                }else{
                    [self updateCentralManagerOrPeripheralState:NO desc:@"设备不匹配,请重新搜索"];
                }
            }
            return;
        }
    }
    [self updateCentralManagerOrPeripheralState:NO desc:[NSString stringWithFormat:@"设备id:%@ 输入有误",identifier]];
}

- (void)readCBCharacteristicValue:(NSString *)UUID resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject
{
    readCharacteristicUUID = UUID;
    readResolve = resolve;
    readReject = reject;
    if (UUID) {
        if ([readCharacteristics.allKeys containsObject:UUID]) {
            [_cbPeripheral readValueForCharacteristic:readCharacteristics[UUID]];
        }else{
            if (readReject) {
                readReject(@"2",@"输入的read特征值uuid有误",nil);
                readReject = nil;
            }
            return;
        }
    }
}

- (void)writeToCBPeripheralWithWriteCharUUID:(NSString *)UUID message:(NSString *)msg resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject
{
    CBCharacteristic *writeChar;
    BOOL response = NO;
    writeResolve = resolve;
    writeReject = reject;
    if (UUID) {
        if ([writeCharacteristics.allKeys containsObject:UUID]) {
            writeChar = writeCharacteristics[UUID];
            if (writeChar.properties & CBCharacteristicPropertyWrite) {
                response = YES;
            }
        }else{
            if (writeReject) {
                writeReject(@"1",@"input a wrong write UUID",nil);
                writeReject = nil;
            }
            return;
        }
    }else{
        for (CBCharacteristic *aChar in writeCharacteristics.allValues) {
            writeChar = aChar;
            if (aChar.properties & CBCharacteristicPropertyWrite) {
                response = YES;
                break;
            }
        }
    }

    [self.cbPeripheral writeValue:[self dataFromHexString:msg] forCharacteristic:writeChar type:response?CBCharacteristicWriteWithResponse:CBCharacteristicWriteWithoutResponse];

}

// 'ABCDEF0123456789' -> <ABCDEF01 23456789>
- (NSData *)dataFromHexString:(NSString *)string
{
    NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
    unsigned char *byte = [data bytes];
    unsigned char result[[data length]];

    for (int i = 0; i < [data length]; i ++) {
        if (byte[i] >= '0' && byte[i] <= '9') {
            unsigned char temp = byte[i] - (0x30-0x0);
            if (i % 2 == 0) {
                result[i/2] = temp << 4;
            }else{
                result[i/2] = result[i/2] | temp;
            }
        }else if (byte[i] >= 'A' && byte[i] <='F'){
            unsigned char temp = byte[i] - (0x46-0xF);
            if (i % 2 == 0) {
                result[i/2] = temp << 4;
            }else{
                result[i/2] = result[i/2] | temp;
            }
        }
    }

    NSData *rData = [NSData dataWithBytes:result length:[data length]/2];
    return rData;
}


- (void)disconnectToCBPeripheral
{
    if (_cbPeripheral) {
        [_cbManager cancelPeripheralConnection:_cbPeripheral];
        _cbPeripheral = nil;
        _cbPeripheral.delegate = nil;
    }
}

- (void)updateCentralManagerOrPeripheralState:(BOOL)connected desc:(NSString *)desc
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(updateConnectionStatus:desc:)]) {
        [self.delegate updateConnectionStatus:connected desc:desc];
    }
}

#pragma mark ----- CBCentralManagerDelegate -----

- (void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    if (central.state == CBCentralManagerStatePoweredOn) {
        [_cbManager scanForPeripheralsWithServices:serviceUUIDs options:scanOption];//搜索周围蓝牙设备
    } else if(central.state == CBCentralManagerStatePoweredOff){
        [self updateCentralManagerOrPeripheralState:NO desc:@"Powered Off"];
    } else if (central.state == CBCentralManagerStateUnsupported){
        [self updateCentralManagerOrPeripheralState:NO desc:@"BLE4.0 unsupported"];
    } else if (central.state == CBCentralManagerStateUnauthorized){
        [self updateCentralManagerOrPeripheralState:NO desc:@"Unauthorized"];
    } else if (central.state == CBCentralManagerStateResetting){
        [self updateCentralManagerOrPeripheralState:NO desc:@"Resetting"];
    } else if(central.state == CBCentralManagerStateUnknown) {
        [self updateCentralManagerOrPeripheralState:NO desc:@"Unknown error"];
    }
}

- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary<NSString *,id> *)advertisementData RSSI:(NSNumber *)RSSI
{
    NSMutableDictionary *peripheralInfo = [NSMutableDictionary dictionary];
    [peripheralInfo setObject:peripheral forKey:@"peripheral"];
    [peripheralInfo setObject:peripheral.name?:@"" forKey:@"name"];
    [peripheralInfo setObject:RSSI?:@(0) forKey:@"RSSI"];
    [peripheralInfo setObject:peripheral.identifier.UUIDString?:@"" forKey:@"identifier"];

    for (NSDictionary *item in discoverPeripherals) {
        CBPeripheral * tempPeripheral = [item objectForKey:@"peripheral"];
        if ([tempPeripheral.identifier isEqual:peripheral.identifier]) {
            return;
        }
    }
    [peripheralInfo addEntriesFromDictionary:advertisementData];
    [discoverPeripherals addObject:peripheralInfo];
    if (self.delegate && [self.delegate respondsToSelector:@selector(didDiscoverPeripheral:)] ) {
        [self.delegate didDiscoverPeripheral:peripheralInfo];
    }
}

- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{

    RCTLog(@"-------------- didconnect -----------------  %@",peripheral.name);
    [self updateCentralManagerOrPeripheralState:YES desc:[NSString stringWithFormat:@"didconnect to %@",peripheral.name]];
    [_cbPeripheral discoverServices:serviceUUIDs];
}

- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(nullable NSError *)error
{
    [self updateCentralManagerOrPeripheralState:NO desc:error.localizedDescription];
}

- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    [self updateCentralManagerOrPeripheralState:NO desc:error.localizedDescription];
}



#pragma mark ----- CBPeripheralDelegate -----
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(nullable NSError *)error
{
    for (CBService *aService in peripheral.services)
    {
        RCTLog(@"service %@",aService.UUID);
        [peripheral discoverCharacteristics:nil forService:aService];
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(nullable NSError *)error
{
    for (CBCharacteristic *aChar in service.characteristics) {
        if (aChar.properties & CBCharacteristicPropertyBroadcast) {//0x01

        }
        if (aChar.properties & CBCharacteristicPropertyRead) {//0x02
            [readCharacteristics setValue:aChar forKey:[aChar.UUID UUIDString]];
            [_cbPeripheral readValueForCharacteristic:aChar];
        }
        if (aChar.properties & CBCharacteristicPropertyWriteWithoutResponse) {//0x04
            [writeCharacteristics setValue:aChar forKey:[aChar.UUID UUIDString]];
        }
        if (aChar.properties & CBCharacteristicPropertyWrite) {//0x08
            [writeCharacteristics setValue:aChar forKey:[aChar.UUID UUIDString]];
        }
        if (aChar.properties & CBCharacteristicPropertyNotify) {//0x10
            [_cbPeripheral setNotifyValue:YES forCharacteristic:aChar];
        }
        if (aChar.properties & CBCharacteristicPropertyIndicate) {//0x20

        }
        if (aChar.properties & CBCharacteristicPropertyAuthenticatedSignedWrites) {//0x40

        }
        if (aChar.properties & CBCharacteristicPropertyExtendedProperties) {//0x80

        }
    }
}

- (NSString *)hexadecimalToString:(NSData *)data {

    const unsigned char *dataBuffer = (const unsigned char *)[data bytes];

    if (!dataBuffer)
        return [NSString string];

    NSUInteger          dataLength  = [data length];
    NSMutableString     *hexString  = [NSMutableString stringWithCapacity:(dataLength * 2)];

    for (int i = 0; i < dataLength; ++i)
        [hexString appendString:[NSString stringWithFormat:@"%02lx", (unsigned long)dataBuffer[i]]];

    return [NSString stringWithString:hexString];
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(nullable NSError *)error
{
    if (readResolve) {
        if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:readCharacteristicUUID]]) {
            NSString *value =[[NSString alloc] initWithData:characteristic.value encoding:NSUTF8StringEncoding];
            readResolve(@{@"value":value,@"readUUID":readCharacteristicUUID});
            readResolve = nil;
        }
    }

    if (self.delegate && [self.delegate respondsToSelector:@selector(didUpdateValueForCharacteristic:value:)]) {
        [self.delegate didUpdateValueForCharacteristic:[characteristic.UUID UUIDString] value:[self hexadecimalToString:characteristic.value]];
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(nullable NSError *)error
{
    if (!error)
    {
        if (writeResolve) {
            writeResolve(@{@"message":@"send succeed",@"writeUUID":[characteristic.UUID UUIDString]});
            writeResolve = nil;
        }
    }else{
        if (writeReject) {
            writeReject(@(error.code),error.localizedDescription,error);
            writeReject = nil;
        }
    }
}


@end
