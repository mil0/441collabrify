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
}
- (IBAction)join:(id)sender;
- (IBAction)undo:(id)sender;
- (IBAction)redo:(id)sender;
- (IBAction)create:(id)sender;
@property (weak, nonatomic) IBOutlet UITextView *textView;
@property NSString * initialText;
@end

