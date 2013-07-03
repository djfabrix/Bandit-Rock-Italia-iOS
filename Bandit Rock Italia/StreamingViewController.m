//
//  StreamingViewController.m
//  Bandit Rock Italia
//
//  Created by djfabrix on 5/1/13.
//  Copyright (c) 2013 Fabrizio Riccardo. All rights reserved.
//

#import "StreamingViewController.h"
#import "Constants.h"
#import "MediaInfoView.h"


@interface StreamingViewController ()

@property (nonatomic, weak) IBOutlet UIImageView *topImageView;
@property (nonatomic, weak) IBOutlet UIImageView *bottomImageView;
@property (nonatomic, strong) MediaInfoView *mediaView;

@end

@implementation StreamingViewController
{
    BOOL isPlaying;
    Class playingInfoCenter;
}

@synthesize player, songTitle, loadStateLabel, loadStateView, playStopButton, artworkImageView;
@synthesize storeViewController, productId, itunesButton;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated {
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    [self becomeFirstResponder];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    itunesButton.hidden = YES;
    
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    NSError *setCategoryError = nil;
    BOOL success = [audioSession setCategory:AVAudioSessionCategoryPlayback error:&setCategoryError];
    if (!success) {
        NSLog(@"DOH Could not set Category!");
    }
    
    NSError *activationError = nil;
    success = [audioSession setActive:YES error:&activationError];
    if (!success) {
        NSLog(@"DOH Could not set Active!");
    }
    
    playingInfoCenter = NSClassFromString(@"MPNowPlayingInfoCenter");
    
    isPlaying = NO;
    
    // cancello il titolo della canzone
    self.songTitle.text = @"";
    loadStateLabel.text = @"";
    loadStateView.hidden = YES;
    
   // [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    
    player = [[MPMoviePlayerController alloc] initWithContentURL:[NSURL URLWithString:banditItaliaUrlString]];
    
    player.movieSourceType = MPMovieSourceTypeStreaming;
    
    player.shouldAutoplay = NO;
    
    // notifiche per i metadati
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(metadataUpdate:)
                                                 name:MPMoviePlayerTimedMetadataUpdatedNotification
                                               object:nil];
    
    // notifiche per lo stato della riproduzione (play, buffering, ..)
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(loadStateChange:)
                                                 name:MPMoviePlayerLoadStateDidChangeNotification
                                               object:nil];
    
    // notifiche per la fine dello stream (error, stop)
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(playbackDidFinish:)
                                                 name:MPMoviePlayerPlaybackDidFinishNotification
                                               object:nil];
    
    if (self.storeViewController == nil) {
        self.storeViewController = [[SKStoreProductViewController alloc] init];
        storeViewController.delegate = self;
    }
    
    
    CGRect mediaViewFrame = CGRectMake(0, -50, self.view.frame.size.width, 50);
    
    _mediaView = [[MediaInfoView alloc] initWithFrame:mediaViewFrame];
    
    [self.view addSubview:_mediaView];
}

- (void)viewDidAppear:(BOOL)animated {
    // ANIMATION TEST
    CGRect topImageViewFrame = self.topImageView.frame;
    topImageViewFrame.origin.y = -topImageViewFrame.size.height;
    
    CGRect bottomImageViewFrame = self.bottomImageView.frame;
    bottomImageViewFrame.origin.y = self.view.frame.size.height;
    
    [UIView beginAnimations:nil context:nil];
    // durata dell'animazione
    [UIView setAnimationDuration:0.7];
    // l'animazione parte 2 secondi in ritardo
    [UIView setAnimationDelay:2.0];
    
    // the animation curve is set to ease out (so the animation goes a little bit slower at the end).
    [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
    
    self.topImageView.frame = topImageViewFrame;
    self.bottomImageView.frame = bottomImageViewFrame;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)loadStateChange:(NSNotification*)notification
{
    //NSLog(@"loadStateChange notification: %ld", (long)[player loadState]);
    MPMovieLoadState loadState = player.loadState;
    /* The load state is not known at this time. */
    if (loadState & MPMovieLoadStateUnknown)
    {
        NSLog(@"MPMovieLoadStateUnknown");
    }
    
    /* The buffer has enough data that playback can begin, but it
     may run out of data before playback finishes. */
    if (loadState & MPMovieLoadStatePlayable)
    {
        //loadStateLabel.text = @"Playing ..";
        songTitle.hidden = NO;
        loadStateView.hidden = YES;
    }
    
    /* The buffering of data has stalled. */
    if (loadState & MPMovieLoadStateStalled)
    {
        loadStateView.hidden = NO;
        loadStateLabel.text = @"Buffering ..";
    }
    
    
}

- (void)metadataUpdate:(NSNotification*)notification
{
    //NSLog(@"metadataUpdate notification: %@", [notification userInfo]);
    
    if ([player timedMetadata]!=nil && [[player timedMetadata] count] > 0) {
        
        [self displayMetaData:[player timedMetadata]];
        
    }
}

- (void)playbackDidFinish:(NSNotification*)notification {
    //NSLog(@"playbackDidFinish notification: %@", [notification userInfo]);
    itunesButton.hidden = YES;
    
    NSError *mediaPlayerError = [[notification userInfo] objectForKey:@"error"];
    
    [playStopButton setImage:[UIImage imageNamed:@"play.png"] forState:UIControlStateNormal];
    
    if (mediaPlayerError) {
        NSLog(@"Impossibile connettersi.. redirecting to bandit sweden: %@", banditUrlString);
        [player stop];
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Bandit Rock Italia"
                                                message:@"Le trasmissioni di Bandit Rock Italia non sono al momento disponibili. Vuoi collegarti Bandit Rock Official?"
                                               delegate:self
                                      cancelButtonTitle:@"No grazie"
                                      otherButtonTitles:@"Ok!",nil];
        
        [alert show];
        
    }
    else {
        if (isPlaying) {
            [self performSelector:@selector(proposeNewStream:) withObject:nil afterDelay:10.0];
        }
    }
    
    isPlaying = NO;
}

- (void)proposeNewStream:(id) sender {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Bandit Rock Italia"
                                                    message:@"Le trasmissioni di Bandit Rock Italia non sono al momento disponibili. Vuoi collegarti Bandit Rock Official?"
                                                   delegate:self
                                          cancelButtonTitle:@"No grazie"
                                          otherButtonTitles:@"Ok!",nil];
    
    [alert show];
}

- (IBAction)play:(id)sender;
{
    if (!isPlaying) {
        
        // risetto l'url di defaul a bandit italia.
        //[player setContentURL:[NSURL URLWithString:banditItaliaUrlString]];
        [player setContentURL:[NSURL URLWithString:banditUrlString]];
        
        [playStopButton setImage:[UIImage imageNamed:@"pause.png"] forState:UIControlStateNormal];
        
        isPlaying = YES;
        loadStateLabel.text = @"Connecting ..";
        loadStateView.hidden = NO;
        [player prepareToPlay];
        [player play];
        
    }
    else {
        [playStopButton setImage:[UIImage imageNamed:@"play.png"] forState:UIControlStateNormal];
        
        isPlaying = NO;
        [self cancelInfoViews];
        [player stop];
    }
    
}


- (void) cancelInfoViews {
    loadStateLabel.text = @"";
    loadStateView.hidden = YES;
    songTitle.hidden = YES;
    itunesButton.hidden = YES;
}

- (void) displayMetaData:(NSArray*) timedMetadata {
    
    //NSLog(@"xx: %d", [[player timedMetadata] count]);
    itunesButton.hidden = YES;
    artworkImageView.image = nil;
    self.productId = nil;
    
    MPTimedMetadata *firstMeta = [[player timedMetadata] objectAtIndex:0];
    //NSLog(@"firstMeta: %@",firstMeta);
    //metadataInfo = firstMeta.value;
    //NSLog (@"Meta Property with value: %@ and key: %@ and keyspace: %@ and timestamp: %f", firstMeta.value, firstMeta.key, firstMeta.keyspace, firstMeta.timestamp);
    
    self.songTitle.text = firstMeta.value;
    

    if (_mediaView.frame.origin.y != 0) {
        CGRect mediaViewFrame = _mediaView.frame;
        mediaViewFrame.origin.y = 0;
        
        
        [UIView animateWithDuration:0.3
                              delay:0.5
                            options: UIViewAnimationCurveEaseOut
                         animations:^{
                             _mediaView.frame = mediaViewFrame;
                             //basketTop.frame = basketTopFrame;
                             //basketBottom.frame = basketBottomFrame;
                         }
                         completion:^(BOOL finished) {
                             NSLog(@"Finished.");
                         }];
    }
    
    
    NSLog(@"playingInfoCenter: %@", playingInfoCenter);
    
    if (playingInfoCenter) {
        NSMutableDictionary *songInfo = [[NSMutableDictionary alloc] init];
        [songInfo setObject:firstMeta.value forKey:MPMediaItemPropertyTitle];
        
        UIImage *copertina = [UIImage imageNamed:@"volbeat.jpg"];
        NSLog(@"copertina: %@", copertina);
        MPMediaItemArtwork *albumArt = [[MPMediaItemArtwork alloc] initWithImage:copertina];
        NSLog(@"albumArt: %@", albumArt);
        
        //[songInfo setObject:albumArt forKey:MPMediaItemPropertyArtwork];
        
        
        [[MPNowPlayingInfoCenter defaultCenter] setNowPlayingInfo:songInfo];
        
        
        // info da itunes
        NSString *urlString = [NSString stringWithFormat:@"https://itunes.apple.com/search?term=%@", firstMeta.value];
        
        urlString = [urlString stringByReplacingOccurrencesOfString:@"-" withString:@"+"];
        urlString = [urlString stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
        NSLog(@"urlString: %@", urlString);
        
        NSURL *url = [NSURL URLWithString:urlString];
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        [NSURLConnection sendAsynchronousRequest:request
                                           queue:[NSOperationQueue mainQueue]
                               completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                                   if (!error) {
                                       NSError* parseError;
                                       id parse = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&parseError];
                                       
                                       
                                       if (!parseError && parse) {
                                           
                                           // numero di risultati
                                           NSInteger numRes = [[parse valueForKey:@"resultCount"] integerValue];
                                           NSLog(@"count: %d", numRes);
                                           NSArray *resArray = [parse valueForKey:@"results"];
                                           
                                           if (numRes > 0) {
                                               
                                               for (NSDictionary *res in resArray) {
                                                   //NSLog(@"kind: %@", [res objectForKey:@"kind"]);
                                                   
                                                   if ([[res objectForKey:@"kind"] isEqualToString:@"song"]) {
                                                       
                                                       NSLog(@"art: %@", [res objectForKey:@"artworkUrl100"]);
                                                       
                                                       UIImage *artImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[res objectForKey:@"artworkUrl100"]]]];
                                                       
                                                       artworkImageView.frame = CGRectMake(artworkImageView.frame.origin.x, artworkImageView.frame.origin.y, artImage.size.width, artImage.size.height);
                                                       
                                                       artworkImageView.image = artImage;
                                                       
                                                       self.productId = [res objectForKey:@"trackId"];
                                                       itunesButton.hidden = NO;
                                                       
                                                       break;
                                                   }
                                               }
                                           }
                                       }
                                   }
                               }];
    }

}

- (IBAction)goToITunes:(id)sender {
    if (self.productId != nil) {
        [storeViewController loadProductWithParameters:@{SKStoreProductParameterITunesItemIdentifier : self.productId} completionBlock:^(BOOL result, NSError *error) {
            if (error) {
                NSLog(@"Error %@ with User Info %@.", error, [error userInfo]);
            } else {
                // Present Store Product View Controller
                [self presentViewController:storeViewController animated:YES completion:nil];
            }
        }];
    }
    
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        [self cancelInfoViews];
    }
    else if (buttonIndex == 1) {
        isPlaying = YES;
        [player setContentURL:[NSURL URLWithString:banditUrlString]];
        [player prepareToPlay];
        [player play];
        [playStopButton setImage:[UIImage imageNamed:@"pause.png"] forState:UIControlStateNormal];
    }
}


- (void)productViewControllerDidFinish:(SKStoreProductViewController *)viewController {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (BOOL)canBecomeFirstResponder{
    return YES;
}

- (void)viewDidUnload {
    [self setArtworkImageView:nil];
    [self setItunesButton:nil];
    [super viewDidUnload];
}
@end
