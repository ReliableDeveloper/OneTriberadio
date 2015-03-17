//
// Copyright (c) 2013 Related Code - http://relatedcode.com
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "common.h"
#import "structures.h"

#import "AFNetworking.h"
#import "ProgressHUD.h"

#import "SelectVideo1.h"
#import "Util.h"
//-------------------------------------------------------------------------------------------------------------------------------------------------
@interface SelectVideo1()
{
	NSString *selected;
	
	NSInteger start;
	NSString *orderby;
}
@end
//-------------------------------------------------------------------------------------------------------------------------------------------------

@implementation SelectVideo1

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (id)initWith:(NSString *)Selected
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	self = [super init];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	selected = [NSString stringWithString:Selected];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	return self;
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)viewDidLoad
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
    [super viewDidLoad];
	//---------------------------------------------------------------------------------------------------------------------------------------------
//	self.title = selected;
    
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"listing_header"] forBarMetrics:UIBarMetricsDefault];
    
//    UIBarButtonItem *btnSearch = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"searchbutton"] style:UIBarButtonItemStylePlain target:self action:@selector(gotoSearch)];
//    self.navigationItem.rightBarButtonItem = btnSearch;
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

	//---------------------------------------------------------------------------------------------------------------------------------------------
   self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Sort" style:UIBarButtonItemStyleBordered
																			 target:self action:@selector(sortButtonPress:)];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	start = 1;
	orderby = @"relevance";
	//---------------------------------------------------------------------------------------------------------------------------------------------
	[NSThread detachNewThreadSelector:@selector(loadVideo:) toTarget:self withObject:nil];
}

- (void) gotoMenu {
    [self.parentViewController dismissViewControllerAnimated:YES completion:nil];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)sortButtonPress:(id)sender
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Search Options: Sort by" delegate:self cancelButtonTitle:@"Cancel"
								destructiveButtonTitle:nil otherButtonTitles:@"Relevance", @"Upload Date", @"View Count", @"Rating", nil];
	[actionSheet showInView:self.view];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	NSString *buttonTitle = [actionSheet buttonTitleAtIndex:buttonIndex];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	if ([buttonTitle isEqualToString:@"Relevance"])		orderby = @"relevance";
	if ([buttonTitle isEqualToString:@"Upload Date"])	orderby = @"published";
	if ([buttonTitle isEqualToString:@"View Count"])	orderby = @"viewCount";
	if ([buttonTitle isEqualToString:@"Rating"])		orderby = @"rating";
	//---------------------------------------------------------------------------------------------------------------------------------------------
	if ([buttonTitle isEqualToString:@"Cancel"] == FALSE)
	{
		start = 1; [self.items removeAllObjects]; [self.tableView reloadData];
		//-----------------------------------------------------------------------------------------------------------------------------------------
		[NSThread detachNewThreadSelector:@selector(loadVideo:) toTarget:self withObject:nil];
	}
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	if (indexPath.row == [self.items count]-1) [NSThread detachNewThreadSelector:@selector(loadVideo:) toTarget:self withObject:nil];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)loadVideo:(id)sender
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
    [Util showIndicator];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	NSString *tmp = [selected stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	NSString *link = [NSString stringWithFormat:@"http://gdata.youtube.com/feeds/api/videos?alt=json&v=2&key=%@&format=1", YOUTUBE_KEY];
	link = [link stringByAppendingFormat:@"&safeSearch=none&q=%@&start-index=%ld&max-results=50&orderby=%@", tmp, (long) start, orderby];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:link]];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
	operation.responseSerializer = [AFJSONResponseSerializer serializer];
	[operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject)
											{ [self didComplete:responseObject]; start += 50; }
									 failure:^(AFHTTPRequestOperation *operation, NSError *error)
     { [Util hideIndicator]; }];
	[[NSOperationQueue mainQueue] addOperation:operation];
	//---------------------------------------------------------------------------------------------------------------------------------------------
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)didComplete:(NSDictionary *)response
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	NSInteger count = [[response valueForKeyPath:@"feed.entry"] count];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	if (count == 0) { [ProgressHUD showError:@"No video found."]; return; }
	//---------------------------------------------------------------------------------------------------------------------------------------------

	//---------------------------------------------------------------------------------------------------------------------------------------------
	for (NSInteger i=0; i<count; i++)
	{
		NSDictionary *entry = [[response valueForKeyPath:@"feed.entry"] objectAtIndex:i];
		//-----------------------------------------------------------------------------------------------------------------------------------------
		NSString *videoid	= [entry valueForKeyPath:@"media$group.yt$videoid.$t"];
		NSString *thumb		= [[[entry valueForKeyPath:@"media$group.media$thumbnail"] objectAtIndex:1] valueForKey:@"url"];
		NSString *title		= [entry valueForKeyPath:@"title.$t"];
		NSString *author	= [[[entry valueForKeyPath:@"media$group.media$credit"] objectAtIndex:0] valueForKey:@"yt$display"];
		NSString *viewcnt	= [entry valueForKeyPath:@"yt$statistics.viewCount"];
		//-----------------------------------------------------------------------------------------------------------------------------------------
		videoItem *item = [[videoItem alloc] initWith:videoid Thumb:thumb Title:title Author:author ViewCnt:viewcnt];
		[self.items addObject:item];
	}
	//---------------------------------------------------------------------------------------------------------------------------------------------

	//---------------------------------------------------------------------------------------------------------------------------------------------
//	[ProgressHUD dismiss];
    [Util hideIndicator];
	[self.tableView reloadData];
	//---------------------------------------------------------------------------------------------------------------------------------------------
}

@end
