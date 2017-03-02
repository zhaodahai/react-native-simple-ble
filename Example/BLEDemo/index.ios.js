/**
 * Sample React Native App
 * https://github.com/facebook/react-native
 * @flow
 */

 import React, { Component } from 'react';
 import {
   AppRegistry,
   StyleSheet,
   Text,
   View,
   ListView,
   Button,
   TouchableOpacity,
   TextInput,
   Keyboard,
 } from 'react-native';

 import ble from 'react-native-simple-ble'
 var peripherals = [];

 const UUID_DEVICE_INFO_SERVICE = 'XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX'
 const UUID_SERVICE             = 'XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX'
 const UUID_WRITE               = 'XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX'

 export default class BLEDemo extends Component {

   constructor(props){
     super(props);
     this.state={
       statusDesc:'',
       msg:'',
       dataSource:new ListView.DataSource({rowHasChanged: (r1, r2) => r1.guid !== r2.guid})
     }
   }

   componentDidMount(){

     ble.registerUpdateConnectionStatus((param)=>{
       this.setState({statusDesc:param.desc});
     });

     ble.registerDiscoverPeripheral((param)=>{
       peripherals.push([param.name,param.identifier]);
       this.setState({dataSource:this.state.dataSource.cloneWithRows(peripherals)})
     });

     ble.registerDidUpdateValueForCharacteristic((param)=>{
       console.log(param.UUID+' : ',param.value);
     });

   }

   scan = () =>{
     peripherals = [];
     this.setState({dataSource:this.state.dataSource.cloneWithRows(peripherals)})
     ble.scan();
   }

   stopScan = () =>{
     ble.stopScan();
   }

   readValue = () =>{
     ble.read(UUID_DEVICE_INFO_SERVICE)
       .then((result) =>{
         console.log('read ' + result.readUUID+' : '+result.value);
       })
       .catch((e)=>{
         console.log('read ' +e);
       })
   }

   disconnect = () =>{
     ble.disconnect();
   }

   sendMsg = () =>{
     Keyboard.dismiss();
     this.setState({statusDesc:'send:'+this.state.msg});
     ble.write(this.state.msg,UUIDSTR_ISSC_TRANS_WRITE)
       .then((result) =>{
         console.log('write '+result.writeUUID+' : ' +result.message);
       })
       .catch((e) =>{
         console.log('write '+ e);
       })
   }

   rowPressed(data,index){
     ble.connect(data[1]);
   }

   renderRow = (rowData, sectionID, rowID) =>{
     return (
             <TouchableOpacity style={{height:45,justifyContent:'center'}}
                               underlayColor='transparent'
                               onPress={() => this.rowPressed(rowData,rowID)}>
               <Text style={{fontSize:12,flex:1}}>{rowData[0]+' : '+rowData[1]}</Text>
             </TouchableOpacity>
     );
   }

   render() {
     return (
       <View style={{flex:1}}>
         <Text style={{marginTop:40,height:30,textAlign:'center',fontSize:18,color:'red'}}>{this.state.statusDesc}</Text>
         <View style={{height:40,marginTop:6,flexDirection:'row',justifyContent: 'space-between'}}>
           <Button onPress={this.scan}
                   title='scan'/>
           <Button onPress={this.stopScan}
                   title='stopScan'/>
           <Button onPress={this.disconnect}
                   title='disconnect'/>
           <Button onPress={this.readValue}
                   title='read'/>
         </View>

         <View style={{backgroundColor:'gold',flexDirection:'row',height:40,}}>
           <TextInput style={{marginTop:5,height:30,marginLeft:30,marginRight:20,flex:1,backgroundColor:'white'}}
                      keyboardType='web-search'
                      onChangeText={(text) => this.setState({msg:text})}
                       />
           <Button title='发送'
                   onPress={this.sendMsg}
                   />
         </View>

         <View style={{marginTop:10,flexDirection:'row',}}>
           <Text style={{fontSize:15,color:'fuchsia',width:50}}>peripherals:</Text>
           <ListView style={{padding:5,height:250,backgroundColor:'lightgreen'}}
                     dataSource={this.state.dataSource}
                     renderRow={this.renderRow}
                     enableEmptySections = {true}
                     />
         </View>
       </View>
     );
   }
 }

 const styles = StyleSheet.create({
   button: {
     borderColor: '#000',
     borderWidth: StyleSheet.hairlineWidth,
   },
 });

AppRegistry.registerComponent('BLEDemo', () => BLEDemo);
