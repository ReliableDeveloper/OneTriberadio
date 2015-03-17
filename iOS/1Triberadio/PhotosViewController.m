//
//  PhotosViewController.m
//  Triberadio
//
//  Created by YingZhi on 6/12/14.
//  Copyright (c) 2014 MobileDev. All rights reserved.
//

#import "PhotosViewController.h"
#import "PhotoCell.h"
#import "HttpAPI.h"
#import "Util.h"
#define selectedTag 100
#define cellSize 72
#define textLabelHeight 20
#define cellAAcitve 1.0
#define cellADeactive 0.3
#define cellAHidden 0.0
#define defaultFontSize 10.0

#define numOfimg 20
#define ROOT_URL @"http://1triberadio.com/wp-content/uploads/index.php?"
//#define ROOT_URL @"http://10.70.3.7/index.php?"

@interface PhotosViewController ()
{
    NSIndexPath *lastAccessed;
    NSMutableArray *photoList;
}
@end

@implementation PhotosViewController
@synthesize m_objImgListOper = _objImgListOper;
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
    _objImgListOper = [[RemoteImgListOperator alloc] init];
    [_objImgListOper resetListSize:20];
    selectedIdx = [[NSMutableDictionary alloc] init];
    [self.collectionView registerClass:[PhotoCell class] forCellWithReuseIdentifier:@"PhotoCell"];

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
    subTitle.text = @"Photos";
    subTitle.font = [UIFont fontWithName:@"Arial" size:12];
    [subTitle setTextAlignment:NSTextAlignmentCenter];
    [titleView addSubview:mainTitle];
    [titleView addSubview:subTitle];
    self.navigationItem.titleView = titleView;
    
    
    UIPanGestureRecognizer *gestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleGesture:)];
    [self.view addGestureRecognizer:gestureRecognizer];
    [gestureRecognizer setMinimumNumberOfTouches:1];
    [gestureRecognizer setMaximumNumberOfTouches:1];
    photoList = [[NSMutableArray alloc] init];
    [self getPhotoList];
    // Do any additional setup after loading the view from its nib.
}


- (void) getPhotoList {
    NSString *requestURL = [NSString stringWithFormat:@"%@%@=%@",ROOT_URL,@"method",@"imagelist"];
    [HttpAPI sendLoginRequest:NO url:requestURL completionBlock:^(BOOL success, NSData *resultData, NSError *err) {
        if (resultData != nil) {
            [Util showIndicator];
            NSDictionary* json = [NSJSONSerialization JSONObjectWithData:resultData options:NSJSONReadingMutableContainers error:nil];
            if (json != nil) {
                NSArray* songlist = [json objectForKey:@"imagelist"];
                if (songlist != nil) {
                    for (int i=0; i < [songlist count]; i++)
                    {
                        NSDictionary *item = [songlist objectAtIndex:i];
                        NSString *path = [item objectForKey:@"link"];
                        [photoList addObject:path];
                    }
                    
                }
            }
            [Util hideIndicator];
            [self.collectionView reloadData];
        }
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
//    return numOfimg * 2;
    return photoList?photoList.count:0;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    
    UICollectionReusableView *reusableview = nil;
    
    return reusableview;
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifier = @"PhotoCell";
    
    PhotoCell *cell = (PhotoCell *)[collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    
    if(cell == nil)
    {	
        NSArray *nib =
        [[NSBundle mainBundle] loadNibNamed:identifier owner:[PhotoCell class] options:nil];
        cell = (PhotoCell *)[nib objectAtIndex:0];
    }
//    [cell setFrame:CGRectMake(0, 0, 100, 100)];

//    [cell setRemoteImgOper:_objImgListOper];
//        cell.photoImage.image = [UIImage imageNamed:@"playcontrolbk.png"];
//    [cell showImgByURL:[photoList objectAtIndex:[indexPath item]]];
    cell.myImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, cell.bounds.size.width, cell.bounds.size.height)];
    cell.myImage.contentMode = UIViewContentModeScaleAspectFill;
    cell.myImage.image = [UIImage imageNamed:@"playcontrolbk.png"];;
    [cell addSubview:cell.myImage];
    [cell setRemoteImgOper:_objImgListOper];
    [cell showImgByURL:[photoList objectAtIndex:[indexPath item]]];
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(cellSize, cellSize);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
    [self setCellSelection:cell selected:YES];
    
    [selectedIdx setValue:@"1" forKey:[NSString stringWithFormat:@"%ld", (long)indexPath.row]];
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
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
