//
//  BasketballLayer.h
//  SimpleBasketball
//
//  Created by Justin Brunet on 5/14/12.
//  Copyright (c) 2012 Blackboard Mobile. All rights reserved.
//

#import "CCLayer.h"
#import "cocos2d.h"
#import "chipmunk.h"
#import "cpMouse.h"

@class BasketballSprite, NetSprite, CCLabelTTF;

@interface BasketballLayer : CCLayer {
    
    cpSpace *_space;
    cpMouse *_mouse;
    
    NSMutableArray *_basketballsArray;
    BasketballSprite *_selectedBasketball;
    
    NetSprite *_net;
    
    CCLabelTTF *_scoreLabel, *_timerLabel;;
    CCMenu *_menu;
    
    int _score;
    BOOL _currentlyPlaying;
    
    NSTimer *_timer;
    
}

@property (assign) BasketballSprite *selectedBasketball;
@property (retain) CCLabelTTF *scoreLabel;
@property (assign) int score;
@property (assign) BOOL currentlyPlaying;

+ (id)scene;

@end
