/*
 * Copyright (c) 2015 Dave Alden  (http://github.com/dpa99c)
 *
 * Permission is hereby granted, free of charge, to any person
 * obtaining a copy of this software and associated documentation
 * files (the "Software"), to deal in the Software without
 * restriction, including without limitation the rights to use,
 * copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the
 * Software is furnished to do so, subject to the following
 * conditions:
 *
 * The above copyright notice and this permission notice shall be
 * included in all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
 * OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
 * HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
 * WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
 * OTHER DEALINGS IN THE SOFTWARE.
 *
 */
#import "LaunchReview.h"
#import "StoreKit/StoreKit.h"


@implementation LaunchReview

- (void)pluginInitialize {
    [super pluginInitialize];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(windowDidBecomeVisibleNotification:)
                                                 name:UIWindowDidBecomeVisibleNotification
                                               object:nil];
}

- (void) launch:(CDVInvokedUrlCommand*)command;
{
    @try {
        CDVPluginResult* pluginResult;
        NSString* appId = [command.arguments objectAtIndex:0];
#if defined(__IPHONE_11_0) && __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_11_0
        NSString* iTunesLink = [NSString stringWithFormat:@"itms-apps://itunes.apple.com/xy/app/foo/id%@?action=write-review", appId];
#else
        NSString* iTunesLink = [NSString stringWithFormat:@"itms-apps://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?type=Purple+Software&id=%@&action=write-review", appId];
#endif
    
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:iTunesLink]];
        
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }
    @catch (NSException *exception) {
        [self handlePluginException:exception :command];
    }
}

- (void) rating:(CDVInvokedUrlCommand*)command;
{
    @try {
        CDVPluginResult* pluginResult;
        
#if defined(__IPHONE_10_3) && __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_10_3
        
        self.ratingRequestCallbackId = command.callbackId;
        
        [SKStoreReviewController requestReview];
        
        
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"requested"];
        [pluginResult setKeepCallback:[NSNumber numberWithBool:YES]];
#else
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Rating dialog requires iOS 10.3+"];
#endif
        
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }
    @catch (NSException *exception) {
        [self handlePluginException:exception :command];
    }
}

- (void) handlePluginException: (NSException*) exception :(CDVInvokedUrlCommand*)command
{
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:exception.reason];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)windowDidBecomeVisibleNotification:(NSNotification *)notification
{
    if ([notification.object isKindOfClass:NSClassFromString(@"SKStoreReviewPresentationWindow")]) {
        CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"shown"];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:self.ratingRequestCallbackId];
    }
}


@end

