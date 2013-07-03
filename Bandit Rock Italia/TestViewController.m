//
//  TestViewController.m
//  Bandit Rock Italia
//
//  Created by djfabrix on 5/1/13.
//  Copyright (c) 2013 Fabrizio Riccardo. All rights reserved.
//

#import "TestViewController.h"

@interface TestViewController ()

@end

@implementation TestViewController
@synthesize artworkImageView, collectionNameLabel;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    collectionNameLabel.text = @"";
    artworkImageView.image = nil;
    
	// Do any additional setup after loading the view.
    NSString *urlString = @"https://itunes.apple.com/search?term=volbeat+thanks";
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
                                           NSDictionary *res1 = [resArray objectAtIndex:0];
                                           NSLog(@"artistViewUrl: %@", [res1 objectForKey:@"artistViewUrl"]);
                                           
                                           NSString *artworkUrlString = [res1 objectForKey:@"artworkUrl100"];
                                           NSString *albumName = [res1 objectForKey:@"collectionName"];
                                           
                                           UIImage *artImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:artworkUrlString]]];
                                           
                                           artworkImageView.frame = CGRectMake(artworkImageView.frame.origin.x, artworkImageView.frame.origin.y, artImage.size.width, artImage.size.height);
                                           
                                           collectionNameLabel.text = albumName;
                                           artworkImageView.image = artImage;
                                           
                                       }
                                       // per ora considero solo il primo elemento
                                      
                                       
                                   }
                                   
                               }
                           }];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setCollectionNameLabel:nil];
    [self setArtworkImageView:nil];
    [super viewDidUnload];
}
@end
