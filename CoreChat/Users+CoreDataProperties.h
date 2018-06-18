//
//  Users+CoreDataProperties.h
//  CoreChat
//
//  Created by admin on 4/19/16.
//  Copyright © 2016 admin. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Users.h"

NS_ASSUME_NONNULL_BEGIN

@interface Users (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *name;
@property (nullable, nonatomic, retain) NSSet<Messages *> *nameHasMessages;

@end

@interface Users (CoreDataGeneratedAccessors)

- (void)addNameHasMessagesObject:(Messages *)value;
- (void)removeNameHasMessagesObject:(Messages *)value;
- (void)addNameHasMessages:(NSSet<Messages *> *)values;
- (void)removeNameHasMessages:(NSSet<Messages *> *)values;

@end

NS_ASSUME_NONNULL_END
