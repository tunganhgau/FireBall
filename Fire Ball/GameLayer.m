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
CGSize screenSize; //iphone 4(480x320), iphone5(568,320), ipad(1024x768)
float speed;
BOOL skipThisFrame=NO; // this to prevent a bug when the ball collide with the bar
NSString *device;

int life = 3;

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
        if (screenSize.width==1024) {
            device = @"iPad";
        }
        else{
            device = @"iPhone";
        }
        NSLog(@"Width:%f, Height:%f", screenSize.width, screenSize.height);
        [self initBar];
        [self initBricks];
        [self initBall];
        
        [self schedule:@selector(nextFrame:)];
        
        self.isTouchEnabled = YES;
        
        [[CCDirector sharedDirector] setDisplayStats:NO];
    }
    return self;
}

- (void) nextFrame:(ccTime)dt {
    [self moveBall];
}

- (void) moveBall{
    float radian = angle * M_PI / 180;

    float vx = cos(radian) * speed;
    float vy = sin(radian) * speed;

    CGPoint direction = ccp(vx,vy);
    ball.position = ccpAdd(ball.position, direction);
    
    [self detectAllCollision];

}

-(void) detectAllCollision{
    int collideValue= 0;
	for (int i = 0; i<[bricks count]; i++){
		int collision =[self detectCollisionWithBall:ball andSprite:bricks[i]];
        //NSLog(@"%d", collideValue);
		if (collision != 0){
            collideValue = collision;
			// collide with brick
			[self removeChild:bricks[i]];
			[bricks removeObject:bricks[i]];
		}
	}
    switch(collideValue){
        case(1):
            [self collideOnTop];break;
        case(2):
            [self collideOnRight];break;
        case(3):
            [self collideOnBottom];break;
        case(4):
            [self collideOnLeft];break;
        default:
            break;
    }
    
    //hit the left screen
    if (ball.position.x < [ball boundingBox].size.width/2){
        [self collideOnLeft];
    }
    // hit the right screen
    if(ball.position.x > screenSize.width - [ball boundingBox].size.width/2){
        [self collideOnRight];
    }
    // hit the top
    if(ball.position.y>screenSize.height - [ball boundingBox].size.height/2) {
        [self collideOnTop];
    }
    
    // fall off
    if(ball.position.y+[ball boundingBox].size.height/2<0) {
        if (life>0) {
            [self resetBall];
        }
        else{
            [self gameEnded];
        }
    }
    
	if (CGRectIntersectsRect(ball.boundingBox, bar.boundingBox)){
        if (!skipThisFrame) {
            [self collideOnBottom];
            int intersectValue = (bar.position.x - ball.position.x);
            angle+=intersectValue;
            if (angle<30) {
                angle=30;
            }
            if (angle>150) {
                angle=150;
            }
            skipThisFrame = YES;
        }
	}
    else{
        skipThisFrame=NO;
    }
}

-(void) gameEnded{
    [[CCDirector sharedDirector] pause];
    UIAlertView *gameOverAlert = [[UIAlertView alloc]initWithTitle:@"Game Over" message:@"That was a good game" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [gameOverAlert show];
}

-(void) resetBall{
    life--;
    ball.position = ccp(bar.position.x, bar.position.y*2+[ball boundingBox].size.height/2 );
    angle = (arc4random()%90)+60;
}

-(void) collideOnRight{
	if (angle < 180){
		angle = 180-angle;
	}
	else{
		angle = 360-(angle-180);
	}
    //NSLog(@"Collided Right");
}
-(void) collideOnLeft{
	if (angle <180){
		angle=180-angle;
	}
	else{
		angle=360-(angle-180);
	}
    //NSLog(@"Collided Left");
}
-(void) collideOnTop{
	if (angle==90){
		angle=270;
	}
	else if(angle<90){
		angle=360-angle;
	}
	else{
		angle=360-angle;
	}
    //NSLog(@"Collided Top");
}
-(void) collideOnBottom{
	if (angle==270){
		angle=90;
	}
	else if(angle<270){
		angle=360-angle;
	}
	else{
		angle=360-angle;
	}
    //NSLog(@"Collided Bottom");
}



// return 1 for top, 2 for right, 3 for bottom, 4 for left, 0 for no collision
- (int) detectCollisionWithBall:(CCSprite*) ball andSprite:(CCSprite *) sprite{
    if (CGRectIntersectsRect([ball boundingBox], [sprite boundingBox])) {
        //NSLog(@"Collided");
        if (angle<=90) {
            if (fabsf(ball.position.x - sprite.position.x) >  ([ball boundingBox].size.width/2+[sprite boundingBox].size.width/2)*0.9){
                return 2;
            }
            //if (ball.position.y+[ball boundingBox].size.height/2 - (sprite.position.y - [sprite boundingBox].size.height/2)>0){
                if (fabsf(ball.position.y-sprite.position.y) < [sprite boundingBox].size.height/2) {
                    return 2;
                }
            //}
            
            return 1;
        }
        else if(angle>90 && angle<=180){
            if (fabsf(ball.position.x - sprite.position.x) >  ([ball boundingBox].size.width/2+[sprite boundingBox].size.width/2)*0.9){

                return 4;
            }
            //if (ball.position.y+[ball boundingBox].size.height/2 - (sprite.position.y - [sprite boundingBox].size.height/2)>0){
                if (fabsf(ball.position.y-sprite.position.y) < [sprite boundingBox].size.height/2) {
                    return 4;
                }
            //}
            return 1;
        }
        else if (angle>180 && angle <=270){
            if (fabsf(ball.position.x - sprite.position.x) >  ([ball boundingBox].size.width/2+[sprite boundingBox].size.width/2)*0.9){

                return 4;
            }
            
            //if (ball.position.y-[ball boundingBox].size.height/2 - (sprite.position.y + [sprite boundingBox].size.height/2)<0){
                if (fabsf(ball.position.y-sprite.position.y) < [sprite boundingBox].size.height/2) {
                    return 4;
                }
            //}
            return 3;
        }
        else{
            if (fabsf(ball.position.x - sprite.position.x) >  ([ball boundingBox].size.width/2+[sprite boundingBox].size.width/2)*0.9){
 

                return 2;
            }
            
            //if (ball.position.y-[ball boundingBox].size.height/2 - (sprite.position.y + [sprite boundingBox].size.height/2)<0){
                if (fabsf(ball.position.y-sprite.position.y) < [sprite boundingBox].size.height/2) {
                    return 2;
                }
            //}
            return 3;
        }
       
        
    }

	return 0;
}



// initialize the bottom bar
-(void) initBar{
    bar = [CCSprite spriteWithFile:@"bar.png"];
    NSLog(@"pixel %f", [bar boundingBox].size.height);
    bar.position = ccp(screenSize.width/2, [bar boundingBox].size.height/2);
    [self addChild:bar];
}

-(void) initBricks{
    bricks = [[NSMutableArray alloc]init];
    CCSprite *dummyBrick = [CCSprite spriteWithFile:@"whiteBrick.png"];
    float brickWidth = [dummyBrick boundingBox].size.width;
    float brickHeight= [dummyBrick boundingBox].size.height;
    //[dummyBrick release];
    float border;
    float topMargin;
    if ([device isEqual:@"iPhone"]) {
        border = 1;
        topMargin = 50;
    }
    else{
        border = 2;
        topMargin = 80;
    }
    
    float leftMargin = (screenSize.width -brickWidth*10 - 9)/2;

    for (int row = 0; row<7; row++) {
        float temp = leftMargin;
        for (int col = 0; col <10; col++) {
            CCSprite *brick = [CCSprite spriteWithFile:@"whiteBrick.png"];
            float x = leftMargin+[brick boundingBox].size.width/2+border;
            float y = screenSize.height - topMargin-[brick boundingBox].size.height/2-border;
            brick.position = ccp(x, y);
            [self addChild:brick];
            [bricks addObject:brick];
            //NSLog(@"%d", margin);
            leftMargin+=brickWidth+border;
        }
        leftMargin = temp;
        topMargin+=brickHeight+border;
    }
}

-(void) initBall{
    if ([device isEqual:@"iPhone"]) {
        speed = 5;
    }
    else{
        speed = 10;
    }
    NSLog(@"%@, %f", device, speed);
    NSInteger random = (arc4random()%90)+60;
    angle = random;
    ball = [CCSprite spriteWithFile:@"ball.png"];
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
    if (newPos.x < [bar boundingBox].size.width/2) {
        bar.position = ccp([bar boundingBox].size.width/2, [bar boundingBox].size.height/2);
    }
    else if(newPos.x > screenSize.width - [bar boundingBox].size.width/2){
        bar.position = ccp(screenSize.width - [bar boundingBox].size.width/2, [bar boundingBox].size.height/2);
    }
    else{
        bar.position = ccp(newPos.x, [bar boundingBox].size.height/2);
    }
}

- (void) applicationDidEnterBackground:(UIApplication *)application
{
    [[CCDirector sharedDirector] stopAnimation];
    [[CCDirector sharedDirector] pause];
}
- (void)applicationWillResignActive:(UIApplication *)application
{
    [[CCDirector sharedDirector] stopAnimation];
    [[CCDirector sharedDirector] pause];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    [[CCDirector sharedDirector] stopAnimation]; // call this to make sure you don't start a second display link!
    [[CCDirector sharedDirector] resume];
    [[CCDirector sharedDirector] startAnimation];
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
