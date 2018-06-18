//
//  ChatEngine.m
//  FireChat
//
//  Created by Jaime Martinez on 8/4/15.
//  Copyright (c) 2015 TEST. All rights reserved.
//

#import "ChatEngine.h"

#import <CoreBluetooth/CoreBluetooth.h>

static NSString *const TRANSFER_SERVICE_UUID = @"DB9ED48A-E8F4-4FF4-BB03-5C4E2D363F3A";
static NSString *const TRANSFER_CHARECTERISTIC_UUUID = @"D10C9F0C-5764-4BE2-A7B8-D550E4E2FD68";

@interface ChatEngine ()<CBCentralManagerDelegate, CBPeripheralDelegate, CBPeripheralManagerDelegate>

//Properties for Central manager
@property (nonatomic, strong) CBCentralManager *centralManager;
@property (nonatomic, strong) NSMutableSet *setDiscoveredPeripheral;
//@property (nonatomic, strong) CBPeripheral *discoveredPeripheral;

//Properties for Peripheral manager
@property(strong, nonatomic) CBPeripheralManager *peripheralManager;
@property(strong, nonatomic) CBMutableCharacteristic *transferCharecteristic;

@end

@implementation ChatEngine

- (instancetype)init
{
    self = [super init];
    if (self) {
        _centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
        _peripheralManager = [[CBPeripheralManager alloc] initWithDelegate:self queue:nil];
        _setDiscoveredPeripheral = [NSMutableSet new];
    }
    return self;
}

#pragma mark - Central Manager methods
-(void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    if( central.state == CBCentralManagerStatePoweredOff )
    {
        NSLog(@"Baby don't hurt me, and power on your dam bluetooth!");
        return;
    }
    else if( central.state == CBCentralManagerStatePoweredOn )
    {
        [central scanForPeripheralsWithServices:@[ [CBUUID UUIDWithString:TRANSFER_SERVICE_UUID] ]
                                        options:@{ CBCentralManagerScanOptionAllowDuplicatesKey : @YES}];
        NSLog(@"Scanning started");
    }
}
-(void)centralManager:(CBCentralManager *)central
didDiscoverPeripheral:(CBPeripheral *)peripheral
    advertisementData:(NSDictionary *)advertisementData
                 RSSI:(NSNumber *)RSSI
{
    NSLog(@"Discovered peripheral %@ at %@", peripheral.name, RSSI.stringValue);
    
    [self.setDiscoveredPeripheral addObject:peripheral];
    peripheral.delegate = self;
    [self.centralManager connectPeripheral:peripheral
                                   options:nil];
    /*
    if( self.discoveredPeripheral != peripheral ){
        self.discoveredPeripheral = peripheral;
        self.discoveredPeripheral.delegate = self;
        [self.centralManager connectPeripheral:self.discoveredPeripheral
                                       options:nil];
    }
    */
}
-(void)centralManager:(CBCentralManager *)central
 didConnectPeripheral:(CBPeripheral *)peripheral
{
    NSLog(@"connected");
    //[central stopScan];
    //NSLog(@"scanning stopped");
    peripheral.delegate = self;
    [peripheral discoverServices:@[ [CBUUID UUIDWithString:TRANSFER_SERVICE_UUID] ]];
}


#pragma mark - Peripheral methods
-(void)peripheral:(CBPeripheral *)peripheral
didDiscoverServices:(NSError *)error
{
    if ( error )
    {
        NSLog(@"%@", error);
        return;
    }
    
    for ( CBService *service in peripheral.services) {
        [peripheral discoverCharacteristics:@[ [CBUUID UUIDWithString:TRANSFER_CHARECTERISTIC_UUUID] ]
                                 forService:service];
    }
}
-(void)peripheral:(CBPeripheral *)peripheral
didDiscoverCharacteristicsForService:(CBService *)service
            error:(NSError *)error
{
    if ( error )
    {
        NSLog(@"%@", error);
        return;
    }
    
    for( CBCharacteristic *charecteristic in service.characteristics)
    {
        if( [charecteristic.UUID isEqual:[CBUUID UUIDWithString:TRANSFER_CHARECTERISTIC_UUUID]])
        {
            [peripheral setNotifyValue:YES forCharacteristic:charecteristic];
        }
    }
}
-(void)peripheral:(CBPeripheral *)peripheral
didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic
            error:(NSError *)error{
    if ( error )
    {
        NSLog(@"%@", error);
        return;
    }
    
    //NSString *stringFromData = [[NSString alloc] initWithData:characteristic.value
      //                                               encoding:NSUTF8StringEncoding];
    //NSData *messageData = [NSData new];
    //NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData: characteristic.value];
    NSDictionary *message = [NSJSONSerialization JSONObjectWithData:characteristic.value
                                                            options:NSJSONReadingAllowFragments
                                                              error:nil];
    //[unarchiver finishDecoding];
    
    //hey it's working
    [self.delegate messagedRecieved:message];
    
    [peripheral setNotifyValue:YES
             forCharacteristic:characteristic];
}


#pragma mark - Peripheral Manager methods
-(void)peripheralManagerDidStartAdvertising:(CBPeripheralManager *)peripheral
                                      error:(NSError *)error
{
    NSLog(@"%@", error);
}

-(void)peripheralManagerDidUpdateState:(CBPeripheralManager *)peripheral
{
    if( peripheral.state != CBPeripheralManagerStatePoweredOn)
    {
        NSLog(@"why you have bluetooth off yo : (");
        return;
    }
    
    if( peripheral.state == CBPeripheralManagerStatePoweredOn)
    {
        self.transferCharecteristic = [[CBMutableCharacteristic alloc] initWithType:[CBUUID UUIDWithString:TRANSFER_CHARECTERISTIC_UUUID]
                                                                         properties:CBCharacteristicPropertyNotify
                                                                              value:nil
                                                                        permissions:CBAttributePermissionsReadable];
        
        CBMutableService *transferService = [[CBMutableService alloc] initWithType:[CBUUID UUIDWithString:TRANSFER_SERVICE_UUID] primary:YES];
        
        transferService.characteristics = @[self.transferCharecteristic];
        [self.peripheralManager addService:transferService];
    }
    [_peripheralManager startAdvertising:@{CBAdvertisementDataServiceUUIDsKey:@[[CBUUID UUIDWithString:TRANSFER_SERVICE_UUID]]}];
}


//UTILITY POST
-(void)advertiseMessage:(NSString*)strMessage
           withChatName:(NSString*)strTrollName
            andChatDate:(NSDate*)date
{
    //NSString *strCombined = [NSString stringWithFormat:@"%@: %@", strTrollName, strMessage];
    
    NSDictionary *message = @{@"name": strTrollName,
                              @"message": strMessage,
                              @"date": date.description};
    NSData *messageData = [NSJSONSerialization dataWithJSONObject:message
                                                          options:NSJSONWritingPrettyPrinted
                                                            error:nil];

    
    [self.peripheralManager updateValue:messageData
                      forCharacteristic:self.transferCharecteristic
                   onSubscribedCentrals:nil];
}



@end
