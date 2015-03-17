//
//  MusicAlbumViewController.m
//  Triberadio
//
//  Created by YingZhi on 6/15/14.
//  Copyright (c) 2014 MobileDev. All rights reserved.
//

#import "MusicAlbumViewController.h"
#import "MusicAlbumCell.h"
#import "HttpApi.h"
#import "Util.h"
#define selectedTag 100
#define cellWidth 130
#define cellHeight 180
#define textLabelHeight 20
#define cellAAcitve 1.0
#define cellADeactive 0.3
#define cellAHidden 0.0
#define defaultFontSize 12.0
#define numOfimg 20
@interface MusicAlbumViewController (){
    NSIndexPath *lastAccessed;
}

@end

@implementation MusicAlbumViewController
{
}

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
    // Do any additional setup after loading the view from its nib.
    [self.collectionView registerClass:[MusicAlbumCell class] forCellWithReuseIdentifier:@"MusicAlbumCell"];
      selectedIdx = [[NSMutableDictionary alloc] init];
    [self.collectionView setAllowsMultipleSelection:FALSE];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"listing_header"] forBarMetrics:UIBarMetricsDefault];

    UIBarButtonItem *btnSearch = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"searchbutton"] style:UIBarButtonItemStylePlain target:self action:@selector(gotoSearch)];
    self.navigationItem.rightBarButtonItem = btnSearch;
    UIBarButtonItem *btnMenu = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"threelinebutton"] style:UIBarButtonItemStylePlain target:self action:@selector(gotoMenu)];
    self.navigationItem.leftBarButtonItem = btnMenu;
    UIView *titleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 200, 45)];
    UIImageView *mainTitle = [[UIImageView alloc] initWithFrame:CGRectMake(40, -15, 150, 40)];
    UILabel *subTitle = [[UILabel alloc] initWithFrame:CGRectMake(7, 20, 200, 21)];
    mainTitle.image = [UIImage imageNamed:@"triberadiomark"];
    subTitle.textColor = [UIColor whiteColor];
    subTitle.text = @"Videos";
    subTitle.font = [UIFont fontWithName:@"Arial" size:12];
    [subTitle setTextAlignment:NSTextAlignmentCenter];
    [titleView addSubview:mainTitle];
    [titleView addSubview:subTitle];
    self.navigationItem.titleView = titleView;
    UIPanGestureRecognizer *gestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleGesture:)];
    [self.view addGestureRecognizer:gestureRecognizer];
    [gestureRecognizer setMinimumNumberOfTouches:1];
    [gestureRecognizer setMaximumNumberOfTouches:1];
    [self.collectionView setBackgroundView: [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"mainbk_portrait"]]];
    [self.collectionView setContentInset:UIEdgeInsetsMake(10, 10, 10, 10)];
    [self initYoutubeVideoList];
}

- (void) initYoutubeVideoList {
    NSString *requestURL = @"http://youtu.be/VL2wgKQWjno";
    [HttpAPI sendLoginRequest:NO url:requestURL completionBlock:^(BOOL success, NSData *resultData, NSError *err) {
            [Util showIndicator];
            [Util hideIndicator];
    }];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return numOfimg * 2;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    
    UICollectionReusableView *reusableview = nil;
    
    return reusableview;
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{

    MusicAlbumCell *cell = (MusicAlbumCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"MusicAlbumCell" forIndexPath:indexPath];
    if(cell == nil)
    {
        NSArray *nib =
        [[NSBundle mainBundle] loadNibNamed:@"MusicAlbumCell" owner:[MusicAlbumCell class] options:nil];
        cell = (MusicAlbumCell *)[nib objectAtIndex:0];
    }

    UIImageView *imgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:[NSString stringWithFormat:@"%d.png", [indexPath row] % numOfimg]]];
    imgView.frame = CGRectMake(0, 0, cellWidth, cellWidth);
    [cell addSubview:imgView];
    
    UILabel *albumLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, cellWidth+5, cellWidth, defaultFontSize)];
    albumLabel.text = @"Random Album";
    albumLabel.textColor = [UIColor whiteColor];
    [albumLabel  setFont:[UIFont fontWithName:@"Arial" size:defaultFontSize]];
    [cell addSubview:albumLabel];
    UILabel *singerLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, cellWidth+5+defaultFontSize, cellWidth, 20)];
    singerLabel.text = @"Singer";
    singerLabel.textColor = [UIColor whiteColor];
    [singerLabel  setFont:[UIFont fontWithName:@"Arial" size:defaultFontSize-2]];
    [cell addSubview:singerLabel];
    
    UIButton *playPauseButton = [[UIButton alloc] initWithFrame:CGRectMake(cellWidth/2-25, cellWidth/2-25, 50, 50)];
    [playPauseButton setImage:[UIImage imageNamed:@"playbutton.png"] forState:UIControlStateNormal];
    [cell addSubview:playPauseButton];
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(cellWidth, cellHeight);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = (UICollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
    [self setCellSelection:cell selected:YES];
    
    [selectedIdx setValue:@"1" forKey:[NSString stringWithFormat:@"%ld", (long)indexPath.row]];
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = (UICollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
    [self setCellSelection:cell selected:NO];
    
    [selectedIdx removeObjectForKey:[NSString stringWithFormat:@"%ld", (long)indexPath.row]];
}

- (void) setCellSelection:(UICollectionViewCell *)cell selected:(bool)selected
{
    //    cell.backgroundView.alpha = selected ? cellAAcitve : cellADeactive;
    cell.backgroundView.alpha = cellAAcitve;
    [cell viewWithTag:selectedTag].alpha = selected ? cellAAcitve : cellAHidden;
}

- (void) resetSelectedCells
{
    for (UICollectionViewCell *cell in self.collectionView.visibleCells) {
        [self deselectCellForCollectionView:self.collectionView atIndexPath:[self.collectionView indexPathForCell:cell]];
    }
}

- (void) gotoMenu
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void) gotoSearch
{
    
}

- (void) handleGesture:(UIPanGestureRecognizer *)gestureRecognizer
{
    float pointerX = [gestureRecognizer locationInView:self.collectionView].x;
    float pointerY = [gestureRecognizer locationInView:self.collectionView].y;
    
    for (UICollectionViewCell *cell in self.collectionView.visibleCells) {
        float cellSX = cell.frame.origin.x;
        float cellEX = cell.frame.origin.x + cell.frame.size.width;
        float cellSY = cell.frame.origin.y;
        float cellEY = cell.frame.origin.y + cell.frame.size.height;
        
        if (pointerX >= cellSX && pointerX <= cellEX && pointerY >= cellSY && pointerY <= cellEY)
        {
            NSIndexPath *touchOver = [self.collectionView indexPathForCell:cell];
            
            if (lastAccessed != touchOver)
            {
                if (cell.selected)
                    [self deselectCellForCollectionView:self.collectionView atIndexPath:touchOver];
                else
                    [self selectCellForCollectionView:self.collectionView atIndexPath:touchOver];
            }
            
            lastAccessed = touchOver;
        }
    }
    
    if (gestureRecognizer.state == UIGestureRecognizerStateEnded)
    {
        lastAccessed = nil;
        self.collectionView.scrollEnabled = YES;
    }
    
    
}

- (void) selectCellForCollectionView:(UICollectionView *)collection atIndexPath:(NSIndexPath *)indexPath
{
    [collection selectItemAtIndexPath:indexPath animated:YES scrollPosition:UICollectionViewScrollPositionNone];
    [self collectionView:collection didSelectItemAtIndexPath:indexPath];
}

- (void) deselectCellForCollectionView:(UICollectionView *)collection atIndexPath:(NSIndexPath *)indexPath
{
    [collection deselectItemAtIndexPath:indexPath animated:YES];
    [self collectionView:collection didDeselectItemAtIndexPath:indexPath];
}

@end
