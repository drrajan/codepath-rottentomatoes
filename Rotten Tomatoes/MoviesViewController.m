//
//  MoviesViewController.m
//  Rotten Tomatoes
//
//  Created by David Rajan on 2/3/15.
//  Copyright (c) 2015 David Rajan. All rights reserved.
//

#import "MoviesViewController.h"
#import "MovieDetailViewController.h"
#import "MovieCell.h"
#import "MovieCollectionCell.h"
#import "UIImageView+RottenTomatoes.h"
#import "SVProgressHUD.h"

@interface MoviesViewController () <UITableViewDelegate, UITableViewDataSource, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UISearchBarDelegate>

@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentControl;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) NSArray *movies;
@property (nonatomic, strong) NSArray *allMovies;
@property (nonatomic, strong) UIRefreshControl *tableRefreshControl;
@property (nonatomic, strong) UIRefreshControl *gridRefreshControl;
@property (nonatomic, strong) UIView *tableErrorView;
@property (nonatomic, strong) UIView *gridErrorView;
@property (nonatomic, strong) NSString *urlString;

@end

@implementation MoviesViewController

- (id)init
{
    return [self initWithDVD:NO];
}

- (id)initWithDVD:(BOOL)isDVD {
    
    self = [super init];
    if(self) {
        if (isDVD) {
            self.title = @"DVDs";
            self.urlString = @"http://api.rottentomatoes.com/api/public/v1.0/lists/dvds/top_rentals.json?apikey=ramgyfgebpvs7z8ce4favsvy";
            self.tabBarItem.image = [UIImage imageNamed:@"dvd.png"];
        } else {
            self.title = @"Movies";
            self.urlString = @"http://api.rottentomatoes.com/api/public/v1.0/lists/movies/box_office.json?apikey=ramgyfgebpvs7z8ce4favsvy";
            self.tabBarItem.image = [UIImage imageNamed:@"movies.png"];
        }
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.searchBar.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
    [self.tableView registerNib:[UINib nibWithNibName:@"MovieCell" bundle:nil] forCellReuseIdentifier:@"MovieCell"];
    
    self.tableView.rowHeight = 100;
    
    UICollectionViewFlowLayout* flowLayout = [[UICollectionViewFlowLayout alloc]init];
    flowLayout.itemSize = CGSizeMake(120, 180);
    flowLayout.ScrollDirection = UICollectionViewScrollDirectionVertical;
    flowLayout.minimumInteritemSpacing = 5;
    flowLayout.minimumLineSpacing = 5;
    CGRect collectionFrame = CGRectMake(30, 137, 260, self.tableView.frame.size.height);
    self.collectionView = [[UICollectionView alloc] initWithFrame:collectionFrame collectionViewLayout:flowLayout];
    [self.collectionView registerNib:[UINib nibWithNibName:@"MovieCollectionCell" bundle:nil] forCellWithReuseIdentifier:@"MovieCollectionCell"];
    self.collectionView.backgroundColor = self.view.backgroundColor;
    
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    
    self.tableRefreshControl = [[UIRefreshControl alloc] init];
    [self.tableRefreshControl addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:self.tableRefreshControl];
    self.gridRefreshControl = [[UIRefreshControl alloc] init];
    [self.gridRefreshControl addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventValueChanged];
    [self.collectionView addSubview:self.gridRefreshControl];
    
    [SVProgressHUD show];
    [self refresh:nil];
}

- (void)refresh:(id)sender {
    NSLog(@"Refreshing");
    
    if (self.tableErrorView) {
        self.tableView.tableHeaderView = nil;
        self.tableErrorView = nil;
        [self.gridErrorView removeFromSuperview];
        self.gridErrorView = nil;
    }
    
    NSURL *url = [NSURL URLWithString:self.urlString];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        if (!connectionError) {
            NSError *jsonError = nil;
            NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
            if (!jsonError) {
                self.movies = responseDictionary[@"movies"];
                self.allMovies = self.movies;
                [self.tableView reloadData];
                [self.collectionView reloadData];
            } else {
                NSLog(@"JSON parsing error!");
            }
        } else {
            NSLog(@"Network connection error!");
            [self showConnectionError];
        }
        [SVProgressHUD dismiss];
        if (sender) {
            [(UIRefreshControl *)sender endRefreshing];
        }
    }];
}

- (IBAction)segmentChanged:(id)sender {
    
    UIView *fromView, *toView;
    
    if (self.segmentControl.selectedSegmentIndex == 1)
    {
        fromView = self.tableView;
        toView = self.collectionView;
        NSLog(@"switching to grid");
    }
    else
    {
        fromView = self.collectionView;
        toView = self.tableView;
        NSLog(@"switching to table");
    }
    
    [UIView transitionFromView:fromView
                        toView:toView
                      duration:0.5
                       options:UIViewAnimationOptionTransitionFlipFromRight
                    completion:nil];
}

- (void)showConnectionError {
    CGRect tableErrorFrame = CGRectMake(0, 0, self.view.bounds.size.width, 30);
    self.tableErrorView = [[UIView alloc] initWithFrame:tableErrorFrame];
    [self.tableErrorView setBackgroundColor:[UIColor redColor]];
    
    CGRect gridErrorFrame = CGRectMake(0, 0, self.collectionView.frame.size.width, 30);
    self.gridErrorView = [[UIView alloc] initWithFrame:gridErrorFrame];
    [self.gridErrorView setBackgroundColor:[UIColor redColor]];
    
    UILabel *tableErrorLabel = [[UILabel alloc] initWithFrame:tableErrorFrame];
    [tableErrorLabel setTextColor:[UIColor blackColor]];
    tableErrorLabel.text = @"Network Connection Error!";
    [tableErrorLabel setTextAlignment:NSTextAlignmentCenter];
    [self.tableErrorView addSubview:tableErrorLabel];
    
    UILabel *gridErrorLabel = [[UILabel alloc] initWithFrame:gridErrorFrame];
    [gridErrorLabel setTextColor:[UIColor blackColor]];
    gridErrorLabel.text = @"Network Connection Error!";
    [gridErrorLabel setTextAlignment:NSTextAlignmentCenter];
    [self.gridErrorView addSubview:gridErrorLabel];
    
    
    [self.collectionView addSubview:self.gridErrorView];
    self.tableView.tableHeaderView = self.tableErrorView;

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - TableView methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.movies.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MovieCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MovieCell"];
    UIView *selectionColor = [[UIView alloc] init];
    selectionColor.backgroundColor = UIColorFromRGB(0x3A9425);
    cell.selectedBackgroundView = selectionColor;
    
    NSDictionary *movie = self.movies[indexPath.row];
    
    UIFont *boldFont = [UIFont boldSystemFontOfSize:12];
    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:
                              boldFont, NSFontAttributeName, nil];
    NSString *synString = [@" " stringByAppendingString:movie[@"synopsis"]];
    NSAttributedString *attributedString = [[NSAttributedString alloc] initWithString:synString];
    NSMutableAttributedString *synopsisText = [[NSMutableAttributedString alloc] initWithString:movie[@"mpaa_rating"] attributes:attributes];
    [synopsisText appendAttributedString:attributedString];
    
    cell.titleLabel.text = movie[@"title"];
    cell.synopsisLabel.attributedText = synopsisText;
    
    NSString *url = [movie valueForKeyPath:@"posters.thumbnail"];
    
    [cell.posterView setImageWithURLFade:[NSURL URLWithString:url]];

    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    MovieDetailViewController *vc = [[MovieDetailViewController alloc] init];
    
    id cell = [tableView cellForRowAtIndexPath:indexPath];
    UIImage *image = ((MovieCell *)cell).posterView.image;
    
    vc.thumbImage = image;
    vc.movie = self.movies[indexPath.row];
    
    self.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:vc animated:YES];
    self.hidesBottomBarWhenPushed = NO;
}

#pragma mark - CollectionView methods

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.movies.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    MovieCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"MovieCollectionCell" forIndexPath:indexPath];
    
    NSDictionary *movie = self.movies[indexPath.row];
    NSString *thumbURL = [movie valueForKeyPath:@"posters.profile"];
    
    NSString *posterURL = [thumbURL stringByReplacingOccurrencesOfString:@"tmb" withString:@"pro"];
    [cell.posterView setImageWithURLFade:[NSURL URLWithString:posterURL]];
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    
    MovieDetailViewController *vc = [[MovieDetailViewController alloc] init];
    
    vc.movie = self.movies[indexPath.row];
    
    self.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:vc animated:YES];
    self.hidesBottomBarWhenPushed = NO;
}

- (UIEdgeInsets)collectionView:(UICollectionView*)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(0, 0, 5, 0);
}


#pragma mark - SearchBar methods

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    [searchBar setShowsCancelButton:YES animated:YES];
    /*self.tableView.allowsSelection = NO;
    self.tableView.scrollEnabled = NO;
    self.collectionView.allowsSelection = NO;
    self.collectionView.scrollEnabled = NO;*/
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    
    if ([searchText isEqualToString:@""]) {
        self.movies = self.allMovies;
    } else {
        NSMutableArray *searchArray = [[NSMutableArray alloc] init];
        
        for (NSDictionary *movie in self.allMovies) {
            if ([movie[@"title"] containsString:searchText]) {
                [searchArray addObject:movie];
            }
        }
        
        self.movies = searchArray;
    }

    [self.tableView reloadData];
    [self.collectionView reloadData];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    [self searchEnded];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [self searchEnded];
}

- (void)searchEnded {
    [self.searchBar setShowsCancelButton:NO animated:YES];
    [self.searchBar resignFirstResponder];
    self.tableView.allowsSelection = YES;
    self.tableView.scrollEnabled = YES;
    self.collectionView.allowsSelection = YES;
    self.collectionView.scrollEnabled = YES;

}

#pragma mark - Helper methods

- (NSString *)styledHTMLwithHTML:(NSString *)HTML {
    NSString *style = @"<meta charset=\"UTF-8\"><style> body { font-family: 'HelveticaNeue'; font-size: 20px; } b {font-family: 'MarkerFelt-Wide'; }</style>";
    
    return [NSString stringWithFormat:@"%@%@", style, HTML];
}

- (NSAttributedString *)attributedStringWithHTML:(NSString *)HTML {
    NSDictionary *options = @{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType };
    return [[NSAttributedString alloc] initWithData:[HTML dataUsingEncoding:NSUTF8StringEncoding] options:options documentAttributes:NULL error:NULL];
}

@end
