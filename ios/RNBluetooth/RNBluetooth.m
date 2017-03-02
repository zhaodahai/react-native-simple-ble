//
//  RNBluetooth.m
//  RNBluetooth
//
//  Created by dahai on 2017/2/16.
//  Copyright © 2017年 dahai. All rights reserved.
//

#import "RNBluetooth.h"



@implementation RNBluetooth

RCT_EXPORT_MODULE();

- (BluetoothManager *)blutoothManager
{
    _blutoothManager = [BluetoothManager sharedInstance];
    return _blutoothManager;
}

RCT_EXPORT_METHOD(scanPeripheralsWithServiceUUIDs:(NSArray *)UUIDs :(BOOL)allowDuplicates :(BOOL)showPowerAlert)
{
    [self.blutoothManager scanCBPeripheralsWithServiceUUIDs:[RCTConvert NSArray:UUIDs] allowDuplicates:allowDuplicates showPowerAlert:showPowerAlert];
}

RCT_EXPORT_METHOD(stopScanPeripherals)
{
    [self.blutoothManager stopScanCBPeripherals];
}

RCT_EXPORT_METHOD(connectToPeripheral:(NSString *)identifier)
{
    [self.blutoothManager connectToCBPeripheral:identifier];
}

RCT_EXPORT_METHOD(writeToPeripheralWithWriteUUID:(NSString *)UUID
                  message:(NSString *)msg
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)
{
    [self.blutoothManager writeToCBPeripheralWithWriteCharUUID:UUID message:msg resolver:resolve rejecter:reject];
}

RCT_EXPORT_METHOD(readValueForCharacteristicWithReadUUID:(NSString *)UUID
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)
{
    [self.blutoothManager readCBCharacteristicValue:UUID resolver:resolve rejecter:reject];
}

RCT_EXPORT_METHOD(disconnectToPeripheral)
{
    [self.blutoothManager disconnectToCBPeripheral];
}
@end
