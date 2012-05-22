//
//  BasketballSprite.m
//  SimpleBasketball
//
//  Created by Justin Brunet on 5/15/12.
//  Copyright (c) 2012 Blackboard Mobile. All rights reserved.
//

#import "BasketballSprite.h"

@implementation BasketballSprite

@synthesize shouldTrackCollision = _shouldTrackCollision;

- (id)initWithSpace:(cpSpace *)space location:(CGPoint)location
{
    if (self = [super initWithSpace:space location:location imageName:@"Basketball.png"])
    {
        canBeDestroyed = NO;
    }
    return self;
}

- (void)createBodyAtLocation:(CGPoint)location
{
    float boxSize = 60.0;
    float mass = 0.1;
   _body = cpBodyNew(mass, cpMomentForCircle(mass, 0, boxSize/2, CGPointZero));
    _body->p = location;
    cpSpaceAddBody(_space, _body);
    
    _shape = cpCircleShapeNew(_body, boxSize/2, CGPointZero);
    _shape->e = 0.8;
    _shape->u = 0.7;
    _shape->collision_type = kCollisionTypeBall;
    cpSpaceAddShape(_space, _shape);
}

@end
