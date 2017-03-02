# react-native-simple-ble
[![npm version](https://img.shields.io/npm/v/react-native-simple-ble.svg?style=flat)](https://www.npmjs.com/package/react-native-simple-ble)

Currently only support ios and require react-native >= 0.40.0


##Installation
1. Install library from `npm`

    ```shell
    npm install react-native-simple-ble --save
    ```
2. Link native code

    ```bash
    react-native link react-native-simple-ble
    ```

##Usage
```js
import ble from 'react-native-simple-ble'
```

##Methods

### scan(UUIDs,allowDuplicates,showPowerAlert)
  Scaning peripherals.
  See method `registerDiscoverPeripheral()`.

__Arguments__
The parameter is optional the configuration keys are:
- `UUIDs` - `Array of String` - [default empty] If you confirm the service UUID in the broadcast information,fill the UUID,block out you don't want, otherwise not.
- `allowDuplicates` - `Boolean` - [default false] Allow scanning duplicates.
- `showPowerAlert` - `Boolean` -  [default true] Show or hide the alert if the bluetooth is turned off during initialization.

__Examples__
```js
ble.scan();
// ble.scan(['XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX']);
```

### stopScan()
Stop the scanning.

__Examples__
```js
ble.stopScan();
```

### connect(identifier)
Connect to a specified peripheral.

__Arguments__
- `identifier` - `String` - Using the method you have to obtain the `identifier` before ,from
method `registerDiscoverPeripheral()`.

__Examples__
```js
ble.connect('XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX')
```

### disconnect()
Disconnect from a peripheral.

__Examples__
```js
ble.disconnect();
```

### write(msg,UUID)
Write to the specified characteristic.

Returns a `Promise` object.

__Arguments__

- `msg` - `String` - The data to write hexstring.(e.g. 'ABCDEF0123456789')
- `UUID` - `String` - [default empty] If you confirm the write more than one characteristic,fill in your specified write characteristic UUID , otherwise not.

__Examples__
```js
// ble.write('ABCDEF0123456789')
ble.write('ABCDEF0123456789','XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX')
  .then((result) =>{
    console.log(result.writeUUID+' : ' +result.message);
  })
  .catch((error) =>{
    console.log(error);
  })
```
- `result.writeUUID` - `String` - write characteristic UUID.
- `result.message` - `String` - write state message.
- `error` - error.

### read(UUID)
Read value for the specified characteristic.

Returns a `Promise` object.

__Arguments__

- `UUID` - `String` - the UUID of the read characteristic.

__Examples__
```js
ble.read('XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX')
  .then((result) =>{
    console.log(result.readUUID+' : '+result.value);
  })
  .catch((error)=>{
    console.log(error);
  })
```
- `result.writeUUID` - `String` - read characteristic UUID.
- `result.value` - `String` - characteristic value.
- `error` - error.

## Events

### registerUpdateConnectionStatus(callback)
Register a callback to monitor the connection status.

The status changed callback.

__Examples__
```js
ble.registerUpdateConnectionStatus((param)=>{
  console.log(param.connect+','+param.desc);
});
```
- `param.connect` - `Boolean` - Is connect or not.
- `param.desc` - `String` - Error message description.

### registerDiscoverPeripheral()
Register a callback to monitor discover peripherals.see method `connect()`.

Once found a peripheral callback.

__Examples__
```js
ble.registerDiscoverPeripheral((param)=>{
  console.log(param.name+','+param.identifier);
});
```
- `param.name` - `String` - Peripheral's name.
- `param.identifier` - `String` - Peripheral's identifier.Using connection,see method `connect()`.
- `param.RSSI` - `Number` - Peripheral received signal strength indicator.
- `...` - (broadcast information)


### registerDidUpdateValueForCharacteristic()
Register a callback to monitor characteristic value.

Characteristic value did update callback.You can get all peripheral sending data from here.

__Examples__
```js
ble.registerDidUpdateValueForCharacteristic((param)=>{
  console.log(param.UUID+' : ',param.value);
});
```
- `param.UUID` - `String` - Characteristic UUID.
- `param.value` - `String` - Characteristic value.
