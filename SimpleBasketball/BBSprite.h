//
//  BBSprite.h
//  SimpleBasketball
//
//  Created by Justin Brunet on 5/15/12.
//  Copyright (c) 2012 Blackboard Mobile. All rights reserved.
//

#import "CCSprite.h"
#import "cocos2d.h"
#import "chipmunk.h"

typedef enum {
    kCollisionTypeGround = 0x1,
    kCollisionTypeBall,
    kCollisionTypeHoop
} CollisionType;

@interface BBSprite : CCSprite {
    
    cpBody *_body;
    cpShape *_shape;
    cpSpace *_space;
    BOOL canBeDestroyed;
    
}

@property (assign) cpBody *body;

- (id)initWithSpace:(cpSpace *)space location:(CGPoint)location imageName:(NSString *)spriteFrameName;

- (void)update;
- (void)createBodyAtLocation:(CGPoint)location;
- (void)destroy;

@end