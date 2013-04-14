//
//  GGKCaptureManager.h
//  Mercy Camera
//
//  Created by Geoff Hom on 4/14/13.
//  Copyright (c) 2013 Geoff Hom. All rights reserved.
//

// This manages a capture session for taking photos from the rear camera: Input is the rear camera; output is a still image.

@interface GGKCaptureManager : NSObject

// The input capture device. I.e., the rear camera.
@property (strong, nonatomic) AVCaptureDevice *device;

@property (strong, nonatomic) AVCaptureSession *session;

// Designated initializer.
- (id)init;

// Create and assign the capture session.
- (void)setUpSession;

@end
