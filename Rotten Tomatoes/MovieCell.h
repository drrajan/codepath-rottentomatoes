//
//  MovieCell.h
//  Rotten Tomatoes
//
//  Created by David Rajan on 2/3/15.
//  Copyright (c) 2015 David Rajan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MovieCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *synopsisLabel;
@property (weak, nonatomic) IBOutlet UIImageView *posterView;

@end
