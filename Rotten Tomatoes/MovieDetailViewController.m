//
//  MovieDetailViewController.m
//  Rotten Tomatoes
//
//  Created by David Rajan on 2/3/15.
//  Copyright (c) 2015 David Rajan. All rights reserved.
//

#import "MovieDetailViewController.h"
#import "UIImageView+AFNetworking.h"

@interface MovieDetailViewController ()

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIImageView *posterView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *synopsisLabel;
@property (assign, nonatomic) BOOL scrollExpanded;
@property (strong, nonatomic) IBOutlet UITapGestureRecognizer *gestureRecognizer;

@end

@implementation MovieDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = self.movie[@"title"];
    self.titleLabel.text = self.movie[@"title"];
    
    NSString *synopsisString = [NSString stringWithFormat:@"Year: %@\nMPAA: %@\nCritics: %@%% %@\nAudience: %@%% %@\nRuntime: %@ minutes\n\n", self.movie[@"year"], self.movie[@"mpaa_rating"], [self.movie valueForKeyPath:@"ratings.critics_score"], [self.movie valueForKeyPath:@"ratings.critics_rating"], [self.movie valueForKeyPath:@"ratings.audience_score"], [self.movie valueForKeyPath:@"ratings.audience_rating"], self.movie[@"runtime"]];
    
    
    self.synopsisLabel.text = [synopsisString stringByAppendingString:self.movie[@"synopsis"]];
    [self.synopsisLabel sizeToFit];
    self.scrollView.contentSize = CGSizeMake(self.view.frame.size.width, self.synopsisLabel.frame.size.height + 60);
    
    NSString *thumbURL = [self.movie valueForKeyPath:@"posters.thumbnail"];
    NSString *posterURL = [thumbURL stringByReplacingOccurrencesOfString:@"tmb" withString:@"ori"];
    
    [self.posterView setImageWithURL:[NSURL URLWithString:posterURL] placeholderImage:self.thumbImage];
  
    self.scrollExpanded = NO;

}
- (IBAction)onTap:(id)sender {
    CGRect frame1 = CGRectMake(0, 60, self.view.bounds.size.width, self.view.bounds.size.height - 60);
    CGRect frame2 = CGRectMake(0, 365, 320, 203);
    CGRect startFrame = frame2;
    CGRect endFrame = frame1;
    
    if (self.scrollExpanded) {
        startFrame = frame1;
        endFrame = frame2;
    }
    
    void (^animationBlock)() = ^{
        [UIView addKeyframeWithRelativeStartTime:0
                                relativeDuration:0.5
                                      animations:^{
                                          self.scrollView.frame = startFrame;
                                      }];
        [UIView addKeyframeWithRelativeStartTime:0.5
                                relativeDuration:0.5
                                      animations:^{
                                          self.scrollView.frame = endFrame;
                                      }];
        
    };
    
    [UIView animateKeyframesWithDuration:0.5
                                   delay:0.0
                                 options:UIViewKeyframeAnimationOptionCalculationModeLinear |
     UIViewAnimationOptionCurveLinear
                              animations:animationBlock
                              completion:^(BOOL finished) {
                              }];
    
    
    self.scrollExpanded = !self.scrollExpanded;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
