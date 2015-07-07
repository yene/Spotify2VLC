//
//  AppDelegate.m
//  Spotify2VLC
//
//  Created by Yannick Weiss on 07/07/15.
//  Copyright © 2015 Yannick Weiss. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@property (weak) IBOutlet NSWindow *window;
@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
  [self startVLC];
  [[NSDistributedNotificationCenter defaultCenter] addObserver:self selector:@selector(updateTrackInfoFromSpotify:) name:@"com.spotify.client.PlaybackStateChanged" object:nil];
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
}

- (void)updateTrackInfoFromSpotify:(NSNotification *)notification {
  NSString *playerState = [notification.userInfo valueForKey:@"Player State"];
  NSString *artist = [notification.userInfo valueForKey:@"Artist"];
  NSString *name = [notification.userInfo valueForKey:@"Name"];
  NSNumber *position = [notification.userInfo valueForKey:@"Playback Position"];
  NSString *songDetails = [NSString stringWithFormat:@"%@ %@", name, artist];
  NSLog(@"search string: %@", songDetails);
  if ([playerState isEqualToString:@"Playing"])  {
    // a new track starts
    if ([position intValue] == 0) {
      songDetails = [songDetails stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLHostAllowedCharacterSet]];
      [self playURLinVLC: songDetails];
    } else {
      [self playVLC];
    }
  } else if ([playerState isEqualToString:@"Paused"])  {
    [self pauseVLC];
  } else if ([playerState isEqualToString:@"Stopped"])  {
    [self quitVLC];
  } else {
    NSLog(@"new state %@", playerState);
  }
}

- (void)startVLC {
  NSString * st = @"tell application \"VLC\" \n"
  "activate \n"
  "set audio volume to 0 \n"
  "end tell";
  NSAppleScript *script = [[NSAppleScript alloc] initWithSource:st];
  [script executeAndReturnError:nil];
}

- (void)playURLinVLC:(NSString *)query {
  NSString * st = [NSString stringWithFormat:@"tell application \"VLC\" \n"
                   "activate \n"
                   "OpenURL \"http://youtube.yannickweiss.com/?q=%@\" \n"
                   "if not fullscreen mode then \n"
                   "fullscreen \n"
                   "end if \n"
                   "set audio volume to 0 \n"
                   "delay 3 \n"
                   "set current time to current time + 3 \n"
                   "end tell", query];
  NSAppleScript *script = [[NSAppleScript alloc] initWithSource:st];
  [script executeAndReturnError:nil];
}

- (void)pauseVLC {
  NSString * st = @"tell application \"VLC\" \n"
  "if playing then \n"
  "play \n"
  "end if \n"
  "end tell";
  NSAppleScript *script = [[NSAppleScript alloc] initWithSource:st];
  [script executeAndReturnError:nil];
}

- (void)playVLC {
  NSString * st = @"tell application \"VLC\" \n"
  "if duration of current item is not equal to -1 then \n"
  "play \n"
  "end if \n"
  "end tell";
  NSAppleScript *script = [[NSAppleScript alloc] initWithSource:st];
  [script executeAndReturnError:nil];
}

- (void)VLCforward {
  NSString * st = @"tell application \"VLC\" to set current time to current time + 2";
  NSAppleScript *script = [[NSAppleScript alloc] initWithSource:st];
  [script executeAndReturnError:nil];
}

- (void)quitVLC {
  NSString * st = @"tell application \"VLC\" to quit \n";
  NSAppleScript *script = [[NSAppleScript alloc] initWithSource:st];
  [script executeAndReturnError:nil];
}

@end
