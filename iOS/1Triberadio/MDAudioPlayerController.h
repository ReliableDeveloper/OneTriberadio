#import "Track.h"
#import "DOUAudioStreamer.h"
#import "DOUAudioVisualizer.h"

@interface MDAudioPlayerController : UIViewController {
    DOUAudioStreamer *streamer;

    NSTimer *timer;
    bool bShowProgress;
}

@property (nonatomic, copy) NSArray *tracks;
@property (nonatomic) NSInteger currentTrackIndex;

@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet UILabel *artistLabel;
@property (strong, nonatomic) IBOutlet UISlider *progressSlider;
@property (strong, nonatomic) IBOutlet UISlider *volumeSlider;
@property (strong, nonatomic) IBOutlet UIButton *buttonPlayPause;
@property (strong, nonatomic) IBOutlet UIButton *buttonNext;
@property (strong, nonatomic) IBOutlet UIButton *buttonPrev;
@property (strong, nonatomic) IBOutlet UIView *progressView;
@property (strong, nonatomic) IBOutlet UIImageView *playerBackView;
@property (strong, nonatomic) IBOutlet UIView *titleView;
- (IBAction)onClickBackground:(id)sender;
@property (strong, nonatomic) IBOutlet UILabel *durationLabel;
@property (strong, nonatomic) IBOutlet UILabel *currentTimeLabel;
- (IBAction)onVolumeOff:(id)sender;

- (IBAction)onVolumeOn:(id)sender;
@property (strong, nonatomic) IBOutlet UIImageView *playcontrolBackView;


@end



