//
//  BluetoothManager.h
//  RNBluetooth
//
//  Created by tcxy on 2017/2/16.
//  Copyright © 2017年 tcxy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
typedef void (^RCTPromiseResolveBlock)(id result);
typedef void (^RCTPromiseRejectBlock)(NSString *code, NSString *message, NSError *error);

@protocol BluetoothManagerDelegate <NSObject>

- (void)didDiscoverPeripheral:(NSDictionary<NSString *,id> *)peripheralInfo;

- (void)updateConnectionStatus:(BOOL)connect desc:(NSString *)desc;

- (void)didUpdateValueForCharacteristic:(NSString *)UUIDString value:(NSData *)value;
@end

@interface BluetoothManager : NSObject<CBPeripheralDelegate,CBCentralManagerDelegate>
{
    NSMutableArray *discoverPeripherals;
    NSMutableArray<CBUUID *> *serviceUUIDs;
    NSDictionary *scanOption;
    NSMutableDictionary *writeCharacteristics;
    NSMutableDictionary *readCharacteristics;
    NSString *readCharacteristicUUID;
    RCTPromiseResolveBlock writeResolve;
    RCTPromiseRejectBlock writeReject;
    RCTPromiseResolveBlock readResolve;
    RCTPromiseRejectBlock readReject;

}

@property (nonatomic, weak)id <BluetoothManagerDelegate>delegate;
@property (nonatomic, strong) CBCentralManager *cbManager;
@property (nonatomic, strong) CBPeripheral *cbPeripheral;

+ (instancetype)sharedInstance;

- (void)scanCBPeripheralsWithServiceUUIDs:(NSArray *)UUIDs
                          allowDuplicates:(BOOL)allowDuplicates
                           showPowerAlert:(BOOL)showPowerAlert;

- (void)stopScanCBPeripherals;
- (void)connectToCBPeripheral:(NSString *)identifier;
- (void)writeToCBPeripheralWithWriteCharUUID:(NSString *)UUID
                                     message:(NSString *)msg
                                    resolver:(RCTPromiseResolveBlock)resolve
                                    rejecter:(RCTPromiseRejectBlock)reject;

- (void)readCBCharacteristicValue:(NSString *)UUID
                         resolver:(RCTPromiseResolveBlock)resolve
                         rejecter:(RCTPromiseRejectBlock)reject;

- (void)disconnectToCBPeripheral;
@end
