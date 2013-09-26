//
//  MainMenu.h
//  Collabo
//
//  Created by Joshua Yu on 9/20/13.
//  Copyright (c) 2013 441. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Collabrify/Collabrify.h>
@interface MainMenu : UIViewController <UITextViewDelegate, CollabrifyClientDelegate, CollabrifyClientDataSource> {
    CollabrifyClient * client;
    
    UIAlertView * createSessionAlert;
    NSMutableString * sessionName;
    int64_t participationID;
}
//@property CollabrifyClient * client;
@end
