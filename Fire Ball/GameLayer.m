//
//  GameLayer.m
//  Fire Ball
//
//  Created by Anh Nguyen on 10/26/13.
//  Copyright 2013 Anh Nguyen. All rights reserved.
//

#import "GameLayer.h"

// Needed to obtain the Navigation Controller
#import "AppDelegate.h"

#import "CCTouchDispatcher.h"

@implementation GameLayer

CCSprite *bar;
NSMutableArray *bricks;
CCSprite *ball;
float angle;
CGSize screenSize;

+(CCScene *) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	GameLayer *layer = [GameLayer node];
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}

// on "init" you need to initialize your instance
-(id) init
{
    if( (self=[super init])) {
        // get the screen size
        screenSize = [[CCDirector sharedDirector] winSize];
        
        [self initBar];
        [self initBricks];
        [self initBall];
        
        [self schedule:@selector(nextFrame:)];
        
        self.isTouchEnabled = YES;
    }
    return self;
}

- (void) nextFrame:(ccTime)dt {
    [self moveBall];
}

- (void) moveBall{
    float speed = 3; // Move 50 pixels in 60 frames (1 second)
    float radian = angle * M_PI / 180;
    //NSLog(@"%f", radian);
    float vx = cos(radian) * speed;
    float vy = sin(radian) * speed;
    //NSLog(@"%f",angle);
    CGPoint direction = ccp(vx,vy);
    ball.position = ccpAdd(ball.position, direction);
    if (ball.position.x < [ball boundingBox].size.width || ball.position.x > screenSize.width - [ball boundingBox].size.width) {
        ball.position = ccp(bar.position.x, bar.position.y*2+[ball boundingBox].size.height/2 );
    }
}

// initialize the bottom bar
-(void) initBar{
    bar = [CCSprite spriteWithFile:@"normalBar.png"];
    NSLog(@"pixel %f", [bar boundingBox].size.height);
    bar.position = ccp(screenSize.width/2, [bar boundingBox].size.height/2);
    [self addChild:bar];
}

-(void) initBricks{
    bricks = [[NSMutableArray alloc]init];
    int border = 60;
    int brickWidth = 50;
    for (int i = 0; i<8; i++) {
        CCSprite *brick = [CCSprite spriteWithFile:@"yellowBrick.png"];
        brick.position = ccp(border+i*brickWidth, screenSize.height - 30);
        [self addChild:brick];
        [bricks addObject:brick];
        border++;
    }
}

-(void) initBall{
    NSInteger random = (arc4random()%178)+1;
    angle = random;
    ball = [CCSprite spriteWithFile:@"Icon-72.png"];
    ball.position = ccp(bar.position.x, bar.position.y*2+[ball boundingBox].size.height/2 );
    [self addChild:ball];
    
}


-(void) registerWithTouchDispatcher
{
	[[[CCDirector sharedDirector] touchDispatcher] addTargetedDelegate:self priority:0 swallowsTouches:YES];
}

- (BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event {
    return YES;
}

- (void)ccTouchMoved:(UITouch *)touch withEvent:(UIEvent *)event {
    CGPoint touchLocation = [self convertTouchToNodeSpace:touch];
    
    CGPoint oldTouchLocation = [touch previousLocationInView:touch.view];
    oldTouchLocation = [[CCDirector sharedDirector] convertToGL:oldTouchLocation];
    oldTouchLocation = [self convertToNodeSpace:oldTouchLocation];
    
    CGPoint translation = ccpSub(touchLocation, oldTouchLocation);
    CGPoint newPos = ccpAdd(bar.position, translation);
    bar.position = ccp(newPos.x, [bar boundingBox].size.height/2);
}

// on "dealloc" you need to release all your retained objects
- (void) dealloc
{
	// in case you have something to dealloc, do it in this method
	// in this particular example nothing needs to be released.
	// cocos2d will automatically release all the children (Label)
	
	// don't forget to call "super dealloc"
    [bar release];
	[super dealloc];
}

@end
