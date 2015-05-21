//
//  ViewController.m
//  Not2048
//
//  Created by Arifin Luthfi P on 21/5/15.
//  Copyright (c) 2015 Himaci Studio. All rights reserved.
//

#import "ViewController.h"
#import "Config.h"
#import "Box.h"

typedef NS_ENUM(int, SwipeDirection) {
    SwipeLeft,
    SwipeRight,
    SwipeUp,
    SwipeDown
};

@interface ViewController () {
    UIView* _playground;
    Box* _matrix[PLAYGROUND_SIZE][PLAYGROUND_SIZE];
    int _totalScore;
    UILabel* _totalScoreLabel;
    
    // Temporary
    int _totalBoxMovement;
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    CGSize winSize = [UIScreen mainScreen].bounds.size;
    
    UILabel* totalScoreLabel = _totalScoreLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, winSize.width-20, 50)];
    totalScoreLabel.textAlignment = NSTextAlignmentCenter;
    totalScoreLabel.center = CGPointMake(winSize.width/2, 35);
    totalScoreLabel.text = @"Score : 0";
    [self.view addSubview:totalScoreLabel];
    
    UIView* playground = _playground = [[UIView alloc] initWithFrame:CGRectMake(0, 0, winSize.width-20, winSize.width-20)];
    playground.backgroundColor = [UIColor colorWithWhite:0.75 alpha:1.0];
    playground.center = self.view.center;
    [self.view addSubview:playground];
    
    UIButton* resetButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    resetButton.backgroundColor = [UIColor greenColor];
    resetButton.frame = CGRectMake(0, 0, self.view.bounds.size.width-20, 40);
    resetButton.center = CGPointMake(winSize.width/2, winSize.height-40);
    [resetButton setTitle:@"RESET" forState:UIControlStateNormal];
    [resetButton addTarget:self action:@selector(initGame) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:resetButton];
    
    // Init container
    for (int i=0; i<PLAYGROUND_SIZE; ++i) {
        for (int j=0; j<PLAYGROUND_SIZE; ++j) {
            _matrix[i][j] = nil;
        }
    }
    
    // Start the game
    [self initGame];
    
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

- (void)initGame {
    _playground.userInteractionEnabled = YES;
    
    // Reset score
    _totalScore = 0;
    _totalScoreLabel.text = @"Score : 0";
    
    // Temporary value
    _totalBoxMovement = 0;
    
    // Clear playground
    for (int i=0; i<PLAYGROUND_SIZE; ++i) {
        for (int j=0; j<PLAYGROUND_SIZE; ++j) {
            if (_matrix[i][j]) {
                Box* box = _matrix[i][j];
                [box.view removeFromSuperview];
            }
            _matrix[i][j] = nil;
        }
    }
    // Add two initial box
    [self spawnRandomBox];
    [self spawnRandomBox];
}

- (void)spawnRandomBox {
    // Should list the available spot, but no time :(
    int posX = arc4random_uniform(PLAYGROUND_SIZE);
    int posY = arc4random_uniform(PLAYGROUND_SIZE);
    while (_matrix[posX][posY]) {
        posX = arc4random_uniform(PLAYGROUND_SIZE);
        posY = arc4random_uniform(PLAYGROUND_SIZE);
    }
    int boxValue = arc4random_uniform(1000) < CHANCE_OF_TWO*1000 ? 2 : 4;
    [self spawnBoxWithValue:boxValue posX:posX posY:posY];
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
    boxView.backgroundColor = [self getColor:box.value];
    box.view = boxView;
    
    UILabel* boxLabel = [[UILabel alloc] initWithFrame:boxView.bounds];
    boxLabel.text = [NSString stringWithFormat:@"%d", value];
    boxLabel.textAlignment = NSTextAlignmentCenter;
    box.label = boxLabel;
    [boxView addSubview:boxLabel];
    
    // Initial hidden, then animate
    boxView.alpha = 0.0;
    boxView.center = CGPointMake(10 + boxSize/2 + box.posX*boxSize + box.posX*10, 10 + boxSize/2 + box.posY*boxSize + box.posY*10);
    
    // Add to view
    [_playground addSubview:boxView];
    
    [UIView animateWithDuration:0.1
                          delay:0.1
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         // Update the appearance
                         box.view.alpha = box.alive ? 1.0 : 0.0;
                         box.view.center = CGPointMake(10 + box.boxSize/2 + box.posX*box.boxSize + box.posX*10, 10 + box.boxSize/2 + box.posY*box.boxSize + box.posY*10);
                     }
                     completion:^(BOOL finished) {
                         // ...
                     }];
}

#pragma mark Swipe gesture listener

- (void)swipedLeft:(id)sender {
    [self processBeforeMovement];
    for (int x=0; x<PLAYGROUND_SIZE; ++x) {
        for (int y=0; y<PLAYGROUND_SIZE; ++y) {
            if (_matrix[x][y]) {
                [self moveBox:_matrix[x][y] direction:SwipeLeft];
            }
        }
    }
    [self processAfterMovement];
}

- (void)swipedRight:(id)sender {
    [self processBeforeMovement];
    for (int x=PLAYGROUND_SIZE-1; x>=0; --x) {
        for (int y=0; y<PLAYGROUND_SIZE; ++y) {
            if (_matrix[x][y]) {
                [self moveBox:_matrix[x][y] direction:SwipeRight];
            }
        }
    }
    [self processAfterMovement];
}

- (void)swipedUp:(id)sender {
    [self processBeforeMovement];
    for (int y=0; y<PLAYGROUND_SIZE; ++y) {
        for (int x=0; x<PLAYGROUND_SIZE; ++x) {
            if (_matrix[x][y]) {
                [self moveBox:_matrix[x][y] direction:SwipeUp];
            }
        }
    }
    [self processAfterMovement];
}

- (void)swipedDown:(id)sender {
    [self processBeforeMovement];
    for (int y=PLAYGROUND_SIZE-1; y>=0; --y) {
        for (int x=0; x<PLAYGROUND_SIZE; ++x) {
            if (_matrix[x][y]) {
                [self moveBox:_matrix[x][y] direction:SwipeDown];
            }
        }
    }
    [self processAfterMovement];
}

- (void)processBeforeMovement {
    _totalBoxMovement = 0;
}

- (void)processAfterMovement {
    if (_totalBoxMovement > 0) {
        [self spawnRandomBox];
    }
    
    // Detect game over > all box filled and no merging available
    BOOL fullBox = NO;
    BOOL mergeAvailable = NO;
    
    int counter = 0;
    for (int x=0; x<PLAYGROUND_SIZE; ++x) {
        for (int y=0; y<PLAYGROUND_SIZE; ++y) {
            if (_matrix[x][y]) {
                counter++;
                // Check available merging
                // Left
                if (x>0 && _matrix[x-1][y] && _matrix[x][y].value==_matrix[x-1][y].value) {
                    mergeAvailable = YES;
                }
                // Right
                if (x<PLAYGROUND_SIZE-1 && _matrix[x+1][y] && _matrix[x][y].value==_matrix[x+1][y].value) {
                    mergeAvailable = YES;
                }
                // Left
                if (y>0 && _matrix[x][y-1] && _matrix[x][y].value==_matrix[x][y-1].value) {
                    mergeAvailable = YES;
                }
                // Right
                if (y<PLAYGROUND_SIZE-1 && _matrix[x][y+1] && _matrix[x][y].value==_matrix[x][y+1].value) {
                    mergeAvailable = YES;
                }
            }
        }
    }
    fullBox = counter == PLAYGROUND_SIZE*PLAYGROUND_SIZE;
    
    // Show alert when game over
    if (fullBox && !mergeAvailable) {
        _playground.userInteractionEnabled = NO;
        
        // Show alert
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"GAME OVER!"
                                                        message:@"YEEEAAAHHHHHHH!!!!!"
                                                       delegate:self
                                              cancelButtonTitle:@"Dismiss"
                                              otherButtonTitles:nil];
        [alert show];
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
                _totalBoxMovement++;
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
                _totalBoxMovement++;
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
                _totalBoxMovement++;
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
                _totalBoxMovement++;
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
    
    [UIView animateWithDuration:0.2
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         // Update the appearance
                         box.view.alpha = box.alive ? 1.0 : 0.0;
                         box.view.center = CGPointMake(10 + box.boxSize/2 + box.posX*box.boxSize + box.posX*10, 10 + box.boxSize/2 + box.posY*box.boxSize + box.posY*10);
                     }
                     completion:^(BOOL finished) {
                         // Remove from superview if dead (merged)
                         if (!box.alive) {
                             [box.view removeFromSuperview];
                         }
                     }];
}

- (void)mergeBox:(Box*)box toOtherBox:(Box*)otherBox {
    // Change the value
    otherBox.value = 2*otherBox.value;
    otherBox.label.text = [NSString stringWithFormat:@"%d", otherBox.value];
    otherBox.view.backgroundColor = [self getColor:otherBox.value];
    
    // Remove the box
    _matrix[box.posX][box.posY] = nil;
    box.alive = NO;
    box.posX = otherBox.posX;
    box.posY = otherBox.posY;
    
    // Add score
    _totalScore += otherBox.value;
    _totalScoreLabel.text = [NSString stringWithFormat:@"Score : %d", _totalScore];
    
    // Count as movement
    _totalBoxMovement++;
}

- (UIColor*)getColor:(int)boxValue {
    float modder = 1.0;
    return [UIColor colorWithRed:modff(0.123*boxValue,&modder) green:modff(0.456*boxValue,&modder) blue:modff(0.789*boxValue,&modder) alpha:1.0];
}

@end
