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

@interface ViewController ()

@property (strong, nonatomic) AVAudioPlayer *audioPlayer;

@property (strong, nonatomic) UIButton *pickSongButton;

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

@property (strong, nonatomic) NSTimer *updatePositionTimer;

@end

const CGFloat carrierBarOffset = 20.0;

@implementation ViewController

- (NSUInteger)supportedInterfaceOrientations {
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        // iPad: Allow all orientations
        return UIInterfaceOrientationMaskAll;
    } else {
        // iPhone: Allow only landscape
        return UIInterfaceOrientationMaskLandscape;
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [self createButtons];
    [self createPositionSlider];
    [self createStartLoopbackSlider];
    [self createEndLoopbackSlider];

    self.updatePositionTimer =
    [NSTimer scheduledTimerWithTimeInterval:0.5
                                     target:self
                                   selector:@selector(updatePositionTimerHandler)
                                   userInfo:nil
                                    repeats:YES];
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
}

- (void)createButtons {
    CGRect mainRect = [[UIScreen mainScreen] bounds];
    CGFloat buttonWidth = CGRectGetWidth(mainRect);
    CGFloat buttonHeight = CGRectGetHeight(mainRect)/8.0;
    CGRect buttonRect = CGRectMake(CGRectGetMidX(mainRect)-buttonWidth/2.0, CGRectGetMinY(mainRect)+carrierBarOffset, buttonWidth, buttonHeight);
    self.pickSongButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.pickSongButton addTarget:self action:@selector(pickSong) forControlEvents:UIControlEventTouchUpInside];
    self.pickSongButton.frame = buttonRect;
    [self.pickSongButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.pickSongButton setBackgroundColor:[UIColor blueColor]];
    [self.pickSongButton setTitle:@"Pick Song" forState:UIControlStateNormal];
    [self.view addSubview:self.pickSongButton];
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
    [self.pickSongButton setTitle:topDisplayTitle forState:UIControlStateNormal];
    
    // get a URL reference to the selected item
    NSURL *url = [item valueForProperty:MPMediaItemPropertyAssetURL];
    
    NSLog(@"url=%@", url);
    
    self.audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
    self.audioPlayer.enableRate=YES;
    self.audioPlayer.rate = 1.0f;
    [self.audioPlayer setNumberOfLoops:-1];
    [self.audioPlayer play];
}

- (void)updatePositionTimerHandler
{
    NSLog(@"update currentTime=%0.2f duration=%0.2f", self.audioPlayer.currentTime, self.audioPlayer.duration);
    self.positionSlider.value = self.audioPlayer.currentTime;
    if (self.positionSlider.value > self.endLoopbackSlider.value) {
        self.positionSlider.value = self.startLoopbackSlider.value;
        self.audioPlayer.currentTime = self.startLoopbackSlider.value;
    }
    [self.positionLabel setText:[NSString stringWithFormat:@"Position: %0.2f", self.positionSlider.value]];
    [self.startLoopbackLabel setText:[NSString stringWithFormat:@"Start Loopback: %0.2f", self.startLoopbackSlider.value]];
    [self.endLoopbackLabel setText:[NSString stringWithFormat:@"End Loopback: %0.2f", self.endLoopbackSlider.value]];
    
}

-(void)positionSliderAction:(id)sender
{
    UISlider *slider = (UISlider*)sender;
    [self.positionLabel setText:[NSString stringWithFormat:@"Position: %0.2f", self.positionSlider.value]];
    self.audioPlayer.currentTime = slider.value;
}

-(IBAction)createPositionSlider
{
    CGRect screenRect = [UIScreen mainScreen].bounds;
    CGFloat frameWidth = CGRectGetWidth(screenRect)*(6.0/8.0);
    CGFloat frameHeight = CGRectGetHeight(screenRect)*(1.0/8.0);
    CGFloat frameX = CGRectGetMinX(screenRect) + (CGRectGetWidth(screenRect)*(1.0/8.0));
    CGFloat frameY = CGRectGetMinY(screenRect) + (CGRectGetHeight(screenRect)*(2.0/8.0));
    CGRect frame = CGRectMake(frameX, frameY, frameWidth, frameHeight);
    
    self.positionLabel = [[UILabel alloc] initWithFrame:frame];
    [self.positionLabel setText:[NSString stringWithFormat:@"Position: %0.2f", self.positionSlider.value]];
    [self.positionLabel setTextColor:[UIColor blackColor]];
    [self.view addSubview:self.positionLabel];
    
    frameWidth = CGRectGetWidth(screenRect)*(6.0/8.0);
    frameHeight = CGRectGetHeight(screenRect)*(1.0/8.0);
    frameX = CGRectGetMinX(screenRect) + (CGRectGetWidth(screenRect)*(1.0/8.0));
    frameY = CGRectGetMinY(screenRect) + (CGRectGetHeight(screenRect)*(3.0/8.0));
    frame = CGRectMake(frameX, frameY, frameWidth, frameHeight);
    
    self.positionSlider = [[UISlider alloc] initWithFrame:frame];
    
    [self.positionSlider addTarget:self action:@selector(positionSliderAction:) forControlEvents:UIControlEventValueChanged];
    [self.positionSlider setBackgroundColor:[UIColor whiteColor]];
    self.positionSlider.minimumValue = 0.0;
    self.positionSlider.maximumValue = self.audioPlayer.duration;
    //NSLog(@"self.audioPlayer.duration=%0.2f", self.audioPlayer.duration);
    self.positionSlider.continuous = YES;
    self.positionSlider.value = 0.0;
    
    [self.view addSubview:self.positionSlider];
}

- (IBAction)startLoopbackPlusButtonHandler
{
    self.startLoopbackSlider.value += 0.1;
    [self.startLoopbackLabel setText:[NSString stringWithFormat:@"Start Loopback: %0.2f", self.startLoopbackSlider.value]];
}

- (IBAction)startLoopbackMinusButtonHandler
{
    self.startLoopbackSlider.value -= 0.1;
    [self.startLoopbackLabel setText:[NSString stringWithFormat:@"Start Loopback: %0.2f", self.startLoopbackSlider.value]];
}

-(void)startLoopbackSliderAction:(id)sender
{
    UISlider *slider = (UISlider*)sender;
    [self.startLoopbackLabel setText:[NSString stringWithFormat:@"Start Loopback: %0.2f", self.startLoopbackSlider.value]];
}

-(IBAction)createStartLoopbackSlider
{
    CGRect screenRect = [UIScreen mainScreen].bounds;
    CGFloat frameWidth = CGRectGetWidth(screenRect)*(6.0/8.0);
    CGFloat frameHeight = CGRectGetHeight(screenRect)*(1.0/8.0);
    CGFloat frameX = CGRectGetMinX(screenRect) + (CGRectGetWidth(screenRect)*(1.0/8.0));
    CGFloat frameY = CGRectGetMinY(screenRect) + (CGRectGetHeight(screenRect)*(4.0/8.0));
    CGRect frame = CGRectMake(frameX, frameY, frameWidth, frameHeight);
    
    self.startLoopbackLabel = [[UILabel alloc] initWithFrame:frame];
    [self.startLoopbackLabel setText:[NSString stringWithFormat:@"Start Loopback: %0.2f", self.startLoopbackSlider.value]];
    [self.startLoopbackLabel setTextColor:[UIColor blackColor]];
    [self.view addSubview:self.startLoopbackLabel];
    
    frameWidth = CGRectGetWidth(screenRect)*(6.0/8.0);
    frameHeight = CGRectGetHeight(screenRect)*(1.0/8.0);
    frameX = CGRectGetMinX(screenRect) + (CGRectGetWidth(screenRect)*(1.0/8.0));
    frameY = CGRectGetMinY(screenRect) + (CGRectGetHeight(screenRect)*(5.0/8.0));
    frame = CGRectMake(frameX, frameY, frameWidth, frameHeight);
    
    self.startLoopbackSlider = [[UISlider alloc] initWithFrame:frame];
    
    /*[self.startLoopbackSlider setMinimumTrackImage:[UIImage imageNamed:@"slider_minimum.png"] forState:UIControlStateNormal];
    [self.startLoopbackSlider setMaximumTrackImage:[UIImage imageNamed:@"slider_maximum.png"] forState:UIControlStateNormal];
    [self.startLoopbackSlider setThumbImage:[UIImage imageNamed:@"slider_tab.png"] forState:UIControlStateNormal];
    [self.startLoopbackSlider setThumbImage:[UIImage imageNamed:@"slider_tab.png"] forState:UIControlStateHighlighted];*/
    
    [self.startLoopbackSlider addTarget:self action:@selector(startLoopbackSliderAction:) forControlEvents:UIControlEventValueChanged];
    [self.startLoopbackSlider setBackgroundColor:[UIColor whiteColor]];
    
    self.startLoopbackSlider.value = 0.0;
    self.startLoopbackSlider.continuous = YES;
    self.startLoopbackSlider.minimumValue = 0.0;
    self.startLoopbackSlider.maximumValue = self.audioPlayer.duration;
    
    [self.view addSubview:self.startLoopbackSlider];
    
    frameWidth = CGRectGetWidth(screenRect)*(1.0/8.0);
    frameHeight = CGRectGetHeight(screenRect)*(1.0/8.0);
    frameX = CGRectGetMinX(screenRect);
    frameY = CGRectGetMinY(screenRect) + (CGRectGetHeight(screenRect)*(5.0/8.0));
    frame = CGRectMake(frameX, frameY, frameWidth, frameHeight);
    self.startLoopbackMinusButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.startLoopbackMinusButton addTarget:self action:@selector(startLoopbackMinusButtonHandler) forControlEvents:UIControlEventTouchUpInside];
    self.startLoopbackMinusButton.frame = frame;
    [self.startLoopbackMinusButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.startLoopbackMinusButton setBackgroundColor:[UIColor whiteColor]];
    [self.startLoopbackMinusButton setTitle:@"-" forState:UIControlStateNormal];
    [self.view addSubview:self.startLoopbackMinusButton];
    
    frameWidth = CGRectGetWidth(screenRect)*(1.0/8.0);
    frameHeight = CGRectGetHeight(screenRect)*(1.0/8.0);
    frameX = CGRectGetMinX(screenRect)+CGRectGetWidth(screenRect)*(7.0/8.0);
    frameY = CGRectGetMinY(screenRect) + (CGRectGetHeight(screenRect)*(5.0/8.0));
    frame = CGRectMake(frameX, frameY, frameWidth, frameHeight);
    self.startLoopbackPlusButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.startLoopbackPlusButton addTarget:self action:@selector(startLoopbackPlusButtonHandler) forControlEvents:UIControlEventTouchUpInside];
    self.startLoopbackPlusButton.frame = frame;
    [self.startLoopbackPlusButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.startLoopbackPlusButton setBackgroundColor:[UIColor whiteColor]];
    [self.startLoopbackPlusButton setTitle:@"+" forState:UIControlStateNormal];
    [self.view addSubview:self.startLoopbackPlusButton];
}

- (IBAction)endLoopbackPlusButtonHandler
{
    self.endLoopbackSlider.value += 0.1;
    [self.endLoopbackLabel setText:[NSString stringWithFormat:@"End Loopback: %0.2f", self.endLoopbackSlider.value]];
}

- (IBAction)endLoopbackMinusButtonHandler
{
    self.endLoopbackSlider.value -= 0.1;
    [self.endLoopbackLabel setText:[NSString stringWithFormat:@"End Loopback: %0.2f", self.endLoopbackSlider.value]];
}

-(void)endLoopbackSliderAction:(id)sender
{
    UISlider *slider = (UISlider*)sender;
    //NSLog(@"end loopback slider value = %0.2f", slider.value);
    [self.endLoopbackLabel setText:[NSString stringWithFormat:@"End Loopback: %0.2f", self.endLoopbackSlider.value]];
}

-(IBAction)createEndLoopbackSlider
{
    CGRect screenRect = [UIScreen mainScreen].bounds;
    CGFloat frameWidth = CGRectGetWidth(screenRect)*(6.0/8.0);
    CGFloat frameHeight = CGRectGetHeight(screenRect)*(1.0/8.0);
    CGFloat frameX = CGRectGetMinX(screenRect) + (CGRectGetWidth(screenRect)*(1.0/8.0));
    CGFloat frameY = CGRectGetMinY(screenRect) + (CGRectGetHeight(screenRect)*(6.0/8.0));
    CGRect frame = CGRectMake(frameX, frameY, frameWidth, frameHeight);
    
    self.endLoopbackLabel = [[UILabel alloc] initWithFrame:frame];
    [self.endLoopbackLabel setText:[NSString stringWithFormat:@"End Loopback: %0.2f", self.endLoopbackSlider.value]];
    [self.endLoopbackLabel setTextColor:[UIColor blackColor]];
    [self.view addSubview:self.endLoopbackLabel];
    
    frameWidth = CGRectGetWidth(screenRect)*(6.0/8.0);
    frameHeight = CGRectGetHeight(screenRect)*(1.0/8.0);
    frameX = CGRectGetMinX(screenRect) + (CGRectGetWidth(screenRect)*(1.0/8.0));
    frameY = CGRectGetMinY(screenRect) + (CGRectGetHeight(screenRect)*(7.0/8.0));
    frame = CGRectMake(frameX, frameY, frameWidth, frameHeight);
    
    self.endLoopbackSlider = [[UISlider alloc] initWithFrame:frame];
    
    [self.endLoopbackSlider addTarget:self action:@selector(endLoopbackSliderAction:) forControlEvents:UIControlEventValueChanged];
    [self.endLoopbackSlider setBackgroundColor:[UIColor whiteColor]];
    
    self.endLoopbackSlider.value = self.audioPlayer.duration;
    self.endLoopbackSlider.continuous = YES;
    self.endLoopbackSlider.minimumValue = 0.0;
    self.endLoopbackSlider.maximumValue = self.audioPlayer.duration;
    
    [self.view addSubview:self.endLoopbackSlider];
    
    frameWidth = CGRectGetWidth(screenRect)*(1.0/8.0);
    frameHeight = CGRectGetHeight(screenRect)*(1.0/8.0);
    frameX = CGRectGetMinX(screenRect);
    frameY = CGRectGetMinY(screenRect) + (CGRectGetHeight(screenRect)*(7.0/8.0));
    frame = CGRectMake(frameX, frameY, frameWidth, frameHeight);
    self.endLoopbackMinusButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.endLoopbackMinusButton addTarget:self action:@selector(endLoopbackMinusButtonHandler) forControlEvents:UIControlEventTouchUpInside];
    self.endLoopbackMinusButton.frame = frame;
    [self.endLoopbackMinusButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.endLoopbackMinusButton setBackgroundColor:[UIColor whiteColor]];
    [self.endLoopbackMinusButton setTitle:@"-" forState:UIControlStateNormal];
    [self.view addSubview:self.endLoopbackMinusButton];
    
    frameWidth = CGRectGetWidth(screenRect)*(1.0/8.0);
    frameHeight = CGRectGetHeight(screenRect)*(1.0/8.0);
    frameX = CGRectGetMinX(screenRect)+CGRectGetWidth(screenRect)*(7.0/8.0);
    frameY = CGRectGetMinY(screenRect) + (CGRectGetHeight(screenRect)*(7.0/8.0));
    frame = CGRectMake(frameX, frameY, frameWidth, frameHeight);
    self.endLoopbackPlusButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.endLoopbackPlusButton addTarget:self action:@selector(endLoopbackPlusButtonHandler) forControlEvents:UIControlEventTouchUpInside];
    self.endLoopbackPlusButton.frame = frame;
    [self.endLoopbackPlusButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.endLoopbackPlusButton setBackgroundColor:[UIColor whiteColor]];
    [self.endLoopbackPlusButton setTitle:@"+" forState:UIControlStateNormal];
    [self.view addSubview:self.endLoopbackPlusButton];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
