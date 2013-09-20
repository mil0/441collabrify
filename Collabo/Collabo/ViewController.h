//
//  ViewController.h
//  Collabo
//
//  Created by milo kock on 9/6/13.
//  Copyright (c) 2013 441. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Collabrify/Collabrify.h>

@interface ViewController : UIViewController <UITextViewDelegate>{
    NSString * tempChange;
    NSString * initialText;
    NSTimer * eventDelay;
    CollabrifyClient * client;
}


- (IBAction)undo:(id)sender;
- (IBAction)redo:(id)sender;

- (IBAction)create:(id)sender;
- (IBAction)join:(id)sender;

- (void) connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response;
@property (weak, nonatomic) IBOutlet UITextView *textView;

@property NSString * initialText;

@end

