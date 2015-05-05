//
//  ViewController.m
//  SongLoopSlowdown
//
//  Created by Douglas Voss on 4/16/15.
//  Copyright (c) 2015 Doug. All rights reserved.
//

#import "ViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>

@interface ViewController () <MPMediaPickerControllerDelegate>

@property (strong, nonatomic) AVAudioPlayer *audioPlayer;

@property (strong, nonatomic) UIButton *pickSongButton;
@property (strong, nonatomic) UILabel  *songInfoLabel;

@property (strong, nonatomic) UIImage *sliderTrackLeftImage;
@property (strong, nonatomic) UIImage *sliderTrackRightImage;
@property (strong, nonatomic) UIImage *sliderImage;
@property (strong, nonatomic) UIImage *pickSongButtonNormalImage;
@property (strong, nonatomic) UIImage *pickSongButtonPressedImage;
@property (strong, nonatomic) UIImage *plusButtonNormalImage;
@property (strong, nonatomic) UIImage *plusButtonPressedImage;
@property (strong, nonatomic) UIImage *minusButtonNormalImage;
@property (strong, nonatomic) UIImage *minusButtonPressedImage;

@property (strong, nonatomic) UIImage *normalPlayNormalImage;
@property (strong, nonatomic) UIImage *normalPlayPressedImage;
@property (strong, nonatomic) UIImage *slowPlayNormalImage;
@property (strong, nonatomic) UIImage *slowPlayPressedImage;

@property (strong, nonatomic) UIImage *normalStopNormalImage;
@property (strong, nonatomic) UIImage *normalStopPressedImage;
@property (strong, nonatomic) UIImage *slowStopNormalImage;
@property (strong, nonatomic) UIImage *slowStopPressedImage;

@property (strong, nonatomic) UIImage *backgroundImage;


@property (strong, nonatomic) UILabel  *positionLabel;
@property (strong, nonatomic) UISlider *positionSlider;

@property (strong, nonatomic) UILabel  *startLoopbackLabel;
@property (strong, nonatomic) UISlider *startLoopbackSlider;
@property (strong, nonatomic) UIButton *startLoopbackMinusButton;
@property (strong, nonatomic) UIButton *startLoopbackPlusButton;

@property (strong, nonatomic) UILabel  *endLoopbackLabel;
@property (strong, nonatomic) UISlider *endLoopbackSlider;
@property (strong, nonatomic) UIButton *endLoopbackMinusButton;
@property (strong, nonatomic) UIButton *endLoopbackPlusButton;

@property (strong, nonatomic) UILabel  *playSpeedLabel;
@property (strong, nonatomic) UISlider *playSpeedSlider;
@property (strong, nonatomic) UIButton *playSpeedMinusButton;
@property (strong, nonatomic) UIButton *playSpeedPlusButton;

@property (strong, nonatomic) UIButton *normalPlayStopButton;
@property (strong, nonatomic) UIButton *slowPlayStopButton;

@property (strong, nonatomic) NSTimer *updatePositionTimer;

@property (nonatomic) bool isPlaying;
@property (nonatomic) bool isSlow;

@end

const CGFloat carrierBarOffset = 20.0;
const CGFloat numberOfHorizontalDivisions = 8.0;
const CGFloat numberOfVerticalDivisions = 12.0;
const CGFloat kPlaySpeedSliderMaximumValue = 3.0;

const CGFloat loopPrecision = 0.1;
const CGFloat speedPrecision = 0.01;
const CGFloat kGlobalFontSize = 24.0;

@implementation ViewController

- (NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskLandscape;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.isPlaying = true;
    self.isSlow = false;
    [self loadImages];
    UIImageView *backgroundImageView = [[UIImageView alloc] initWithImage:self.backgroundImage];
    backgroundImageView.frame = [[UIScreen mainScreen] bounds];
    [self.view addSubview:backgroundImageView];
//    [self.view addSubview:self.backgroundImage];
    [self createTopBar];
    [self createPositionSlider];
    [self createStartLoopbackSlider];
    [self createEndLoopbackSlider];
    [self createPlaySpeedSlider];

    self.updatePositionTimer =
    [NSTimer scheduledTimerWithTimeInterval:loopPrecision
                                     target:self
                                   selector:@selector(updatePositionTimerHandler)
                                   userInfo:nil
                                    repeats:YES];
}

- (void)loadImages
{
    self.sliderTrackLeftImage = [[UIImage imageNamed:@"LeftTrackSlice.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 7, 0, 0)];
    self.sliderTrackRightImage = [[UIImage imageNamed:@"RightTrackSlice.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 0, 7)];
    //self.sliderImage = [[UIImage imageNamed:@"Slider.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
    self.sliderImage = [UIImage imageNamed:@"Slider.png"];
    
    self.pickSongButtonNormalImage = [UIImage imageNamed:@"PickSongButtonNormal.png"];
    self.pickSongButtonPressedImage = [UIImage imageNamed:@"PickSongButtonPressed.png"];
    
    self.plusButtonNormalImage = [UIImage imageNamed:@"PlusButtonNormal.png"];
    self.plusButtonPressedImage = [UIImage imageNamed:@"PlusButtonPressed.png"];
    
    self.minusButtonNormalImage = [UIImage imageNamed:@"MinusButtonNormal.png"];
    self.minusButtonPressedImage = [UIImage imageNamed:@"MinusButtonPressed.png"];
    
    self.normalPlayNormalImage = [UIImage imageNamed:@"PlayNormal.png"];
    self.normalPlayPressedImage = [UIImage imageNamed:@"PlayNormalPressed.png"];
    self.slowPlayNormalImage = [UIImage imageNamed:@"PlaySlow.png"];
    self.slowPlayPressedImage = [UIImage imageNamed:@"PlaySlowPressed.png"];

    self.normalStopNormalImage = [UIImage imageNamed:@"StopNormal.png"];
    self.normalStopPressedImage = [UIImage imageNamed:@"StopNormalPressed.png"];
    self.slowStopNormalImage = [UIImage imageNamed:@"StopSlow.png"];
    self.slowStopPressedImage = [UIImage imageNamed:@"StopSlowPressed.png"];

    self.backgroundImage = [UIImage imageNamed:@"Background.png"];
}

- (void)viewDidAppear:(BOOL)animated
{
    self.positionSlider.minimumValue = 0.0;
    self.positionSlider.maximumValue = self.audioPlayer.duration;
    self.positionSlider.value = 0.0;
    
    self.startLoopbackSlider.minimumValue = 0.0;
    self.startLoopbackSlider.maximumValue = self.audioPlayer.duration;
    self.startLoopbackSlider.value = 0.0;

    self.endLoopbackSlider.minimumValue = 0.0;
    self.endLoopbackSlider.maximumValue = self.audioPlayer.duration;
    self.endLoopbackSlider.value = self.audioPlayer.duration;
    
    self.playSpeedSlider.minimumValue = 0.01;
    self.playSpeedSlider.maximumValue = kPlaySpeedSliderMaximumValue;
    self.playSpeedSlider.value = 1.0;
}

- (void)createTopBar {
    CGRect mainRect = [[UIScreen mainScreen] bounds];
    CGFloat leftXMargin = 15.0;
    
    CGFloat buttonWidth = CGRectGetWidth(mainRect)/4.0;
    CGFloat buttonHeight = CGRectGetHeight(mainRect)*(2.0/numberOfVerticalDivisions);
    CGRect buttonRect = CGRectMake(CGRectGetMinX(mainRect)+leftXMargin, CGRectGetMinY(mainRect)+carrierBarOffset, buttonWidth, buttonHeight);
    self.pickSongButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.pickSongButton addTarget:self action:@selector(pickSong) forControlEvents:UIControlEventTouchUpInside];
    self.pickSongButton.frame = buttonRect;
    //[self.pickSongButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.pickSongButton setImage:self.pickSongButtonNormalImage forState:UIControlStateNormal];
    [self.pickSongButton setImage:self.pickSongButtonPressedImage forState:UIControlStateHighlighted];
    //[self.pickSongButton setBackgroundColor:[UIColor blueColor]];
    //[self.pickSongButton setTitle:@"Pick Song" forState:UIControlStateNormal];
    [self.view addSubview:self.pickSongButton];
    
    CGFloat songInfoOriginX = leftXMargin+buttonWidth+leftXMargin;
    CGFloat songInfoWidth = CGRectGetWidth(mainRect)*(3.0/8.0);
    CGFloat songInfoHeight = CGRectGetHeight(mainRect)*(2.0/numberOfVerticalDivisions);
    CGRect songInfoRect = CGRectMake(songInfoOriginX, CGRectGetMinY(mainRect)+carrierBarOffset, songInfoWidth, songInfoHeight);
    self.songInfoLabel = [[UILabel alloc] initWithFrame:songInfoRect];
    //self.songInfoLabel.backgroundColor = [UIColor redColor];
    [self.songInfoLabel setFont:[UIFont fontWithName:@"Open24DisplaySt" size:kGlobalFontSize]];
    //self.songInfoLabel.backgroundColor = [UIColor redColor];
    [self.songInfoLabel setText:@"Please Pick a Song"];
    //[self.songInfoLabel setText:@"Song Loop Slowdown"];
    //[self.songInfoLabel setText:@"abcdefghijklmnopqrstuvwxyz0123456789"];
    [self.songInfoLabel setTextColor:[UIColor blackColor]];
    self.songInfoLabel.numberOfLines = 2;
    self.songInfoLabel.lineBreakMode = NSLineBreakByWordWrapping;
    [self.songInfoLabel sizeToFit];
    [self.view addSubview:self.songInfoLabel];
    
    buttonWidth = buttonHeight;
    buttonRect = CGRectMake(songInfoOriginX+songInfoWidth+10.0, CGRectGetMinY(mainRect)+carrierBarOffset, buttonWidth, buttonHeight);
    self.normalPlayStopButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.normalPlayStopButton.frame = buttonRect;
    [self.normalPlayStopButton addTarget:self action:@selector(playNormalButtonHandler) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.normalPlayStopButton];
    
    buttonWidth = buttonHeight;
    buttonRect = CGRectMake(songInfoOriginX+songInfoWidth+buttonWidth+10.0+10.0, CGRectGetMinY(mainRect)+carrierBarOffset, buttonWidth, buttonHeight);
    self.slowPlayStopButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.slowPlayStopButton.frame = buttonRect;
    [self.view addSubview:self.slowPlayStopButton];
    [self.slowPlayStopButton addTarget:self action:@selector(playSlowButtonHandler) forControlEvents:UIControlEventTouchUpInside];
    [self updatePlayStopImages];
}

- (void)updatePlayStopImages
{
    if (!self.isPlaying) {
        [self.normalPlayStopButton setImage:self.normalPlayNormalImage forState:UIControlStateNormal];
        [self.normalPlayStopButton setImage:self.normalPlayPressedImage forState:UIControlStateHighlighted];
        [self.slowPlayStopButton setImage:self.slowPlayNormalImage forState:UIControlStateNormal];
        [self.slowPlayStopButton setImage:self.slowPlayPressedImage forState:UIControlStateHighlighted];
    } else {
        [self.normalPlayStopButton setImage:self.normalStopNormalImage forState:UIControlStateNormal];
        [self.normalPlayStopButton setImage:self.normalStopPressedImage forState:UIControlStateHighlighted];
        [self.slowPlayStopButton setImage:self.slowStopNormalImage forState:UIControlStateNormal];
        [self.slowPlayStopButton setImage:self.slowStopPressedImage forState:UIControlStateHighlighted];
    }
}

- (IBAction)pickSong
{
    MPMediaPickerController *picker = [[MPMediaPickerController alloc] initWithMediaTypes:MPMediaTypeAnyAudio];
    
    [picker setDelegate:self];
    [picker setAllowsPickingMultipleItems:NO];
    [self presentViewController:picker animated:YES completion:NULL];
}

// Media Picker Delegate
- (void)mediaPicker:(MPMediaPickerController *) mediaPicker didPickMediaItems:(MPMediaItemCollection *) collection {
    
    // remove the media picker screen
    [self dismissViewControllerAnimated:YES completion:NULL];
    
    // grab the first selection (media picker is capable of returning more than one selected item,
    // but this app only deals with one song at a time)
    MPMediaItem *item = [[collection items] objectAtIndex:0];
    NSString *title = [item valueForProperty:MPMediaItemPropertyTitle];
    NSString *artist = [item valueForProperty:MPMediaItemPropertyArtist];
    NSString *topDisplayTitle = [NSString stringWithFormat:@"%@: %@", title, artist];
    [self.songInfoLabel setText:topDisplayTitle];
    
    /*if (!item) {
        NSLog(@"MPMediaItem *item didn't alloc init properly.");
    }*/
    // get a URL reference to the selected item
    NSURL *url = [item valueForProperty:MPMediaItemPropertyAssetURL];
    //NSLog(@"url=%@", url);
    
    NSError *err;
    self.audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&err];
    if (!self.audioPlayer) {
        //NSLog(@"AVAudioPlayer alloc/init failed");
    }
    self.audioPlayer.enableRate=YES;
    self.audioPlayer.rate = 1.0f;
    [self.audioPlayer setNumberOfLoops:-1];
    [self.audioPlayer play];
    if (err != nil) {
        [self.songInfoLabel setText:@"Error opening song"];
        //NSLog(@"AVAudioPlayer Error was %@.  Could be due to song being a DRM (Digital Rights Management) song", err);
    }
}

- (void)mediaPickerDidCancel:(MPMediaPickerController *)mediaPicker
{
    [mediaPicker dismissViewControllerAnimated:YES completion:nil];
}

- (void)updateSliderLabels
{
    [self.positionLabel setText:[NSString stringWithFormat:@"Position: %0.1f seconds", self.positionSlider.value]];
    [self.startLoopbackLabel setText:[NSString stringWithFormat:@"Start Loopback: %0.1f seconds", self.startLoopbackSlider.value]];
    [self.endLoopbackLabel setText:[NSString stringWithFormat:@"End Loopback: %0.1f seconds", self.endLoopbackSlider.value]];
    [self.playSpeedLabel setText:[NSString stringWithFormat:@"Speed: %0.0f percent", self.playSpeedSlider.value*100.0]];
}

- (void)updatePositionTimerHandler
{
    //NSLog(@"update currentTime=%0.2f duration=%0.2f", self.audioPlayer.currentTime, self.audioPlayer.duration);
    self.positionSlider.value = [self roundToTenths:self.audioPlayer.currentTime];
    if (self.positionSlider.value > self.endLoopbackSlider.value) {
        self.positionSlider.value = [self roundToTenths:self.startLoopbackSlider.value];
        self.audioPlayer.currentTime = self.positionSlider.value;
    }
    [self updateSliderLabels];
}

-(double)roundToTenths:(double)arg
{
    return (round(arg*10.0)/10.0);
}

-(void)positionSliderAction:(id)sender
{
    UISlider *slider = (UISlider*)sender;
    self.positionSlider.value = [self roundToTenths:slider.value];
    
    if (self.positionSlider.value > self.endLoopbackSlider.value) {
        self.endLoopbackSlider.value = self.positionSlider.value;
    }
    
    if (self.positionSlider.value < self.startLoopbackSlider.value) {
        self.startLoopbackSlider.value = self.positionSlider.value;
    }
    
    [self updateSliderLabels];
    self.audioPlayer.currentTime = self.positionSlider.value;
}

-(IBAction)createPositionSlider
{
    CGRect screenRect = [UIScreen mainScreen].bounds;
    CGFloat frameWidth = CGRectGetWidth(screenRect)*(6.0/numberOfHorizontalDivisions);
    CGFloat frameHeight = CGRectGetHeight(screenRect)*(1.0/numberOfVerticalDivisions);
    CGFloat frameX = CGRectGetMinX(screenRect) + (CGRectGetWidth(screenRect)*(1.0/numberOfHorizontalDivisions));
    CGFloat frameY = CGRectGetMinY(screenRect) + (CGRectGetHeight(screenRect)*(3.0/numberOfVerticalDivisions));
    CGRect frame = CGRectMake(frameX, frameY, frameWidth, frameHeight);
    
    self.positionLabel = [[UILabel alloc] initWithFrame:frame];
    [self.positionLabel setFont:[UIFont fontWithName:@"Open24DisplaySt" size:kGlobalFontSize]];
    [self updateSliderLabels];
    [self.positionLabel setTextColor:[UIColor blackColor]];
    [self.view addSubview:self.positionLabel];
    
    frameWidth = CGRectGetWidth(screenRect)*(6.0/numberOfHorizontalDivisions);
    frameHeight = CGRectGetHeight(screenRect)*(1.0/numberOfVerticalDivisions);
    frameX = CGRectGetMinX(screenRect) + (CGRectGetWidth(screenRect)*(1.0/numberOfHorizontalDivisions));
    frameY = CGRectGetMinY(screenRect) + (CGRectGetHeight(screenRect)*(4.0/numberOfVerticalDivisions));
    frame = CGRectMake(frameX, frameY, frameWidth, frameHeight);
    
    self.positionSlider = [[UISlider alloc] initWithFrame:frame];
    [self.positionSlider setMinimumTrackImage:self.sliderTrackLeftImage forState:UIControlStateNormal ];
    [self.positionSlider setMaximumTrackImage:self.sliderTrackRightImage forState:UIControlStateNormal];
    [self.positionSlider setThumbImage:self.sliderImage forState:UIControlStateNormal];
    [self.positionSlider setThumbImage:self.sliderImage forState:UIControlStateHighlighted];
    
    
    
    [self.positionSlider addTarget:self action:@selector(positionSliderAction:) forControlEvents:UIControlEventValueChanged];
    self.positionSlider.minimumValue = 0.0;
    self.positionSlider.maximumValue = self.audioPlayer.duration;
    //NSLog(@"self.audioPlayer.duration=%0.2f", self.audioPlayer.duration);
    self.positionSlider.continuous = YES;
    self.positionSlider.value = 0.0;
    
    [self.view addSubview:self.positionSlider];
}

- (IBAction)playNormalButtonHandler
{
    if (self.isPlaying) {
        self.isPlaying = false;
        [self.audioPlayer stop];
        self.positionSlider.value = self.startLoopbackSlider.value;
        self.audioPlayer.currentTime = self.positionSlider.value;
    } else {
        self.isPlaying = true;
        self.isSlow = false;
        self.audioPlayer.rate = 1.0f;
        [self.audioPlayer play];
    }
    [self updatePlayStopImages];
}

- (IBAction)playSlowButtonHandler
{
    if (self.isPlaying) {
        self.isPlaying = false;
        [self.audioPlayer stop];
        self.positionSlider.value = self.startLoopbackSlider.value;
        self.audioPlayer.currentTime = self.positionSlider.value;
    } else {
        self.isPlaying = true;
        self.isSlow = true;
        self.audioPlayer.rate = self.playSpeedSlider.value;
        [self.audioPlayer play];
    }
    [self updatePlayStopImages];
}

- (void)clipStartAndPositionSliders
{
    if (self.positionSlider.value < self.startLoopbackSlider.value)
    {
        self.positionSlider.value = self.startLoopbackSlider.value;
        self.audioPlayer.currentTime = self.positionSlider.value;
    }
}

- (IBAction)startLoopbackPlusButtonHandler
{
    self.startLoopbackSlider.value += loopPrecision;
    [self clipLoopbackSliders];
    [self clipStartAndPositionSliders];
    
    [self updateSliderLabels];
}

- (IBAction)startLoopbackMinusButtonHandler
{
    self.startLoopbackSlider.value -= loopPrecision;
    [self clipLoopbackSliders];
    [self clipStartAndPositionSliders];
    
    [self updateSliderLabels];
}

-(void)startLoopbackSliderAction:(id)sender
{
    UISlider *slider = (UISlider *)sender;
    self.startLoopbackSlider.value = [self roundToTenths:slider.value];
    [self clipLoopbackSliders];
    [self clipStartAndPositionSliders];
    
    [self updateSliderLabels];
}

-(IBAction)createStartLoopbackSlider
{
    CGRect screenRect = [UIScreen mainScreen].bounds;
    CGFloat frameWidth = CGRectGetWidth(screenRect)*(6.0/numberOfHorizontalDivisions);
    CGFloat frameHeight = CGRectGetHeight(screenRect)*(1.0/numberOfVerticalDivisions);
    CGFloat frameX = CGRectGetMinX(screenRect) + (CGRectGetWidth(screenRect)*(1.0/numberOfHorizontalDivisions));
    CGFloat frameY = CGRectGetMinY(screenRect) + (CGRectGetHeight(screenRect)*(5.0/numberOfVerticalDivisions));
    CGRect frame = CGRectMake(frameX, frameY, frameWidth, frameHeight);
    
    self.startLoopbackLabel = [[UILabel alloc] initWithFrame:frame];
    [self.startLoopbackLabel setFont:[UIFont fontWithName:@"Open24DisplaySt" size:kGlobalFontSize]];
    [self updateSliderLabels];
    [self.startLoopbackLabel setTextColor:[UIColor blackColor]];
    [self.view addSubview:self.startLoopbackLabel];
    
    
    [self createPlusMinusButtonsForButton:self.startLoopbackPlusButton
                     plusButtonHandler:@selector(startLoopbackPlusButtonHandler)
                            minusButton:self.startLoopbackMinusButton
                     minusButtonHandler:@selector(startLoopbackMinusButtonHandler)
        verticalPositionInScreenDivisions:5.5];
    
    
    frameWidth = CGRectGetWidth(screenRect)*(6.0/numberOfHorizontalDivisions);
    frameHeight = CGRectGetHeight(screenRect)*(1.0/numberOfVerticalDivisions);
    frameX = CGRectGetMinX(screenRect) + (CGRectGetWidth(screenRect)*(1.0/numberOfHorizontalDivisions));
    frameY = CGRectGetMinY(screenRect) + (CGRectGetHeight(screenRect)*(6.0/numberOfVerticalDivisions));
    frame = CGRectMake(frameX, frameY, frameWidth, frameHeight);
    
    self.startLoopbackSlider = [[UISlider alloc] initWithFrame:frame];
    
    [self.startLoopbackSlider setMinimumTrackImage:self.sliderTrackLeftImage forState:UIControlStateNormal ];
    [self.startLoopbackSlider setMaximumTrackImage:self.sliderTrackRightImage forState:UIControlStateNormal];
    [self.startLoopbackSlider setThumbImage:self.sliderImage forState:UIControlStateNormal];
    [self.startLoopbackSlider setThumbImage:self.sliderImage forState:UIControlStateHighlighted];
    
    [self.startLoopbackSlider addTarget:self action:@selector(startLoopbackSliderAction:) forControlEvents:UIControlEventValueChanged];
    
    self.startLoopbackSlider.value = 0.0;
    self.startLoopbackSlider.continuous = YES;
    self.startLoopbackSlider.minimumValue = 0.0;
    self.startLoopbackSlider.maximumValue = self.audioPlayer.duration;
    
    [self.view addSubview:self.startLoopbackSlider];
    


}

- (void)createPlusMinusButtonsForButton:(UIButton *)plusButton
                     plusButtonHandler:(SEL)plusButtonHandler
                            minusButton:(UIButton *)minusButton
                     minusButtonHandler:(SEL)minusButtonHandler
      verticalPositionInScreenDivisions:(CGFloat)verticalPositionInScreenDivisions
{
    CGRect screenRect = [UIScreen mainScreen].bounds;
    
    CGFloat plusMinusButtonXOffset = (CGRectGetWidth(screenRect)/(numberOfHorizontalDivisions))/16.0;
    
    CGFloat frameHeight = (CGRectGetHeight(screenRect)*(1.0/numberOfVerticalDivisions))*2.0;
    CGFloat frameWidth = frameHeight;
    CGFloat frameX = CGRectGetMinX(screenRect)+plusMinusButtonXOffset;
    CGFloat frameY = CGRectGetMinY(screenRect) + (CGRectGetHeight(screenRect)*(verticalPositionInScreenDivisions/numberOfVerticalDivisions));
    CGRect frame = CGRectMake(frameX, frameY, frameWidth, frameHeight);
    minusButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [minusButton addTarget:self action:minusButtonHandler forControlEvents:UIControlEventTouchUpInside];
    minusButton.frame = frame;
    [minusButton setImage:self.minusButtonNormalImage forState:UIControlStateNormal];
    [minusButton setImage:self.minusButtonPressedImage forState:UIControlStateHighlighted];
    [self.view addSubview:minusButton];
    
    frameHeight = (CGRectGetHeight(screenRect)*(1.0/numberOfVerticalDivisions))*2.0;
    frameWidth = frameHeight;
    frameX = CGRectGetMinX(screenRect)+CGRectGetWidth(screenRect)*((numberOfHorizontalDivisions-1.0)/numberOfHorizontalDivisions) + plusMinusButtonXOffset;
    frameY = CGRectGetMinY(screenRect) + (CGRectGetHeight(screenRect)*(verticalPositionInScreenDivisions/numberOfVerticalDivisions));
    frame = CGRectMake(frameX, frameY, frameWidth, frameHeight);
    plusButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [plusButton addTarget:self action:plusButtonHandler forControlEvents:UIControlEventTouchUpInside];
    plusButton.frame = frame;
    [plusButton setImage:self.plusButtonNormalImage forState:UIControlStateNormal];
    [plusButton setImage:self.plusButtonPressedImage forState:UIControlStateHighlighted];
    [self.view addSubview:plusButton];
}

- (void)clipLoopbackSliders
{
    if (self.startLoopbackSlider.value > self.endLoopbackSlider.value) {
        self.endLoopbackSlider.value = self.startLoopbackSlider.value;
    } else if (self.endLoopbackSlider.value < self.startLoopbackSlider.value) {
        self.startLoopbackSlider.value = self.endLoopbackSlider.value;
    }
}

- (void)clipEndAndPositionSliders
{
    if (self.positionSlider.value > self.endLoopbackSlider.value)
    {
        self.positionSlider.value = self.endLoopbackSlider.value;
        self.audioPlayer.currentTime = self.positionSlider.value;
    }
}

- (IBAction)endLoopbackPlusButtonHandler
{
    self.endLoopbackSlider.value += loopPrecision;
    [self clipLoopbackSliders];
    [self clipEndAndPositionSliders];
    [self updateSliderLabels];
}

- (IBAction)endLoopbackMinusButtonHandler
{
    self.endLoopbackSlider.value -= loopPrecision;
    [self clipLoopbackSliders];
    [self clipEndAndPositionSliders];
    [self updateSliderLabels];
}

-(void)endLoopbackSliderAction:(id)sender
{
    UISlider *slider = (UISlider *)sender;
    self.endLoopbackSlider.value = [self roundToTenths:slider.value];
    [self clipLoopbackSliders];
    [self clipEndAndPositionSliders];
    //NSLog(@"end loopback slider value = %0.2f", slider.value);
    [self updateSliderLabels];
}

-(IBAction)createEndLoopbackSlider
{
    CGRect screenRect = [UIScreen mainScreen].bounds;
    CGFloat frameWidth = CGRectGetWidth(screenRect)*(6.0/numberOfHorizontalDivisions);
    CGFloat frameHeight = CGRectGetHeight(screenRect)*(1.0/numberOfVerticalDivisions);
    CGFloat frameX = CGRectGetMinX(screenRect) + (CGRectGetWidth(screenRect)*(1.0/numberOfHorizontalDivisions));
    CGFloat frameY = CGRectGetMinY(screenRect) + (CGRectGetHeight(screenRect)*(7.0/numberOfVerticalDivisions));
    CGRect frame = CGRectMake(frameX, frameY, frameWidth, frameHeight);
    
    self.endLoopbackLabel = [[UILabel alloc] initWithFrame:frame];
    [self.endLoopbackLabel setFont:[UIFont fontWithName:@"Open24DisplaySt" size:kGlobalFontSize]];
    [self updateSliderLabels];
    [self.endLoopbackLabel setTextColor:[UIColor blackColor]];
    [self.view addSubview:self.endLoopbackLabel];
    
    frameWidth = CGRectGetWidth(screenRect)*(6.0/numberOfHorizontalDivisions);
    frameHeight = CGRectGetHeight(screenRect)*(1.0/numberOfVerticalDivisions);
    frameX = CGRectGetMinX(screenRect) + (CGRectGetWidth(screenRect)*(1.0/numberOfHorizontalDivisions));
    frameY = CGRectGetMinY(screenRect) + (CGRectGetHeight(screenRect)*(8.0/numberOfVerticalDivisions));
    frame = CGRectMake(frameX, frameY, frameWidth, frameHeight);
    
    self.endLoopbackSlider = [[UISlider alloc] initWithFrame:frame];
    [self.endLoopbackSlider setMinimumTrackImage:self.sliderTrackLeftImage forState:UIControlStateNormal ];
    [self.endLoopbackSlider setMaximumTrackImage:self.sliderTrackRightImage forState:UIControlStateNormal];
    [self.endLoopbackSlider setThumbImage:self.sliderImage forState:UIControlStateNormal];
    [self.endLoopbackSlider setThumbImage:self.sliderImage forState:UIControlStateHighlighted];
    
    [self.endLoopbackSlider addTarget:self action:@selector(endLoopbackSliderAction:) forControlEvents:UIControlEventValueChanged];
    
    self.endLoopbackSlider.value = self.audioPlayer.duration;
    self.endLoopbackSlider.continuous = YES;
    self.endLoopbackSlider.minimumValue = 0.0;
    self.endLoopbackSlider.maximumValue = self.audioPlayer.duration;
    
    [self.view addSubview:self.endLoopbackSlider];
    
    
    [self createPlusMinusButtonsForButton:self.endLoopbackPlusButton
                     plusButtonHandler:@selector(endLoopbackPlusButtonHandler)
                            minusButton:self.endLoopbackMinusButton
                     minusButtonHandler:@selector(endLoopbackMinusButtonHandler)
        verticalPositionInScreenDivisions:7.5];
}

- (IBAction)playSpeedPlusButtonHandler
{
    self.playSpeedSlider.value += speedPrecision;
    [self updateSliderLabels];
    if (self.isSlow) {
        self.audioPlayer.rate = self.playSpeedSlider.value;
    } else {
        self.audioPlayer.rate = 1.0f;
    }
}

- (IBAction)playSpeedMinusButtonHandler
{
    self.playSpeedSlider.value -= speedPrecision;
    [self updateSliderLabels];
    if (self.isSlow) {
        self.audioPlayer.rate = self.playSpeedSlider.value;
    } else {
        self.audioPlayer.rate = 1.0f;
    }
}

-(void)playSpeedSliderAction:(id)sender
{
    UISlider *slider = (UISlider*)sender;
    self.playSpeedSlider.value = round(slider.value*100.0)/100.0;
    //NSLog(@"end loopback slider value = %0.2f", slider.value);
    [self updateSliderLabels];
    if (self.isSlow) {
        self.audioPlayer.rate = self.playSpeedSlider.value; // round to nearest percent
    } else {
        self.audioPlayer.rate = 1.0f;
    }
}

-(IBAction)createPlaySpeedSlider
{
    CGRect screenRect = [UIScreen mainScreen].bounds;
    CGFloat frameWidth = CGRectGetWidth(screenRect)*(6.0/numberOfHorizontalDivisions);
    CGFloat frameHeight = CGRectGetHeight(screenRect)*(1.0/numberOfVerticalDivisions);
    CGFloat frameX = CGRectGetMinX(screenRect) + (CGRectGetWidth(screenRect)*(1.0/numberOfHorizontalDivisions));
    CGFloat frameY = CGRectGetMinY(screenRect) + (CGRectGetHeight(screenRect)*(9.0/numberOfVerticalDivisions));
    CGRect frame = CGRectMake(frameX, frameY, frameWidth, frameHeight);
    
    self.playSpeedLabel = [[UILabel alloc] initWithFrame:frame];
    [self.playSpeedLabel setFont:[UIFont fontWithName:@"Open24DisplaySt" size:kGlobalFontSize]];
    [self updateSliderLabels];
    [self.playSpeedLabel setTextColor:[UIColor blackColor]];
    [self.view addSubview:self.playSpeedLabel];
    
    frameWidth = CGRectGetWidth(screenRect)*(6.0/numberOfHorizontalDivisions);
    frameHeight = CGRectGetHeight(screenRect)*(1.0/numberOfVerticalDivisions);
    frameX = CGRectGetMinX(screenRect) + (CGRectGetWidth(screenRect)*(1.0/numberOfHorizontalDivisions));
    frameY = CGRectGetMinY(screenRect) + (CGRectGetHeight(screenRect)*(10.0/numberOfVerticalDivisions));
    frame = CGRectMake(frameX, frameY, frameWidth, frameHeight);
    
    self.playSpeedSlider = [[UISlider alloc] initWithFrame:frame];
    [self.playSpeedSlider setMinimumTrackImage:self.sliderTrackLeftImage forState:UIControlStateNormal ];
    [self.playSpeedSlider setMaximumTrackImage:self.sliderTrackRightImage forState:UIControlStateNormal];
    [self.playSpeedSlider setThumbImage:self.sliderImage forState:UIControlStateNormal];
    [self.playSpeedSlider setThumbImage:self.sliderImage forState:UIControlStateHighlighted];
    
    [self.playSpeedSlider addTarget:self action:@selector(playSpeedSliderAction:) forControlEvents:UIControlEventValueChanged];
    
    self.playSpeedSlider.value = 1.0;
    self.playSpeedSlider.continuous = YES;
    self.playSpeedSlider.minimumValue = 0.01;
    self.playSpeedSlider.maximumValue = kPlaySpeedSliderMaximumValue;
    
    [self.view addSubview:self.playSpeedSlider];
    
 [self createPlusMinusButtonsForButton:self.playSpeedPlusButton
                     plusButtonHandler:@selector(playSpeedPlusButtonHandler)
                            minusButton:self.playSpeedMinusButton
                     minusButtonHandler:@selector(playSpeedMinusButtonHandler)
            verticalPositionInScreenDivisions:9.5];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    NSLog(@"got memory warning.  Oh no!");
}

@end
