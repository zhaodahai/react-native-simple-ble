//
//  RNBluetoothEvent.m
//  RNBluetooth
//
//  Created by tcxy on 2017/2/27.
//  Copyright © 2017年 tcxy. All rights reserved.
//

#import "RNBluetoothEvent.h"

@implementation RNBluetoothEvent
RCT_EXPORT_MODULE();

- (instancetype)init
{
    if (self = [super init]) {
        self.blutoothManager = [BluetoothManager sharedInstance];
        self.blutoothManager.delegate = self;
    }
    return self;
}

- (NSArray<NSString *> *)supportedEvents {
    return @[@"didDiscoverPeripheral",@"updateConnectionStatus",@"didUpdateValueForCharacteristic"];
}

#pragma - mark BluetoothManagerDelegate
- (void)didDiscoverPeripheral:(NSDictionary<NSString *,id> *)peripheralInfo
{
    [self sendEventWithName:@"didDiscoverPeripheral" body:peripheralInfo];
}

- (void)updateConnectionStatus:(BOOL)connect desc:(NSString *)desc
{
    [self sendEventWithName:@"updateConnectionStatus" body:@{@"connect":@(connect),@"desc":desc?:@""}];
}

- (void)didUpdateValueForCharacteristic:(NSString *)UUIDString value:(NSData *)value
{
    [self sendEventWithName:@"didUpdateValueForCharacteristic" body:@{@"UUID":UUIDString,@"value":value}];
}

@end
