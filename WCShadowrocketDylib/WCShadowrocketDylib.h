//  weibo: http://weibo.com/xiaoqing28
//  blog:  http://www.alonemonkey.com
//
//  WCShadowrocketDylib.h
//  WCShadowrocketDylib
//
//  Created by gwc on 2018/4/10.
//  Copyright (c) 2018 gwc. All rights reserved.
//

#import <Foundation/Foundation.h>

#define INSERT_SUCCESS_WELCOME @"\n               🎉!!！congratulations!!！🎉\n👍----------------insert dylib success----------------👍"

@interface CustomViewController

@property (nonatomic, copy) NSString* newProperty;

- (NSString*)getMyName;

- (void)newMethod:(NSString*) output;

@end
