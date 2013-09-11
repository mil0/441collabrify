//
//  ViewController.h
//  Collabo
//
//  Created by milo kock on 9/6/13.
//  Copyright (c) 2013 441. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Collabrify/Collabrify.h>

@interface ViewController : UIViewController
- (IBAction)undo:(id)sender;
- (IBAction)redo:(id)sender;
@property (weak, nonatomic) IBOutlet UITextView *textView;

@end
