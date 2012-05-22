//
//  ZoneSensor.h
//  SimpleBasketball
//
//  Created by Justin Brunet on 5/18/12.
//  Copyright (c) 2012 Blackboard Mobile. All rights reserved.
//

#import "BBSprite.h"

@interface ZoneSensor : BBSprite {
        
}

@property (assign) int pointValue;

- (void)initWithSpace:(cpSpace *)space location:(CGPoint)location size:(CGSize)size pointValue:(int)pointValue;

@end
