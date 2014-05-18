//
//  TextBarView.m
//  Buzzrd
//
//  Created by Brian Mancini on 5/17/14.
//  Copyright (c) 2014 Brian Mancini. All rights reserved.
//

#import "KeyboardTextView.h"

@interface KeyboardTextView()

@property (strong, nonatomic) UIButton *sendButton;

@end


@implementation KeyboardTextView

const int MARGIN_SIZE = 5;
const int BUTTON_WIDTH = 52;

-(id)initWithFrame:(CGRect)frame 
{
    self = [super initWithFrame:frame];
    if (self != nil)
    {
        // set view level properties
        self.backgroundColor = [[UIColor alloc]initWithRed:225.0f/255.0f green:225.0f/255.0f blue:225.0f/255.0f alpha:1.0f];
        
        // create the textbox
        self.textView = [[UITextView alloc] init];
        self.textView.frame = CGRectMake(40, MARGIN_SIZE, self.frame.size.width - 100, self.frame.size.height - (2 * MARGIN_SIZE));
        self.textView.editable = true;
        self.textView.keyboardType = UIKeyboardTypeDefault;
        self.textView.delegate = self;
        self.textView.backgroundColor = [UIColor whiteColor];
        self.textView.layer.masksToBounds = true;
        self.textView.layer.cornerRadius = 5.0f;
        self.textView.layer.borderWidth = 1.0f;
        self.textView.layer.borderColor = [[UIColor alloc]initWithRed:200.0f/255.0f green:200.0f/255.0f blue:200.0f/255.0f alpha:1.0f].CGColor;
        [self addSubview:self.textView];
        
        // create the send button
        self.sendButton = [[UIButton alloc]init];
        self.sendButton.frame = CGRectMake(self.frame.size.width - BUTTON_WIDTH - MARGIN_SIZE, MARGIN_SIZE, BUTTON_WIDTH, self.frame.size.height - (2 * MARGIN_SIZE));
        self.sendButton.backgroundColor = [UIColor orangeColor];
        self.sendButton.titleLabel.font = [UIFont fontWithName:@"Helvetica" size:12];
        self.sendButton.layer.masksToBounds = true;
        self.sendButton.layer.cornerRadius = 5.0f;
        [self.sendButton setTitle:@"Send" forState:UIControlStateNormal];
        [self.sendButton addTarget:self action:@selector(sendTouchedAction) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.sendButton];
        
        // create hooks for keyboard
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(onKeyboardOpen:)
                                                     name:UIKeyboardWillShowNotification
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(onKeyboardClose:)
                                                     name:UIKeyboardWillHideNotification
                                                   object:nil];
    }
    return self;
}

#pragma mark - Instance Methods

- (void)dismissKeyboard
{
    [self.textView resignFirstResponder];
}

#pragma mark -  Action Handlers


-(void)sendTouchedAction
{
    NSString *message = self.textView.text;
    self.textView.text = @"";
    
    // TODO reset the size of the textview
    
    [self.delegate keyboardTextView:self sendTouched:message];
}


#pragma mark - Keyboard methods

-(void)onKeyboardOpen:(NSNotification *)notification
{
    // This code will move the keyboard
    NSDictionary *userInfo = [notification userInfo];
    NSTimeInterval animationDuration;
    UIViewAnimationCurve animationCurve;
    CGRect keyboardEndFrame;
 
    [[userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] getValue:&animationCurve];
    [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] getValue:&animationDuration];
    [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] getValue:&keyboardEndFrame];
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:animationDuration];
    [UIView setAnimationCurve:animationCurve];
    
    CGRect newFrame = self.frame;
    newFrame.origin.y = keyboardEndFrame.origin.y - newFrame.size.height;
    self.frame = newFrame;
    
    [UIView commitAnimations];
}

-(void)onKeyboardClose:(NSNotification *)notification
{
    NSDictionary *keyboardInfo = [notification userInfo];
    NSValue *keyboardFrameEnd = [keyboardInfo valueForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardFrameEndRect = [keyboardFrameEnd CGRectValue];
    
    CGRect newFrame = self.frame;
    newFrame.origin.y = keyboardFrameEndRect.origin.y - newFrame.size.height;
}


#pragma mark - UITextViewDelegate methods

-(BOOL)textViewShouldBeginEditing:(UITextView *)aTextView
{
    return true;
}

-(void)textViewDidEndEditing:(UITextView *)textView
{
    [self.textView resignFirstResponder];
}

-(void)textViewDidChange:(UITextView *)textView
{
    if(textView.frame.size.height != textView.contentSize.height)
    {
        float delta = textView.contentSize.height - textView.frame.size.height;
        
        // change textview size
        CGRect textViewFrame = textView.frame;
        textViewFrame.size.height = textView.contentSize.height;
        textView.frame = textViewFrame;
        
        // change view size
        CGRect inputFrame = self.frame;
        inputFrame.size.height = inputFrame.size.height + delta;
        inputFrame.origin.y = inputFrame.origin.y - delta;
        self.frame = inputFrame;
        
        // change button position
        CGRect buttonFrame = self.sendButton.frame;
        buttonFrame.origin.y = buttonFrame.origin.y + delta;
        self.sendButton.frame = buttonFrame;
    }
}




@end
