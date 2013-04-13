//
//  GGKOverlayViewController.m
//  GGK Cam A
//
//  Created by Geoff Hom on 2/6/13.
//  Copyright (c) 2013 Geoff Hom. All rights reserved.
//

#import "GGKOverlayViewController.h"

@interface GGKOverlayViewController ()

@end

@implementation GGKOverlayViewController

- (IBAction)cancelPhoto {
    
    NSLog(@"cancelPhoto called");
//    [self.delegate overlayViewControllerDidFinishWithCamera];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (IBAction)takePhoto {
    
    NSLog(@"takePhoto called");
    [self.imagePickerController takePicture];
    NSLog(@"takePhoto2 called");
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

@end
