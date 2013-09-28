//
//  SessionViewController.h
//  Collabo
//
//  Created by Joshua Yu on 9/20/13.
//  Copyright (c) 2013 441. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SessionViewController : UITableViewController{
    NSMutableArray * sessionList;
}
- (void) setSessionList:(NSArray *)list;


@end
