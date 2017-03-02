
'use strict'
import React,{Component} from 'react';
import {NativeModules,NativeEventEmitter} from 'react-native';
const defaultManager = NativeModules.RNBluetooth;
const defaultEvent = new NativeEventEmitter(NativeModules.RNBluetoothEvent);

function scan(UUIDs=[],allowDuplicates=false,showPowerAlert=true){
  defaultManager.scanPeripheralsWithServiceUUIDs(UUIDs,allowDuplicates,showPowerAlert);
}

function stopScan(){
  defaultManager.stopScanPeripherals();
}

function connect(identifier){
  defaultManager.connectToPeripheral(identifier);
}

function write(msg,UUID){
  return defaultManager.writeToPeripheralWithWriteUUID(UUID,msg);
}

function read(UUID){
  return defaultManager.readValueForCharacteristicWithReadUUID(UUID);
}

function disconnect(){
  defaultManager.disconnectToPeripheral();
}

function registerUpdateConnectionStatus(callback){
  defaultEvent.addListener('updateConnectionStatus',(param) =>{
    callback(param);
  })
}

function registerDiscoverPeripheral(callback){
  defaultEvent.addListener('didDiscoverPeripheral',(param) =>{
    callback(param);
  })
}

function registerDidUpdateValueForCharacteristic(callback){
  defaultEvent.addListener('didUpdateValueForCharacteristic',(param) =>{
    callback(param);
  })
}

export {
  scan,
  stopScan,
  connect,
  write,
  read,
  disconnect,

  registerUpdateConnectionStatus,
  registerDiscoverPeripheral,
  registerDidUpdateValueForCharacteristic
}
