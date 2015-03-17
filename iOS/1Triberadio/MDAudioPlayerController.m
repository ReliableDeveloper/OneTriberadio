#import "MDAudioPlayerController.h"
#import "Util.h"
#import "AsyncImageView.h"
static void *kStatusKVOKey = &kStatusKVOKey;
static void *kDurationKVOKey = &kDurationKVOKey;
static void *kBufferingRatioKVOKey = &kBufferingRatioKVOKey;

@interface MDAudioPlayerController () {
@private
}
@end

@implementation MDAudioPlayerController
@synthesize titleLabel;
@synthesize artistLabel;
@synthesize progressSlider;
@synthesize volumeSlider;
@synthesize buttonPlayPause;
@synthesize buttonNext;
@synthesize buttonPrev;
@synthesize progressView;
@synthesize playerBackView;
@synthesize tracks;
@synthesize titleView;
@synthesize currentTrackIndex;
@synthesize currentTimeLabel;
@synthesize durationLabel;
@synthesize playcontrolBackView;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        bShowProgress = false;
    }
    return self;
}

- (void)viewDidLoad
{
    
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"listing_header"] forBarMetrics:UIBarMetricsDefault];
    
    UIBarButtonItem *btnSearch = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"searchbutton"] style:UIBarButtonItemStylePlain target:self action:@selector(gotoSearch)];
    self.navigationItem.rightBarButtonItem = btnSearch;
    UIBarButtonItem *btnMenu = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"threelinebutton"] style:UIBarButtonItemStylePlain target:self action:@selector(gotoMenu)];
    self.navigationItem.leftBarButtonItem = btnMenu;
    UIView *titleViews = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 200, 45)];
    UIImageView *mainTitle = [[UIImageView alloc] initWithFrame:CGRectMake(40, -15, 150, 40)];
    UILabel *subTitle = [[UILabel alloc] initWithFrame:CGRectMake(7, 20, 200, 21)];
    mainTitle.image = [UIImage imageNamed:@"triberadiomark"];
    subTitle.textColor = [UIColor whiteColor];
    subTitle.text = @"Media";
    subTitle.font = [UIFont fontWithName:@"Arial" size:12];
    [subTitle setTextAlignment:NSTextAlignmentCenter];
    [titleViews addSubview:mainTitle];
    [titleViews addSubview:subTitle];
    self.navigationItem.titleView = titleViews;
    
    
    [titleView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"playcontrolbk"]]];
    [progressView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"playcontrolbk"]]];
    [playcontrolBackView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"playcontrolbk"]]];
    [titleLabel setFont:[UIFont systemFontOfSize:20.0]];
    [titleLabel setTextColor:[UIColor whiteColor]];
    [titleLabel setTextAlignment:NSTextAlignmentCenter];
    [titleLabel setLineBreakMode:NSLineBreakByTruncatingTail];
    [artistLabel setFont:[UIFont systemFontOfSize:14.0]];
    [artistLabel setTextColor:[UIColor whiteColor]];
    [artistLabel setTextAlignment:NSTextAlignmentCenter];
    [artistLabel setLineBreakMode:NSLineBreakByTruncatingTail];
    
    Track *track = [tracks objectAtIndex:currentTrackIndex];
    [titleLabel setText:track.title];
    [artistLabel setText:track.artist];
//    NSData *imageData = [NSData dataWithContentsOfURL:track.audioBackImageURL];
//    UIImage *image = [UIImage imageWithData:imageData];
//    [playerBackView setImage:image];
    
    playerBackView.imageURL = track.audioBackImageURL;
    [buttonPlayPause addTarget:self action:@selector(_actionPlayPause:) forControlEvents:UIControlEventTouchDown];

    [buttonNext addTarget:self action:@selector(_actionNext:) forControlEvents:UIControlEventTouchDown];
    [buttonPrev addTarget:self action:@selector(_actionPrev:) forControlEvents:UIControlEventTouchDown];
    [progressSlider setThumbImage:[UIImage imageNamed:@"AudioPlayerScrubberKnob.png"]
                        forState:UIControlStateNormal];
    [progressSlider setMinimumTrackImage:[[UIImage imageNamed:@"AudioPlayerScrubberLeft.png"] stretchableImageWithLeftCapWidth:5 topCapHeight:3] forState:UIControlStateNormal];
    [progressSlider setMaximumTrackImage:[[UIImage imageNamed:@"AudioPlayerScrubberRight.png"]                                             stretchableImageWithLeftCapWidth:5 topCapHeight:3] forState:UIControlStateNormal];
    
    [progressSlider addTarget:self action:@selector(_actionSliderProgress:) forControlEvents:UIControlEventValueChanged];


//    [volumeSlider setThumbImage:[UIImage imageNamed:@"AudioPlayerScrubberKnob.png"]
//                                                        forState:UIControlStateNormal];
//    [volumeSlider setMinimumTrackImage:[[UIImage imageNamed:@"AudioPlayerScrubberLeft.png"] stretchableImageWithLeftCapWidth:5 topCapHeight:3] forState:UIControlStateNormal];
//    [volumeSlider setMaximumTrackImage:[[UIImage imageNamed:@"AudioPlayerScrubberRight.png"]                                             stretchableImageWithLeftCapWidth:5 topCapHeight:3] forState:UIControlStateNormal];
    
    [volumeSlider addTarget:self action:@selector(_actionSliderVolume:) forControlEvents:UIControlEventValueChanged];
    [progressView setHidden:YES];
    [Util hideIndicator];
}

- (void)_cancelStreamer
{
    if (streamer != nil) {
        [streamer pause];
        [streamer removeObserver:self forKeyPath:@"status"];
        [streamer removeObserver:self forKeyPath:@"duration"];
        [streamer removeObserver:self forKeyPath:@"bufferingRatio"];
        streamer = nil;
    }
}

- (void)_resetStreamer
{
    [self _cancelStreamer];
    
    if (0 == [tracks count])
    {

    }
    else
    {
        Track *track = [tracks objectAtIndex:currentTrackIndex];
        [titleLabel setText:track.title];
        [artistLabel setText:track.artist];
        playerBackView.imageURL = track.audioBackImageURL;

        streamer = [DOUAudioStreamer streamerWithAudioFile:track];
        [streamer addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:kStatusKVOKey];
        [streamer addObserver:self forKeyPath:@"duration" options:NSKeyValueObservingOptionNew context:kDurationKVOKey];
        [streamer addObserver:self forKeyPath:@"bufferingRatio" options:NSKeyValueObservingOptionNew context:kBufferingRatioKVOKey];
        
        [streamer play];
        
        [self _updateBufferingStatus];
        [self _setupHintForStreamer];
    }
}

- (void)_setupHintForStreamer
{
    NSUInteger nextIndex = currentTrackIndex + 1;
    if (nextIndex >= [tracks count]) {
        nextIndex = 0;
    }
    
    [DOUAudioStreamer setHintWithAudioFile:[tracks objectAtIndex:nextIndex]];
}

- (void)_timerAction:(id)timer
{
    if ([streamer duration] == 0.0) {
        [progressSlider setValue:0.0f animated:NO];
    }
    else {
        [progressSlider setValue:[streamer currentTime] / [streamer duration] animated:YES];
        NSString *current = [NSString stringWithFormat:@"%d:%02d", (int)streamer.currentTime / 60, (int)streamer.currentTime % 60, nil];
        NSString *dur = [NSString stringWithFormat:@"-%d:%02d", (int)((int)(streamer.duration - streamer.currentTime)) / 60, (int)((int)(streamer.duration - streamer.currentTime)) % 60, nil];
        durationLabel.text = dur;
        currentTimeLabel.text = current;

    }
}

- (void)_updateStatus
{
    switch ([streamer status]) {
        case DOUAudioStreamerPlaying:
            [buttonPlayPause setBackgroundImage:[UIImage imageNamed:@"AudioPlayerPause.png"] forState:UIControlStateNormal];
            break;
            
        case DOUAudioStreamerPaused:
            [buttonPlayPause setBackgroundImage:[UIImage imageNamed:@"AudioPlayerPlay.png"] forState:UIControlStateNormal];
            break;
            
        case DOUAudioStreamerIdle:
            [buttonPlayPause setBackgroundImage:[UIImage imageNamed:@"AudioPlayerPlay.png"] forState:UIControlStateNormal];
            break;
            
        case DOUAudioStreamerFinished:
            [self _actionNext:nil];
            break;
            
        case DOUAudioStreamerBuffering:
            break;
            
        case DOUAudioStreamerError:
            break;
    }
}

- (void)_updateBufferingStatus
{
 
   if ([streamer bufferingRatio] >= 1.0) {
        NSLog(@"sha256: %@", [streamer sha256]);
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (context == kStatusKVOKey) {
        [self performSelector:@selector(_updateStatus)
                     onThread:[NSThread mainThread]
                   withObject:nil
                waitUntilDone:NO];
    }
    else if (context == kDurationKVOKey) {
        [self performSelector:@selector(_timerAction:)
                     onThread:[NSThread mainThread]
                   withObject:nil
                waitUntilDone:NO];
    }
    else if (context == kBufferingRatioKVOKey) {
        [self performSelector:@selector(_updateBufferingStatus)
                     onThread:[NSThread mainThread]
                   withObject:nil
                waitUntilDone:NO];
    }
    else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [Util showIndicator];
    [self _resetStreamer];
    
    timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(_timerAction:) userInfo:nil repeats:YES];
    [volumeSlider setValue:[DOUAudioStreamer volume]];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [timer invalidate];
    [streamer stop];
    [self _cancelStreamer];
    
    [super viewWillDisappear:animated];
}

- (void)_actionPlayPause:(id)sender
{
    if ([streamer status] == DOUAudioStreamerPaused ||
        [streamer status] == DOUAudioStreamerIdle) {
        [streamer play];
    }
    else {
        [streamer pause];
    }
}

- (void)_actionNext:(id)sender
{
    if (++currentTrackIndex >= [tracks count]) {
        currentTrackIndex = 0;
    }
    
    [self _resetStreamer];
}

- (void)_actionPrev:(id)sender
{
    if (--currentTrackIndex <= 0) {
        currentTrackIndex = 0;
    }
    
    [self _resetStreamer];
}

- (void)_actionStop:(id)sender
{
    [streamer stop];
}

- (void)_actionSliderProgress:(id)sender
{
    [streamer setCurrentTime:[streamer duration] * [progressSlider value]];
}

- (void)_actionSliderVolume:(id)sender
{
    [DOUAudioStreamer setVolume:[volumeSlider value]];
}

- (void) gotoSearch {
    
}

- (void) gotoMenu {

    [self dismissViewControllerAnimated:YES completion:nil];
}
- (IBAction)onClickBackground:(id)sender {
    if (bShowProgress) {
        [progressView setHidden:YES];
        [titleView setHidden:NO];
        bShowProgress = false;
    } else {
        [progressView setHidden:NO];
        [titleView setHidden:YES];
        bShowProgress = true;
    }
}
- (IBAction)onVolumeOff:(id)sender {
    [DOUAudioStreamer setVolume:0];
    [volumeSlider setValue:0];
}

- (IBAction)onVolumeOn:(id)sender {
    [DOUAudioStreamer setVolume:1];
    [volumeSlider setValue:1];
}
@end





