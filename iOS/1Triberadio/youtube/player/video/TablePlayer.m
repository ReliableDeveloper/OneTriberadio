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

#import "parseutils.h"

#import <AVFoundation/AVFoundation.h>
#import "AFNetworking.h"
#import "ProgressHUD.h"
#import "utilities.h"

#import "TablePlayer.h"

//-------------------------------------------------------------------------------------------------------------------------------------------------
@interface TablePlayer()
{
	videoItem *video;

	NSMutableArray *Items1;
	NSMutableArray *Items2;
	
	UIBarButtonItem *addButton;
	UIBarButtonItem *delButton;
}
@end
//-------------------------------------------------------------------------------------------------------------------------------------------------

@implementation TablePlayer

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (id)initWith:(videoItem *)Video
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	self = [super init];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	video = Video;
	//---------------------------------------------------------------------------------------------------------------------------------------------
	return self;
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)viewDidLoad
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[super viewDidLoad];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	
	//---------------------------------------------------------------------------------------------------------------------------------------------
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playbackStateChanged)
												 name:MPMoviePlayerPlaybackStateDidChangeNotification object:nil];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playbackFinished)
												 name:MPMoviePlayerPlaybackDidFinishNotification object:nil];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	
	//---------------------------------------------------------------------------------------------------------------------------------------------
	Items1 = [[NSMutableArray alloc] init];
	Items2 = [[NSMutableArray alloc] init];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	[Items1 addObject:itemDetailBold(video.title)];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	[Items1 addObject:itemDetail([NSString stringWithFormat:@"%@ views", FormatViewCount(video.viewcnt)])];
	[Items1 addObject:itemDetail([NSString stringWithFormat:@"Uploaded by %@", video.author])];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	[Items2 addObject:itemMenuIcon(@"Share")];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	[self.sections addObject:Items1];
	[self.sections addObject:Items2];
	//---------------------------------------------------------------------------------------------------------------------------------------------
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)viewWillAppear:(BOOL)animated
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[super viewWillAppear:animated];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	if ([self isMovingToParentViewController] == YES)
	{
		CGFloat width = self.view.bounds.size.width;
		CGFloat height = width / 320 * 200;
		//-----------------------------------------------------------------------------------------------------------------------------------------
		UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, width, height)];
		headerView.backgroundColor = [UIColor blackColor];
		self.tableView.tableHeaderView = headerView;
		//-----------------------------------------------------------------------------------------------------------------------------------------
		[self playVideo:video.videoid];
	}
	//---------------------------------------------------------------------------------------------------------------------------------------------
	if ([self isMovingToParentViewController] == NO) [self.player.view setFrame:self.tableView.tableHeaderView.bounds];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)viewWillDisappear:(BOOL)animated
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[super viewWillDisappear:animated];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	if ([self isMovingFromParentViewController]) [self.player stop];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation duration:(NSTimeInterval)duration
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[self.player.view setFrame:self.tableView.tableHeaderView.bounds];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	if (isPhone())
	{
		if ((self.player.playbackState == MPMoviePlaybackStatePlaying) &&
			(UIDeviceOrientationIsLandscape([self interfaceOrientation])))	[self.player setFullscreen:YES animated:YES];
	}
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void) playbackStateChanged
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	if (isPhone())
	{
		if ((self.player.playbackState == MPMoviePlaybackStatePlaying) &&
			(UIDeviceOrientationIsLandscape([self interfaceOrientation])))	[self.player setFullscreen:YES animated:YES];
	}
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void) playbackFinished
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[self.player setFullscreen:NO animated:YES];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	tableItem *tmp = [[self.sections objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	if ([tmp.text1 isEqualToString:@"Share"])
	{
		NSString *link = [NSString stringWithFormat:@"http://www.youtube.com/watch?v=%@", video.videoid];
		//-----------------------------------------------------------------------------------------------------------------------------------------
		NSArray *data = @[video.title, link];
		//-----------------------------------------------------------------------------------------------------------------------------------------
		UIActivityViewController* activityController = [[UIActivityViewController alloc] initWithActivityItems:data applicationActivities:nil];
		[self presentViewController:activityController animated:YES completion:^{}];
	}
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)playVideo:(NSString *)videoid
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	NSString *link = [NSString stringWithFormat:@"https://www.youtube.com/get_video_info?video_id=%@", videoid];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:link]];
	AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	[operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject)
											{ [self didComplete:operation.responseData]; }
									 failure:^(AFHTTPRequestOperation *operation, NSError *error)
											{ NSLog(@"playVideo failed: %@", error); }];
	[[NSOperationQueue mainQueue] addOperation:operation];
	//---------------------------------------------------------------------------------------------------------------------------------------------
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)didComplete:(NSData *)response
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	NSString *linkVideo = @"";
	//---------------------------------------------------------------------------------------------------------------------------------------------
	NSString *videoQuery = [[NSString alloc] initWithData:response encoding:NSASCIIStringEncoding];
	NSDictionary *videoDict = DictionaryWithQueryString(videoQuery, NSUTF8StringEncoding);
	//---------------------------------------------------------------------------------------------------------------------------------------------
	if (videoDict[@"errorcode"] != nil) { [ProgressHUD showError:@"Sorry, this video can only be played on YouTube."]; return; }
	//---------------------------------------------------------------------------------------------------------------------------------------------

	//---------------------------------------------------------------------------------------------------------------------------------------------
	NSArray *streamQueries = [videoDict[@"url_encoded_fmt_stream_map"] componentsSeparatedByString:@","];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	for (NSString *streamQuery in streamQueries)
	{
		NSDictionary *stream = DictionaryWithQueryString(streamQuery, NSUTF8StringEncoding);
		if ([AVURLAsset isPlayableExtendedMIMEType:stream[@"type"]])
		{
			NSString *link = [NSString stringWithFormat:@"%@&signature=%@", stream[@"url"], stream[@"sig"]];
			//-------------------------------------------------------------------------------------------------------------------------------------
			if ([stream[@"itag"] isEqualToString:@"37"] == FALSE) {	linkVideo = link; break; }
		}
	}
	//---------------------------------------------------------------------------------------------------------------------------------------------
	if ([linkVideo isEqualToString:@""] == FALSE)
	{
		self.player = [[MPMoviePlayerController alloc] initWithContentURL:[NSURL URLWithString:linkVideo]];
		[self.player prepareToPlay];
		[self.player.view setFrame:self.tableView.tableHeaderView.bounds];
		[self.tableView.tableHeaderView addSubview:self.player.view];
		[self.player play];
	}
	//---------------------------------------------------------------------------------------------------------------------------------------------
}

@end
