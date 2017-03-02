//
//  RNBluetoothEvent.h
//  RNBluetooth
//
//  Created by tcxy on 2017/2/27.
//  Copyright © 2017年 tcxy. All rights reserved.
//

#import <React/RCTEventEmitter.h>
#import "BluetoothManager.h"
@interface RNBluetoothEvent : RCTEventEmitter<BluetoothManagerDelegate>
@property (nonatomic , strong) BluetoothManager *blutoothManager;

@end
