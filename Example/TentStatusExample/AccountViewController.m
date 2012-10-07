//
//  AccountViewController.m
//  TentStatusExample
//
//  Copyright (c) 2012 Ben Stovold http://thoughtfulpixel.com
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

#import "AccountViewController.h"
#import "TentStatusClient.h"
#import "NSURL+TPEquivalence.h"
#import "UICKeyChainStore.h"
#import "Profile.h"

@interface AccountViewController () <UITextFieldDelegate>

@property (nonatomic, strong) IBOutlet UITextField *entityURIField;
@property (nonatomic, strong) NSURL *entityURL;
@property (nonatomic, strong) NSURL *tentServerURL;

@property (nonatomic, strong) IBOutlet UITableViewCell *profileCell;
@property (nonatomic, strong) IBOutlet UIImageView *profileImageView;
@property (nonatomic, strong) IBOutlet UILabel *profileName;
@property (nonatomic, strong) IBOutlet UILabel *profileBio;

@end

@implementation AccountViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    // comment this in for resetting the keychain values
//    [UICKeyChainStore removeItemForKey:BASE_URL];
//    [UICKeyChainStore removeItemForKey:ACCESS_TOKEN];
//    [UICKeyChainStore removeItemForKey:MAC_KEY];
//    [UICKeyChainStore removeItemForKey:MAC_KEY_ID];
//    [UICKeyChainStore removeItemForKey:MAC_ALGORITHM];
//    [UICKeyChainStore removeItemForKey:CLIENT_ID];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didAuthorizeWithEntity:)
                                                 name:TPTentClientDidAuthorizeWithTentServerNotification
                                               object:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    if ([UICKeyChainStore stringForKey:ENTITY] && [UICKeyChainStore stringForKey:BASE_URL]) {
        self.entityURIField.text = [UICKeyChainStore stringForKey:ENTITY];
        self.entityURL = [NSURL URLWithString:self.entityURIField.text];
        self.tentServerURL = [NSURL URLWithString:[UICKeyChainStore stringForKey:BASE_URL]];
    }
    
    if (self.entityURIField.text.length == 0) {
        self.entityURIField.text = @"https://";
    }
    
    [self.entityURIField becomeFirstResponder];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    NSURL *entityURL = [NSURL URLWithString:textField.text];
    if (!entityURL) {
        return NO;
    }
    
    [textField resignFirstResponder];

    if ([self.entityURL isEquivalent:entityURL] &&
        [[TentStatusClient sharedClient] isAuthorizedForTentServer:self.tentServerURL]) {
        [self loadProfile];
        return YES;
    }
    
    self.entityURL = entityURL;

    [self doAuthorize];

    return YES;
}

- (void)doAuthorize
{
    [[TentStatusClient sharedClient] discoverTentServerForEntityURL:self.entityURL success:^(NSURL *canonicalServerURL, NSURL *canonicalEntityURL) {
        [UICKeyChainStore setString:self.entityURIField.text forKey:ENTITY];
        self.entityURL = canonicalEntityURL;
        if ([self.tentServerURL isEquivalent:canonicalServerURL] &&
            [[TentStatusClient sharedClient] isAuthorizedForTentServer:self.tentServerURL]) {
            [self loadProfile];
        } else {
            self.tentServerURL = canonicalServerURL;
                [[TentStatusClient sharedClient] authorizeForTentServerURL:self.tentServerURL];
            }
        } failure:nil];
}

- (void)didAuthorizeWithEntity:(NSDictionary *)notification
{
    [self loadProfile];
}

- (void)populateProfile:(Profile*)profile {
    self.profileName.text = profile.name;
    self.profileBio.text = profile.bio;
    self.profileImageView.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:profile.avatar_url]]];
    self.profileCell.hidden = NO;
}

- (IBAction)showTimeline
{
    [self performSegueWithIdentifier:@"ShowTimeline" sender:self];
}

- (void)loadProfile {
    [[TentStatusClient sharedClient] getProfileRepresentationWithEntity:@"https://dlinsin.tent.is" success:^(NSDictionary *profileRepresentations) {
        [self populateProfile:[[Profile alloc] initWithDictionary:profileRepresentations]];
    } failure:^(NSError *error) {
        NSLog(@"erro:%@", error);
    }];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
