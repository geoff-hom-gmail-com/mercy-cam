//
//  NSUserDefaults+GGKAdditions.h
//  Mercy Camera
//
//  Created by Geoff Hom on 5/8/13.
//  Copyright (c) 2013 Geoff Hom. All rights reserved.
//

@interface NSUserDefaults (GGKAdditions)

// Return the key's integer. If not found, then return the alternate value.
- (NSInteger)ggk_integerForKey:(NSString *)theKey ifNil:(NSInteger)theAlternateInteger;

@end
