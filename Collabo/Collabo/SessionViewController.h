//
//  SessionViewController.h
//  Collabo
//
//  Created by Joshua Yu on 9/20/13.
//  Copyright (c) 2013 441. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Collabrify/Collabrify.h>
#import "ViewController.h"

@interface SessionViewController : UITableViewController{
    NSMutableArray * sessionList;
    CollabrifyClient * client;
    int32_t participationID;
}
- (void) setSessionList:(NSArray *)list;
- (void) setClient:(CollabrifyClient *)client_segue;

@end
