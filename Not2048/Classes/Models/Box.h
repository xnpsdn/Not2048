//
//  Box.h
//  Not2048
//
//  Created by Arifin Luthfi P on 21/5/15.
//  Copyright (c) 2015 Himaci Studio. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface Box : NSObject

@property (nonatomic, assign) BOOL alive;

@property (nonatomic, assign) int value;
@property (nonatomic, assign) int posX;
@property (nonatomic, assign) int posY;

@property (nonatomic, assign) float boxSize;
@property (nonatomic, retain) UIView* view;
@property (nonatomic, retain) UILabel* label;

@end
