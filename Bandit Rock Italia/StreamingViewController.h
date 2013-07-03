//
//  StreamingViewController.h
//  Bandit Rock Italia
//
//  Created by djfabrix on 5/1/13.
//  Copyright (c) 2013 Fabrizio Riccardo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>
#import <StoreKit/StoreKit.h>

@interface StreamingViewController : UIViewController <SKStoreProductViewControllerDelegate>

@property (strong, nonatomic) IBOutlet UILabel *songTitle;
@property (strong, nonatomic) IBOutlet UIView *loadStateView;
@property (strong, nonatomic) IBOutlet UILabel *loadStateLabel;

@property (nonatomic, strong) MPMoviePlayerController *player;
@property (strong, nonatomic) IBOutlet UIButton *playStopButton;

@property (strong, nonatomic) IBOutlet UIImageView *artworkImageView;

@property (strong, nonatomic) SKStoreProductViewController *storeViewController;
@property (strong, nonatomic) NSString* productId;
@property (strong, nonatomic) IBOutlet UIButton *itunesButton;

- (IBAction)play:(id)sender;
- (IBAction)goToITunes:(id)sender;

- (void)proposeNewStream:(id) sender;

@end
