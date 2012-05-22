//
//  BasketballLayer.m
//  SimpleBasketball
//
//  Created by Justin Brunet on 5/14/12.
//  Copyright (c) 2012 Blackboard Mobile. All rights reserved.
//

#import "BasketballLayer.h"
#import "BasketballSprite.h"
#import "NetSprite.h"

#import "CCLabelTTF.h"

#import "drawSpace.h"

#define BASKETBALL_LAYER_NUMBER_OF_BASKETBALLS 5

@interface BasketballLayer ()

- (void)configureSelf;
- (void)configureScoreLabel;

- (void)createSpace;
- (void)createBoundingBox;
- (void)createBasketballs;
- (void)createHoop;
- (void)createRim;
- (void)createBackboard;
- (void)addCollisionHandlers;

- (void)createGroundFromPoint:(CGPoint)firstPoint toPoint:(CGPoint)secondPoint;

- (void)handleEndOfTouch;

- (void)startGame;
- (void)endGame;
- (void)beginTimer;
- (void)timerTicked;

- (void)resizeSprite:(CCSprite *)sprite toSize:(CGSize)desiredSize;
- (void)mouseGrabIfBallAtLocation:(CGPoint)location;
- (BasketballSprite *)basketballSpriteForBody:(cpBody *)body;
- (void)updateScore:(int)score;

cpBool basketballNetCollisionBegan(cpArbiter *arb, struct cpSpace *space, void *data);
void basketballNetCollisionEnded(cpArbiter *arb, struct cpSpace *space, void *data);

@end

@implementation BasketballLayer

@synthesize selectedBasketball = _selectedBasketball;
@synthesize scoreLabel = _scoreLabel;
@synthesize score = _score;
@synthesize currentlyPlaying = _currentlyPlaying;

#pragma mark - Setup/Teardown

+ (id)scene
{
    CCScene *scene = [CCScene node];
    BasketballLayer *layer = [BasketballLayer node];
    [scene addChild:layer];
    return scene;
}

- (id)init
{
    if (self = [super init])
    {
        [self configureSelf];
        [self configureScoreLabel];
        
        [self createSpace];
        [self createBoundingBox];
        [self createBasketballs];
        [self createHoop];
        [self createRim];
        [self createBackboard];
        
        [self scheduleUpdate];
        _mouse = cpMouseNew(_space);
        
        [self addCollisionHandlers];
        
        CCLabelTTF *startLabel = [CCLabelTTF labelWithString:@"Start Game" fontName:@"Helvetica" fontSize:20];
        CCMenuItemLabel *startGameLabel = [CCMenuItemLabel itemWithLabel:startLabel target:self selector:@selector(startGame)];
        _menu = [[CCMenu menuWithItems:startGameLabel, nil] retain];
        [self addChild:_menu];
    }
    return self;
}

- (void)dealloc
{
    [_basketballsArray release];
    [_net release];
    [_menu release];
    [_timerLabel release];
    cpSpaceFree(_space);
    cpMouseFree(_mouse);
    
    [super dealloc];
}

#pragma mark - View Configuration

- (void)configureSelf
{
    self.isTouchEnabled = YES;
    _basketballsArray = [[NSMutableArray alloc] initWithCapacity:0];
    
    [CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGB565];
    CCSprite *background = [CCSprite spriteWithFile:@"BlueWaveBackground.jpg"];
    background.anchorPoint = ccp(0,0);
    [self addChild:background z:-1];
    [CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_Default];
}

- (void)configureScoreLabel
{
    _scoreLabel = [CCLabelTTF labelWithString:@"0" fontName:@"Helvetica" fontSize:30];
    _scoreLabel.position = CGPointMake(60, 700);
    [self addChild:_scoreLabel];
    
    _timerLabel = [[CCLabelTTF labelWithString:@"30" fontName:@"Helvetica" fontSize:25] retain];
    _timerLabel.position = CGPointMake(400, 700);
}

#pragma mark - Space Creation

- (void)createSpace
{
    _space = cpSpaceNew();
    _space->gravity = CGPointMake(0, -1200);
    _space->damping = 0.9;
    cpSpaceResizeStaticHash(_space, 100, 100);
    cpSpaceResizeActiveHash(_space, 100, 100);
}

- (void)createBoundingBox
{
    float offset = 20; // only want to display 10 pixels of wall
    CGSize windowSize = [CCDirector sharedDirector].winSize;
    [self createGroundFromPoint:CGPointMake(0, -offset) toPoint:CGPointMake(windowSize.width, -offset + 50)];//D
    [self createGroundFromPoint:CGPointMake(-offset, 0) toPoint:CGPointMake(-offset, windowSize.height)];//L
    [self createGroundFromPoint:CGPointMake(0, windowSize.height + offset) toPoint:CGPointMake(windowSize.width, windowSize.height + offset)];//U
    [self createGroundFromPoint:CGPointMake(windowSize.width + offset, 0) toPoint:CGPointMake(windowSize.width + offset, windowSize.height)];//R
}

- (void)createBasketballs
{   
    int xStep = 80, xOrigin = 200;
    
    for (int i = 0; i < BASKETBALL_LAYER_NUMBER_OF_BASKETBALLS; i++)
    {
        BasketballSprite *basketball = [[[BasketballSprite alloc] initWithSpace:_space location:CGPointMake(xOrigin, 117)] autorelease];
        [self resizeSprite:basketball toSize:CGSizeMake(66, 66)];
        [self addChild:basketball];
        
        [_basketballsArray addObject:basketball];
        xOrigin += xStep;
    }
}

- (void)createHoop
{
    CGPoint netOrigin = CGPointMake([CCDirector sharedDirector].winSize.width-130, 430);
    
    _net = [[NetSprite alloc] initWithSpace:_space location:netOrigin];
    [self resizeSprite:_net toSize:CGSizeMake(130, 130)];
    [self addChild:_net];
}

- (void)createRim
{
    CGPoint netOrigin = CGPointMake([CCDirector sharedDirector].winSize.width-130, 430);
    netOrigin = CGPointMake(netOrigin.x - 130/2 + 3, netOrigin.y + 130/2 - 5);
    
    cpBody *leftRimBody = cpBodyNewStatic();
    leftRimBody->p = netOrigin;
    
    float rimHeight = 7.0;
    cpShape *leftRimShape = cpBoxShapeNew(leftRimBody, rimHeight, rimHeight);
    
    leftRimShape->e = 0.8;
    leftRimShape->u = 1.0;
    leftRimShape->group = 5;
//    leftRimShape->collision_type = kCollisionTypeHoop;
    
    cpSpaceAddShape(_space, leftRimShape);
    
    netOrigin = CGPointMake(netOrigin.x + 130+7, netOrigin.y);
    
    cpBody *rightRimBody = cpBodyNewStatic();
    rightRimBody->p = netOrigin;
    
    float rightRimWidth = 20;
    cpShape *rightRimShape = cpBoxShapeNew(rightRimBody, rightRimWidth, rimHeight);
    
    rightRimShape->e = 0.8;
    rightRimShape->u = 1.0;
    rightRimShape->group = 5;
//    rightRimShape->collision_type = kCollisionTypeHoop;
    
    cpSpaceAddShape(_space, rightRimShape);
}

- (void)createBackboard
{
    CGPoint backboardOrigin = CGPointMake([CCDirector sharedDirector].winSize.width-40, 550);
    CGSize backboardSize = CGSizeMake(10, 250);
    
    cpBody *backboardBody = cpBodyNewStatic();
    backboardBody->p = backboardOrigin;
    
    cpShape *backboardShape = cpBoxShapeNew(backboardBody, backboardSize.width, backboardSize.height);
    
    backboardShape->e = 0.8;
    backboardShape->u = 1.0;
    backboardShape->group = 5;
//    backboardShape->collision_type = kCollisionTypeHoop;
    
    cpSpaceAddShape(_space, backboardShape);
}

- (void)createGroundFromPoint:(CGPoint)firstPoint toPoint:(CGPoint)secondPoint
{    
    cpBody *groundBody = cpBodyNewStatic();
    
    float radius = 30;
    cpShape *groundShape = cpSegmentShapeNew(groundBody, firstPoint, secondPoint, radius);
    
    groundShape->e = 0.8;
    groundShape->u = 1.0;
    groundShape->collision_type = kCollisionTypeGround;
    
    cpSpaceAddShape(_space, groundShape);
}

- (void)addCollisionHandlers
{
    cpSpaceAddCollisionHandler(_space, kCollisionTypeBall, kCollisionTypeHoop, basketballNetCollisionBegan, NULL, NULL, basketballNetCollisionEnded, self);
}

#pragma mark - Game Lifecycle

static int countdown = 30;

- (void)startGame
{
    countdown = 30;
    _timerLabel.string = [NSString stringWithFormat:@"%i", countdown];
    [self updateScore:0];
    [self removeChild:_menu cleanup:NO];
    self.currentlyPlaying = YES;
    [self beginTimer];
    [self addChild:_timerLabel];
}

- (void)endGame
{
    [_timer invalidate];
    [_timer release];
    _timer = nil;
    
    countdown = 0;
    [self addChild:_menu];
    [self removeChild:_timerLabel cleanup:NO];
    self.currentlyPlaying = NO;
}

- (void)beginTimer
{
    _timer = [[NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(timerTicked) userInfo:nil repeats:YES] retain];
}

- (void)timerTicked
{
    countdown--;
    _timerLabel.string = [NSString stringWithFormat:@"%i", countdown];
    
    if (countdown <= 0)
        [self endGame];
}

#pragma mark - Updating/Drawing

- (void)update:(ccTime)dt {
    cpSpaceStep(_space, dt);
    
    for (BasketballSprite *basketball in _basketballsArray) {
        [basketball update];
    }
    [_net update];
}

- (void)draw
{
    drawSpaceOptions options = {
        0,
        0,
        1,
        4.0,
        4.0,
        2.0
    };
    
    drawSpace(_space, &options);
}

#pragma mark - Touch Handling

- (void)registerWithTouchDispatcher {
    [[CCTouchDispatcher sharedDispatcher] addTargetedDelegate:self priority:0 swallowsTouches:YES];
}

- (BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event {
    CGPoint touchLocation = [self convertTouchToNodeSpace:touch];
    [self mouseGrabIfBallAtLocation:touchLocation];
    return YES;
}

- (void)ccTouchMoved:(UITouch *)touch withEvent:(UIEvent *)event {
    CGPoint touchLocation = [self convertTouchToNodeSpace:touch];
    cpMouseMove(_mouse, touchLocation);
}

- (void)ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event {
    [self handleEndOfTouch];
}

- (void)ccTouchCancelled:(UITouch *)touch withEvent:(UIEvent *)event {
    [self handleEndOfTouch];
}

- (void)handleEndOfTouch 
{
    cpMouseRelease(_mouse);
    
    if (self.selectedBasketball) 
    {
        self.selectedBasketball.shouldTrackCollision = YES;
        self.selectedBasketball = nil;
    }
}

#pragma mark - Utility

- (void)resizeSprite:(CCSprite *)sprite toSize:(CGSize)desiredSize
{
    CGSize imageSize = [sprite boundingBox].size;
    CGSize scaleFactor = CGSizeMake(desiredSize.width/imageSize.width, desiredSize.height/imageSize.height);
    sprite.scaleX = scaleFactor.width;
    sprite.scaleY = scaleFactor.height;
}

- (void)mouseGrabIfBallAtLocation:(CGPoint)location
{
    cpMouseRelease(_mouse);
	_mouse->body->p = location;
	
    cpShape *grabbedShape = cpSpacePointQueryFirst(_mouse->space, location, GRABABLE_MASK_BIT, 0);
    if (grabbedShape && grabbedShape->collision_type == kCollisionTypeBall)
    {
        cpMouseGrab(_mouse, location, false);
        self.selectedBasketball = [self basketballSpriteForBody:grabbedShape->body];
        self.selectedBasketball.shouldTrackCollision = NO;
    }
}

- (BasketballSprite *)basketballSpriteForBody:(cpBody *)body
{
    for (BasketballSprite *basketball in _basketballsArray) {
        if (basketball.body == body)
            return basketball;
    }
    return nil;
}

- (void)updateScore:(int)score
{
    self.score = score;
    self.scoreLabel.string = [NSString stringWithFormat:@"%i", self.score];
}

#pragma mark - Collision Callbacks

cpBool basketballNetCollisionBegan(cpArbiter *arb, struct cpSpace *space, void *data)
{
    cpBody *basketball = nil;
    cpBody *hoopPlane = nil;
    
    BasketballLayer *layer = (BasketballLayer *)data;
    if (!layer.currentlyPlaying)
        return cpFalse;
    
    CP_ARBITER_GET_BODIES(arb, body_a, body_b);
    CP_ARBITER_GET_SHAPES(arb, shape_a, shape_b);
    
    if (shape_a->collision_type == kCollisionTypeBall)
    {
        basketball = body_a;
        hoopPlane = body_b;
    }
    else
    {
        basketball = body_b;
        hoopPlane = body_a;
    }
    
    BasketballSprite *sprite = [layer basketballSpriteForBody:basketball];

    if (!sprite || !sprite.shouldTrackCollision || basketball->p.y < hoopPlane->p.y)
    {
        if (sprite)
            sprite.shouldTrackCollision = NO;
        return cpFalse;
    }
     
    return cpTrue;
}

void basketballNetCollisionEnded(cpArbiter *arb, struct cpSpace *space, void *data)
{
    BasketballLayer *layer = (BasketballLayer *)data;
    
    cpBody *basketball = nil;
    cpBody *hoopPlane = nil;
    
    CP_ARBITER_GET_BODIES(arb, body_a, body_b);
    CP_ARBITER_GET_SHAPES(arb, shape_a, shape_b);
    
    if (shape_a->collision_type == kCollisionTypeBall)
    {
        basketball = body_a;
        hoopPlane = body_b;
    }
    else
    {
        basketball = body_b;
        hoopPlane = body_a;
    }
    
    BasketballSprite *sprite = [layer basketballSpriteForBody:basketball];
    
    if (!sprite || !sprite.shouldTrackCollision)
        return;
    
    if (basketball->p.y < hoopPlane->p.y && layer.currentlyPlaying)
    {
        layer.score++;
        [layer updateScore:layer.score];
    }
//    sprite.shouldTrackCollision = NO;
}

@end
