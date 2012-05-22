//
//  ZoneSensor.m
//  SimpleBasketball
//
//  Created by Justin Brunet on 5/18/12.
//  Copyright (c) 2012 Blackboard Mobile. All rights reserved.
//

#import "ZoneSensor.h"

@implementation ZoneSensor

@synthesize pointValue = _pointValue;

- (void)initWithSpace:(cpSpace *)space location:(CGPoint)location size:(CGSize)size pointValue:(int)pointValue
{
    if (self = [super initWithSpace:space location:location imageName:nil])
    {
        
    }
    return self;
}

@end
