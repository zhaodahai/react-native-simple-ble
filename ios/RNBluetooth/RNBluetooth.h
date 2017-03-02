//
//  RNBluetooth.h
//  RNBluetooth
//
//  Created by dahai on 2017/2/16.
//  Copyright © 2017年 dahai. All rights reserved.
//
#import <Foundation/Foundation.h>
#import <React/RCTBridgeModule.h>
#import <React/RCTConvert.h>
#import "BluetoothManager.h"


@interface RNBluetooth : NSObject<RCTBridgeModule>


@property (nonatomic , strong) BluetoothManager *blutoothManager;

@end
