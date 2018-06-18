//
//  ChatEngine.h
//  FireChat
//
//  Created by Jaime Martinez on 8/4/15.
//  Copyright (c) 2015 TEST. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ChatEngineDelegate <NSObject>

-(void)messagedRecieved:(NSDictionary *)message;

@end

@interface ChatEngine : NSObject

@property(nonatomic, weak) id<ChatEngineDelegate> delegate;

-(void)advertiseMessage:(NSString*)strMessage withChatName: (NSString *)strTrollName andChatDate:(NSDate*)date;

@end
