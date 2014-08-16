//
//  ViewController.m
//  test
//
//  Created by LYH on 2014. 8. 15..
//  Copyright (c) 2014년 YK. All rights reserved.
//

// http://nshipster.com/method-swizzling/


#import "ViewController.h"
#import "objc/runtime.h"

@interface ViewController ()

@end


@implementation ViewController
            
- (void)viewDidLoad {
	[super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	NSLog((@"%s (Line:%d)"), __PRETTY_FUNCTION__, __LINE__);
}


@end

@implementation UIViewController (Tracking)

+ (void)load {
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		Class class = [self class];

		// When swizzling a class method, use the following:
		// Class class = object_getClass((id)self);

		SEL originalSelector = @selector(viewWillAppear:);
		SEL swizzledSelector = @selector(xxx_viewWillAppear:);

		Method originalMethod = class_getInstanceMethod(class, originalSelector);
		Method swizzledMethod = class_getInstanceMethod(class, swizzledSelector);

		BOOL didAddMethod =
		class_addMethod(class,
						originalSelector,
						method_getImplementation(swizzledMethod),
						method_getTypeEncoding(swizzledMethod));

		if (didAddMethod) {
			class_replaceMethod(class,
								swizzledSelector,
								method_getImplementation(originalMethod),
								method_getTypeEncoding(originalMethod));
		} else {
			method_exchangeImplementations(originalMethod, swizzledMethod);
		}
	});
}


#pragma mark - Method Swizzling

- (void)xxx_viewWillAppear:(BOOL)animated {
	[self xxx_viewWillAppear:animated];      // 재귀호출처럼 보이지만 스위즐링상태이므로 무한루프에 빠지지 않는다.
	NSLog((@"%s (Line:%d)"), __PRETTY_FUNCTION__, __LINE__);
}

@end
