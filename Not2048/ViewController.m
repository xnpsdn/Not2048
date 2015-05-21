//
//  ViewController.m
//  Not2048
//
//  Created by Arifin Luthfi P on 21/5/15.
//  Copyright (c) 2015 Himaci Studio. All rights reserved.
//

#import "ViewController.h"
#import "Box.h"

typedef NS_ENUM(int, SwipeDirection) {
    SwipeLeft,
    SwipeRight,
    SwipeUp,
    SwipeDown
};

#define PLAYGROUND_SIZE 4

@interface ViewController () {
    UIView* _playground;
    Box* _matrix[PLAYGROUND_SIZE][PLAYGROUND_SIZE];
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    CGSize winSize = [UIScreen mainScreen].bounds.size;
    
    UIView* playground = _playground = [[UIView alloc] initWithFrame:CGRectMake(0, 0, winSize.width-20, winSize.width-20)];
    playground.backgroundColor = [UIColor colorWithWhite:0.75 alpha:1.0];
    playground.center = self.view.center;
    [self.view addSubview:playground];
    
    // Init container
    for (int i=0; i<PLAYGROUND_SIZE; ++i) {
        for (int j=0; j<PLAYGROUND_SIZE; ++j) {
            _matrix[i][j] = nil;
        }
    }
    
    // Test...
    for (int i=0; i<1; ++i) {
        //[self spawnBoxWithValue:arc4random_uniform(PLAYGROUND_SIZE) posX:i%PLAYGROUND_SIZE posY:i/PLAYGROUND_SIZE];
        [self spawnBoxWithValue:2 posX:0 posY:0];
        [self spawnBoxWithValue:4 posX:1 posY:0];
        [self spawnBoxWithValue:2 posX:2 posY:0];
        [self spawnBoxWithValue:2 posX:3 posY:0];
        [self spawnBoxWithValue:2 posX:0 posY:1];
    }
    
    // Gesture recognizer
    UISwipeGestureRecognizer* grLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipedLeft:)];
    grLeft.direction = UISwipeGestureRecognizerDirectionLeft;
    [playground addGestureRecognizer:grLeft];
    
    UISwipeGestureRecognizer* grRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipedRight:)];
    grRight.direction = UISwipeGestureRecognizerDirectionRight;
    [playground addGestureRecognizer:grRight];
    
    UISwipeGestureRecognizer* grUp = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipedUp:)];
    grUp.direction = UISwipeGestureRecognizerDirectionUp;
    [playground addGestureRecognizer:grUp];
    
    UISwipeGestureRecognizer* grDown = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipedDown:)];
    grDown.direction = UISwipeGestureRecognizerDirectionDown;
    [playground addGestureRecognizer:grDown];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark Gameplay methods

- (void)initBox {
    // ...
}

- (void)spawnAnotherBox {
    // ...
}

- (void)spawnBoxWithValue:(int)value posX:(int)posX posY:(int)posY {
    Box* box = [[Box alloc] init];
    box.alive = YES;
    box.value = value;
    box.posX = posX;
    box.posY = posY;
    
    // Add to logic
    _matrix[posX][posY] = box;
    
    // Calculate box size
    float boxSize = (_playground.frame.size.width - (10*(PLAYGROUND_SIZE+1))) / PLAYGROUND_SIZE;
    box.boxSize = boxSize;
    
    // Create view and the label
    UIView* boxView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, boxSize, boxSize)];
    boxView.backgroundColor = [UIColor greenColor];
    box.view = boxView;
    
    UILabel* boxLabel = [[UILabel alloc] initWithFrame:boxView.bounds];
    boxLabel.text = [NSString stringWithFormat:@"%d", value];
    boxLabel.textAlignment = NSTextAlignmentCenter;
    box.label = boxLabel;
    [boxView addSubview:boxLabel];
    
    // Update position
    boxView.center = CGPointMake(10 + boxSize/2 + box.posX*boxSize + box.posX*10, 10 + boxSize/2 + box.posY*boxSize + box.posY*10);
    
    // Add to view
    [_playground addSubview:boxView];
}

#pragma mark Swipe gesture listener

- (void)swipedLeft:(id)sender {
    for (int x=0; x<PLAYGROUND_SIZE; ++x) {
        for (int y=0; y<PLAYGROUND_SIZE; ++y) {
            if (_matrix[x][y]) {
                [self moveBox:_matrix[x][y] direction:SwipeLeft];
            }
        }
    }
}

- (void)swipedRight:(id)sender {
    for (int x=PLAYGROUND_SIZE-1; x>=0; --x) {
        for (int y=0; y<PLAYGROUND_SIZE; ++y) {
            if (_matrix[x][y]) {
                [self moveBox:_matrix[x][y] direction:SwipeRight];
            }
        }
    }
}

- (void)swipedUp:(id)sender {
    for (int y=0; y<PLAYGROUND_SIZE; ++y) {
        for (int x=0; x<PLAYGROUND_SIZE; ++x) {
            if (_matrix[x][y]) {
                [self moveBox:_matrix[x][y] direction:SwipeUp];
            }
        }
    }
}

- (void)swipedDown:(id)sender {
    for (int y=PLAYGROUND_SIZE-1; y>=0; --y) {
        for (int x=0; x<PLAYGROUND_SIZE; ++x) {
            if (_matrix[x][y]) {
                [self moveBox:_matrix[x][y] direction:SwipeDown];
            }
        }
    }
}

- (void)moveBox:(Box*)box direction:(SwipeDirection)direction {
    if (direction == SwipeLeft) {
        // Take position
        for (int x=0; x<box.posX; ++x) {
            if (!_matrix[x][box.posY]) {
                _matrix[box.posX][box.posY] = nil;
                _matrix[x][box.posY] = box;
                box.posX = x;
            }
        }
        // Merge if box in the left has same value
        if (box.posX>0 && _matrix[box.posX-1][box.posY]) {
            Box* otherBox = _matrix[box.posX-1][box.posY];
            if (box.value == otherBox.value) {
                [self mergeBox:box toOtherBox:otherBox];
            }
        }
        
    } else if (direction == SwipeRight) {
        // Check boxes in right
        for (int x=PLAYGROUND_SIZE-1; x>=box.posX; --x) {
            if (!_matrix[x][box.posY]) {
                _matrix[box.posX][box.posY] = nil;
                _matrix[x][box.posY] = box;
                box.posX = x;
            }
        }
        // Merge if box in the left has same value
        if (box.posX<PLAYGROUND_SIZE-1 && _matrix[box.posX+1][box.posY]) {
            Box* otherBox = _matrix[box.posX+1][box.posY];
            if (box.value == otherBox.value) {
                [self mergeBox:box toOtherBox:otherBox];
            }
        }
    } else if (direction == SwipeUp) {
        // Check boxes in top
        for (int y=0; y<box.posY; ++y) {
            if (!_matrix[box.posX][y]) {
                _matrix[box.posX][box.posY] = nil;
                _matrix[box.posX][y] = box;
                box.posY = y;
            }
        }
        // Merge if box in the left has same value
        if (box.posY>0 && _matrix[box.posX][box.posY-1]) {
            Box* otherBox = _matrix[box.posX][box.posY-1];
            if (box.value == otherBox.value) {
                [self mergeBox:box toOtherBox:otherBox];
            }
        }
    } else if (direction == SwipeDown) {
        // Check boxes in bottom
        for (int y=PLAYGROUND_SIZE-1; y>=box.posY; --y) {
            if (!_matrix[box.posX][y]) {
                _matrix[box.posX][box.posY] = nil;
                _matrix[box.posX][y] = box;
                box.posY = y;
            }
        }
        // Merge if box in the left has same value
        if (box.posY<PLAYGROUND_SIZE-1 && _matrix[box.posX][box.posY+1]) {
            Box* otherBox = _matrix[box.posX][box.posY+1];
            if (box.value == otherBox.value) {
                [self mergeBox:box toOtherBox:otherBox];
            }
        }
    }
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.2];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
    
    // Update position
    box.view.center = CGPointMake(10 + box.boxSize/2 + box.posX*box.boxSize + box.posX*10, 10 + box.boxSize/2 + box.posY*box.boxSize + box.posY*10);
    box.view.alpha = box.alive ? 1.0 : 0.0;
    
    [UIView commitAnimations];
}

- (void)mergeBox:(Box*)box toOtherBox:(Box*)otherBox {
    otherBox.value = 2*otherBox.value;
    otherBox.label.text = [NSString stringWithFormat:@"%d", otherBox.value];
    
    _matrix[box.posX][box.posY] = nil;
    box.posX = otherBox.posX;
    box.posY = otherBox.posY;
    box.alive = NO;
}

@end
