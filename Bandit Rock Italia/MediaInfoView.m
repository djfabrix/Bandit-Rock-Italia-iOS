//
//  MediaInfoView.m
//  Bandit Rock Italia
//
//  Created by djfabrix on 5/1/13.
//  Copyright (c) 2013 Fabrizio Riccardo. All rights reserved.
//

#import "MediaInfoView.h"

@implementation MediaInfoView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor whiteColor];
        //self.frame = CGRectMake(0, 0, 100, 200);
        self.alpha = 0.8;
        
        UILabel *nowPlayingLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 5, self.frame.size.width-10, 20)];
        nowPlayingLabel.text = @"Now Playing:";
        nowPlayingLabel.textColor = [UIColor orangeColor];
        
        NSLog(@"font: %@", nowPlayingLabel.font.fontName);
        //[nowPlayingLabel setFont:[UIFont boldSystemFontOfSize:16]];
        nowPlayingLabel.backgroundColor = [UIColor yellowColor];
        [self addSubview:nowPlayingLabel];
        
        UILabel *trackTitle = [[UILabel alloc] initWithFrame:CGRectMake(5, 25, self.frame.size.width-10, 20)];
        trackTitle.textColor = [UIColor orangeColor];
        trackTitle.text = @"Halestorm - I Miss The Misery";
        [trackTitle setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:14.0]];
        
        [self addSubview:trackTitle];
    }
    
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
