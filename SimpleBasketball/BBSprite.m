//
//  BBSprite.m
//  SimpleBasketball
//
//  Created by Justin Brunet on 5/15/12.
//  Copyright (c) 2012 Blackboard Mobile. All rights reserved.
//

#import "BBSprite.h"

@implementation BBSprite

@synthesize body = _body;

#pragma mark - Setup/Teardown

- (id)initWithSpace:(cpSpace *)space location:(CGPoint)location imageName:(NSString *)spriteFrameName
{
    if (self = [super initWithFile:spriteFrameName])
    {
        _space = space;
        [self createBodyAtLocation:location];
        canBeDestroyed = YES;
    }
    return self;
}

- (void)createBodyAtLocation:(CGPoint)location
{
    float mass = 1.0;
    _body = cpBodyNew(mass, cpMomentForBox(mass, self.contentSize.width, self.contentSize.height));
    _body->p = location;
    _body->data = self;
    cpSpaceAddBody(_space, _body);
    
    _shape = cpBoxShapeNew(_body, self.contentSize.width, self.contentSize.height);
    _shape->e = 0.3;
    _shape->u = 1.0;
    _shape->data = self;
    cpSpaceAddShape(_space, _shape);
}

- (void)destroy
{
    if (!canBeDestroyed)
        return;
    
    cpSpaceRemoveBody(_space, _body);
    cpSpaceRemoveShape(_space, _shape);
    [self removeFromParentAndCleanup:YES];
}

#pragma mark - Updating

- (void)update 
{
    self.position = self.body->p;
    self.rotation = CC_RADIANS_TO_DEGREES(-1 * self.body->a);
}

@end

