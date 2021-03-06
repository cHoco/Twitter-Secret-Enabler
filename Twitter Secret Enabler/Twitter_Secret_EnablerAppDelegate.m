/*
 Twitter_Secret_EnablerAppDelegate.m
 Twitter Secret Enabler
 
 Created by Enrico Ghirardi on 10/07/11.
 
 Copyright 2011 Enrico "cHoco" Ghirardi
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this work except in compliance with the License.
 You may obtain a copy of the License in the LICENSE file, or at:
 
 http://www.apache.org/licenses/LICENSE-2.0
 
 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
*/

#import "Twitter_Secret_EnablerAppDelegate.h"

@implementation Twitter_Secret_EnablerAppDelegate

@synthesize window, emailText, moreInfoLabel, patchButton;

- (void)dealloc
{
    [moreInfoLabel release];
    [patchButton release];
    [emailText release];
    [window release];
    [super dealloc];
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender
{
    return YES;
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
    
    INAppStoreWindow *aWindow = (INAppStoreWindow*)self.window;
    aWindow.titleBarHeight = 36;
    [self.window center];
    
    NSTextField *titleLabel;
    titleLabel = [[NSTextField alloc] initWithFrame:NSMakeRect(0, 11, 240, 17)];
    [titleLabel.cell setBackgroundStyle:NSBackgroundStyleRaised];
    [titleLabel setStringValue:@"Twitter Secret Enabler"];
    [titleLabel setAlignment:NSRightTextAlignment];
    [titleLabel setFont:[NSFont fontWithName:@"Lucida Grande" size:14]];
    [titleLabel setTextColor:[NSColor colorWithCalibratedWhite:0.15 alpha:1]];
    [titleLabel setBezeled:NO];
    [titleLabel setDrawsBackground:NO];
    [titleLabel setEditable:NO];
    [titleLabel setSelectable:NO];
    [aWindow.titleBarView addSubview:titleLabel];
    [titleLabel release];

    [moreInfoLabel setAllowsEditingTextAttributes:YES];
    [moreInfoLabel setSelectable:YES];
    NSURL* url = [NSURL URLWithString:@"http://twitter.com/icHoco"];
    NSMutableAttributedString* string = [[NSMutableAttributedString alloc] init];
    [string appendAttributedString:[NSAttributedString hyperlinkFromString:@"cHoco" withURL:url]];
    [moreInfoLabel setAttributedStringValue:string];
    [string release];
}

- (NSString *)sha1:(NSString *)str {
    const char *cStr = [str UTF8String];
    unsigned char result[CC_SHA1_DIGEST_LENGTH];
    CC_SHA1(cStr, (unsigned int)strlen(cStr), result);
    NSString *s = [NSString  stringWithFormat:
                   @"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
                   result[0], result[1], result[2], result[3], result[4],
                   result[5], result[6], result[7],
                   result[8], result[9], result[10], result[11], result[12],
                   result[13], result[14], result[15],
                   result[16], result[17], result[18], result[19]
                   ];
    return [s lowercaseString];
}

- (IBAction)startPatching:(id)sender {
    if ([[emailText stringValue] length]>0) {
        if ([self twitterIsRunning]==NO) {
            [self patchTwitterPlist];
        }
        else
            ;//TODO Tell user to close twitter app for security
    }
    else
        ;//TODO Tell user to write something in the email field :D
}

- (BOOL)twitterIsRunning
{
    //TODO Detect twitter
    return NO;
}

- (void)patchTwitterPlist
{
    NSString *licenseCode = [self calculateLicense:[emailText stringValue]];
    NSString *licenseString = [NSString stringWithFormat:@"macheist%@", licenseCode];
    
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary *twitterPlist = [[defaults persistentDomainForName:@"com.twitter.twitter-mac"] mutableCopy];
    [twitterPlist removeObjectsForKeys:[NSArray arrayWithObjects:@"reg.email3", @"reg.license3", nil]];
    [twitterPlist setObject:[emailText stringValue] forKey:@"reg.email3"];
    [twitterPlist setObject:licenseString forKey:@"reg.license3"];
    
    [defaults setPersistentDomain:twitterPlist forName:@"com.twitter.twitter-mac"];
    [twitterPlist release];
    
    [patchButton setTitle:@"Done!"];
    [patchButton setEnabled:NO];
}

- (NSString *)calculateLicense:(NSString *)email
{
    NSString *preSHA1str = [[[[NSString stringWithFormat:@"%@macheist", email] lowercaseString] componentsSeparatedByCharactersInSet:[[NSCharacterSet letterCharacterSet] invertedSet]] componentsJoinedByString:@""];
    NSString *afterSHA1str = [[[self sha1:preSHA1str] componentsSeparatedByCharactersInSet:[[NSCharacterSet decimalDigitCharacterSet] invertedSet]] componentsJoinedByString:@""];
    NSString *licenseCode;
    if ([afterSHA1str length]==8) {
        licenseCode = afterSHA1str;
    }
    else {
        licenseCode = [afterSHA1str substringToIndex:8];
    }
    return licenseCode;
}

@end