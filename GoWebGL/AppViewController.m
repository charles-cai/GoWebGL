/*
 - copyright (c) 2011 Copenhagen Institute of Interaction Design (CIID)
 - all rights reserved.
 
 + redistribution and use in source and binary forms, with or without
 + modification, are permitted provided that the following conditions
 + are met:
 +  > redistributions of source code must retain the above copyright
 +    notice, this list of conditions and the following disclaimer.
 +  > redistributions in binary form must reproduce the above copyright
 +    notice, this list of conditions and the following disclaimer in
 +    the documentation and/or other materials provided with the
 +    distribution.
 
 + THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
 + "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
 + LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
 + FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE
 + COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,
 + INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
 + BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS
 + OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED
 + AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
 + OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT
 + OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
 + SUCH DAMAGE.
 
 ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 ~ author: dviid
 ~ contact: dviid@ciid.dk 
 
 The UIWebView hack was discovered by Nathan de Vries and can be found 
 here -> atnan.com/​blog/​2011/​11/​03/​enabling-and-using-webgl-on-ios/​
 
 */

#import "AppViewController.h"

#import <QuartzCore/QuartzCore.h>

@implementation AppViewController

- (void)loadView
{
    [super loadView];            
    
    //-> init + setup UIWebView (from Nathan)
    UIWebView* webView = [[[UIWebView alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
    id webDocumentView = [webView performSelector:@selector(_browserView)];
    id backingWebView = [webDocumentView performSelector:@selector(webView)];
    [backingWebView _setWebGLEnabled:YES]; //<-- !!!
    [webView setDelegate:self];
    
    //-> set as main view
    [self setView:webView];
    
    CGRect webViewRect = [webView bounds];
    
    float mx = webViewRect.size.width / 2 + webViewRect.origin.x;
    float my = webViewRect.size.height / 2 + webViewRect.origin.y;
    float sx = webViewRect.size.width - 50;
    
    //-> text input views
    CGRect viewRect = { mx - sx / 2, my - my / 2, sx, 40.0  };
    _textview_container = [[UIView alloc] initWithFrame:viewRect];
    [webView addSubview:_textview_container]; 
    
    _textview = [[UIView alloc] initWithFrame:_textview_container.bounds];
    UIColor* viewCol = [[UIColor alloc] initWithRed:0.98 green:1.0 blue:0.01 alpha:0.5];
    _textview.layer.cornerRadius = 8.0f;
    [_textview setBackgroundColor:viewCol];
    [_textview setOpaque:YES];
    
    [_textview_container addSubview:_textview];
    
    CGRect textRect = {15, 15, 2 * viewRect.size.width / 3, 30};
    UITextField *textField = [[UITextField alloc] initWithFrame:textRect];
    [textField setBackgroundColor:[UIColor whiteColor]];
    [textField setBorderStyle:UITextBorderStyleRoundedRect];
    textField.layer.cornerRadius = 5.0f;
    textField.clearsOnBeginEditing = YES;
    textField.clearButtonMode = UITextFieldViewModeWhileEditing;
    [textField setOpaque:YES];
    [textField setPlaceholder:@">>> URL...!"];    
    [textField setReturnKeyType:UIReturnKeyDone];
    [textField setEnablesReturnKeyAutomatically:YES];
    [textField setTag:007];
    [textField setDelegate:self];
    
    [_textview addSubview:textField];
    
    CGRect goRect = { textRect.origin.x + textRect.size.width + 15, textRect.origin.y - 5, 50, 50 };
    UIButton *go = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [go setFrame:goRect];
    [go setTitle:@"GO!" forState:UIControlStateNormal];
    [go setTitleColor:[UIColor grayColor] forState: UIControlStateNormal];
    [go setTitleColor:[UIColor whiteColor] forState: UIControlStateSelected];
    [go setBackgroundImage:[UIImage imageNamed:@"marcin.png"] forState: UIControlStateHighlighted];
    [go addTarget:self action:@selector(go) forControlEvents:UIControlEventTouchUpInside];
    
    [_textview addSubview:go];   
    
    //-> gestures
        
    UISwipeGestureRecognizer *swiperec = 
    [[[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swiperight:)] autorelease];
    [swiperec setDirection:UISwipeGestureRecognizerDirectionRight];
    [swiperec setDelegate:self];        
    [[self view] addGestureRecognizer:swiperec];    
    
    swiperec = 
    [[[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeleft:)] autorelease];
    [swiperec setDirection:UISwipeGestureRecognizerDirectionLeft];
    [swiperec setDelegate:self];        
    [[self view] addGestureRecognizer:swiperec];  
    
    UITapGestureRecognizer *taprec = 
    [[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)] autorelease];
    [taprec setNumberOfTapsRequired:2];
    [taprec setNumberOfTouchesRequired:2];
    [taprec setDelegate:self];
    [[self view] addGestureRecognizer:taprec];    
    
    //-> fullscreen
    [[UIApplication sharedApplication] setStatusBarHidden:YES animated:YES];        
    
}

- (void) go
{
     NSLog(@"go");
    UITextField *txtf = (UITextField *)[[self view] viewWithTag:007];
    _query = [[txtf text] copy];    
    [txtf resignFirstResponder];
    
    NSURL *url = [NSURL URLWithString:_query];
    NSURLRequest* request = [NSURLRequest requestWithURL:url];
    [((UIWebView*)self.view) loadRequest:request];
    
    
}

- (void) querybox_show
{
    [UIView transitionWithView:_textview_container duration:0.8
                       options:UIViewAnimationOptionTransitionFlipFromTop
                    animations:^ { [_textview_container addSubview:_textview]; }
                    completion:nil];                
}

- (void) querybox_hide
{
    [UIView transitionWithView:_textview_container duration:0.8
                       options:UIViewAnimationOptionTransitionFlipFromBottom
                    animations:^ { [_textview removeFromSuperview]; }
                    completion:nil];   
}

- (void) flip:(NSTimer*)waahoo
{
    UITextField *txtf = (UITextField *)[[self view] viewWithTag:007];
    [self querybox_hide];    
    txtf.text = [_query_success copy]; 
    [self querybox_show];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

- (void) swiperight:(UISwipeGestureRecognizer *)recognizer
{
    NSLog(@"swipe right");
    [((UIWebView*)[self view]) goBack];
}

- (void) swipeleft:(UISwipeGestureRecognizer *)recognizer
{
    NSLog(@"swipe left");
    [((UIWebView*)[self view]) goForward];
}

- (void) tap:(UISwipeGestureRecognizer *)recognizer
{
    NSLog(@"tap");
    [self querybox_show];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self go];
    return TRUE;
}

- (BOOL)textFieldShouldClear:(UITextField *)textField 
{
    if(_query_success) {
        ((UITextField *)[[self view] viewWithTag:007]).text = _query_success;
        return NO;
    }
    return YES;
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    NSLog(@"didFailLoadWithError");
    UITextField *txtf = (UITextField *)[[self view] viewWithTag:007];
    txtf.text = @"<---> ERROR <--->"; 
    
    NSTimer* t = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                  target:self 
                                                selector:@selector(flip:) 
                                                userInfo:nil 
                                                 repeats:NO];    
    [t fire];
    
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    NSLog(@"webViewDidFinishLoad");      
    _query_success = [_query copy];
    
    [self querybox_hide];        
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    NSLog(@"webViewDidStartLoad");
    UITextField *txtf = (UITextField *)[[self view] viewWithTag:007];
    txtf.text = @"...... LOADING ......";     
}

- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event {
    if (event.type == UIEventSubtypeMotionShake) {
        [self querybox_show];
    }
}

- (void) dealloc
{
    [_textview release];
    [_textview_container release];
}


@end
