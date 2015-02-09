//
//  MoviesViewController.h
//  Rotten Tomatoes
//
//  Created by David Rajan on 2/3/15.
//  Copyright (c) 2015 David Rajan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MoviesViewController : UIViewController

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

- (id)initWithDVD:(BOOL)isDVD;

@end
