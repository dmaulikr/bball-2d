//
//  AppDelegate.h
//  SimpleBasketball
//
//  Created by Justin Brunet on 5/14/12.
//  Copyright Blackboard Mobile 2012. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RootViewController;

@interface AppDelegate : NSObject <UIApplicationDelegate> {
	UIWindow			*window;
	RootViewController	*viewController;
}

@property (nonatomic, retain) UIWindow *window;

@end
