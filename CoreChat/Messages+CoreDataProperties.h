//
//  Messages+CoreDataProperties.h
//  CoreChat
//
//  Created by admin on 4/19/16.
//  Copyright © 2016 admin. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Messages.h"

NS_ASSUME_NONNULL_BEGIN

@interface Messages (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *message;
@property (nullable, nonatomic, retain) NSDate *date;
@property (nullable, nonatomic, retain) NSManagedObject *ofUser;

@end

NS_ASSUME_NONNULL_END
