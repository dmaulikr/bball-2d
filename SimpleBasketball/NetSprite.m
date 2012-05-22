//
//  NetSprite.m
//  SimpleBasketball
//
//  Created by Justin Brunet on 5/15/12.
//  Copyright (c) 2012 Blackboard Mobile. All rights reserved.
//

#import "NetSprite.h"

@interface NetSprite ()

- (void)addHoopPlaneAtLocation:(CGPoint)location;

@end

@implementation NetSprite

- (id)initWithSpace:(cpSpace *)space location:(CGPoint)location
{
    if (self = [super initWithSpace:space location:location imageName:@"B-Ball_Retro_Net.png"])
    {
        canBeDestroyed = NO;
    }
    return self;
}

- (void)createBodyAtLocation:(CGPoint)location
{
    CGSize boxSize = CGSizeMake(130, 10);
    float mass = 1.7;
    
    _body = cpBodyNew(mass, cpMomentForBox(mass, boxSize.width, boxSize.height));
    _body->p = location;
    
//    _shape = cpBoxShapeNew(_body, boxSize.width, boxSize.height);
//    _shape->group = 5;
    
    [self addHoopPlaneAtLocation:location];
}

- (void)addHoopPlaneAtLocation:(CGPoint)location
{
    CGSize boxSize = CGSizeMake(130, 6);
    float mass = 1.7;
    
    cpBody *hoopPlaneBody = cpBodyNew(mass, cpMomentForBox(mass, boxSize.width, boxSize.height));
    hoopPlaneBody->p = CGPointMake(location.x, location.y + 130/2 - boxSize.height/2);
    
    cpShape *hoopPlaneShape = cpBoxShapeNew(hoopPlaneBody, boxSize.width, boxSize.height);
    hoopPlaneShape->e = 1.0;
    hoopPlaneShape->u = 0.7;
    hoopPlaneShape->collision_type = kCollisionTypeHoop;
    hoopPlaneShape->group = 5;
    hoopPlaneShape->sensor = YES;
    cpSpaceAddShape(_space, hoopPlaneShape);
}

@end
