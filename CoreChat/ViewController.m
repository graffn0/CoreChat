//
//  ViewController.m
//  CoreChat
//
//  Created by admin on 4/19/16.
//  Copyright © 2016 admin. All rights reserved.
//

#import "ViewController.h"
#import "CCell.h"
#import "AppDelegate.h"
#import "Users.h"
#import "Messages.h"
#import "ChatEngine.h"

@interface ViewController() <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, ChatEngineDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tblChat;
@property (weak, nonatomic) IBOutlet UITextField *txtChatMessage;
@property (weak, nonatomic) IBOutlet UITextField *txtOther;
@property (strong, nonatomic) NSMutableDictionary *users;
@property (strong, nonatomic) NSMutableArray *results;
@property (strong, nonatomic) ChatEngine *cEngine;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self updateData];
    self.users = [NSMutableDictionary new];
    self.cEngine = [ChatEngine new];
    self.cEngine.delegate = self;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateView:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateView:) name:UIKeyboardWillShowNotification object:nil];
}

-(void)updateView:(NSNotification*)notification {
    float duration = [notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] floatValue];
    CGRect keyboard = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    float yNew = keyboard.origin.y - self.view.frame.size.height;
    [UIView animateWithDuration:duration animations:^{
        self.view.frame = CGRectMake(self.view.frame.origin.x, yNew, self.view.frame.size.width, self.view.frame.size.height);
        //self.view
    }];
}

- (IBAction)btnCamera:(id)sender {
}
- (IBAction)btnMicrophone:(id)sender {
}
- (IBAction)btnRefresh:(id)sender {
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    
    if (textField.text.length > 0) {
        if(textField == self.txtOther) {
            
            [self updateUser:self.txtOther.text];
        }
    
        if (textField == self.txtChatMessage && self.txtOther.text > 0) {
            [self utilityMethod:self.txtChatMessage.text forUser:self.txtOther.text atDate:[NSDate new]];
            [self.cEngine advertiseMessage:self.txtChatMessage.text withChatName:self.txtOther.text andChatDate: [NSDate new]];
        }
    }
    return true;
}

-(void)updateUser:(NSString*)strUserName {
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *MOC = appDelegate.managedObjectContext;
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Users"];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name = %@", strUserName];
    [fetchRequest setPredicate:predicate];
    if ([[MOC executeFetchRequest:fetchRequest error:nil] count] == 0) {
        Users *aUser = [NSEntityDescription insertNewObjectForEntityForName:@"Users" inManagedObjectContext:MOC];
        aUser.name = strUserName;
        aUser.nameHasMessages = [NSMutableSet new];
        [MOC save:nil];
    }
}

-(void)updateData {
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *MOC = appDelegate.managedObjectContext;
    
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Messages"];
     self.results = [[MOC executeFetchRequest:fetchRequest error:nil] mutableCopy];
    [self.results sortUsingComparator:^NSComparisonResult(Messages *obj1, Messages *obj2) {
        return [obj1.date compare: obj2.date];
    }];
    [self.tblChat reloadData];
    NSIndexPath *ip = [NSIndexPath indexPathForRow:self.results.count-1 inSection:0];
    [self.tblChat scrollToRowAtIndexPath:ip atScrollPosition:UITableViewScrollPositionBottom animated:YES];
}



-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return self.results.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    Messages *mess =(Messages*) self.results[indexPath.row];
    Users * user =(Users*) mess.ofUser;
    NSString *identifier = self.txtOther.text == user.name ? @"meCell" : @"themCell";
    CCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];
    NSDateFormatter *df = [NSDateFormatter new];
    [df setTimeStyle:NSDateFormatterShortStyle];
    cell.lblChat.text = [NSString stringWithFormat:@"%@\n%@\n%@", user.name, mess.message, [df stringFromDate:mess.date]];
    /*
    if (self.txtOther.text == user.name) {
        MeCell *cell = [tableView dequeueReusableCellWithIdentifier:@"meCell" forIndexPath:indexPath];
        cell.lblChat.text = mess.message;
        return cell;
    } else {
        ChatCell *cell = [tableView dequeueReusableCellWithIdentifier:@"themCell" forIndexPath:indexPath];
        cell.lblChat.text = mess.message;
        return cell;
    }
     */
    return cell;
}

-(void)messagedRecieved:(NSDictionary *)message {
    NSDateFormatter *df = [NSDateFormatter new];
    [df setDateFormat:@"yyyy-MM-DD HH:mm:ss ZZZ"];
    NSDate *date = [df dateFromString:message[@"date"]];
    
    [self updateUser:message[@"name"]];
    [self utilityMethod:message[@"message"] forUser:message[@"name"] atDate:date];
}

-(void)utilityMethod:(NSString*)message forUser:(NSString*)strUser atDate:(NSDate*)date {
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *MOC = appDelegate.managedObjectContext;
    Messages *aMessage = [NSEntityDescription insertNewObjectForEntityForName:@"Messages" inManagedObjectContext:MOC];
    aMessage.message = message;
    aMessage.date = date;
    Users *user = self.users[strUser];
    aMessage.ofUser = user;
    
    [user.nameHasMessages setByAddingObject:aMessage];
    [MOC save:nil];
    
    self.txtChatMessage.text = @"";
    
    [self updateData];
}

@end
