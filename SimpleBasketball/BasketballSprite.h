//
//  BasketballSprite.h
//  SimpleBasketball
//
//  Created by Justin Brunet on 5/15/12.
//  Copyright (c) 2012 Blackboard Mobile. All rights reserved.
//

#import "BBSprite.h"
#import "chipmunk.h"

@interface BasketballSprite : BBSprite {
    
}

@property (nonatomic, assign) BOOL shouldTrackCollision;

- (id)initWithSpace:(cpSpace *)space location:(CGPoint)location;

@end
