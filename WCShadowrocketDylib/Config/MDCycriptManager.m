//  weibo: http://weibo.com/xiaoqing28
//  blog:  http://www.alonemonkey.com
//
//  MDCycriptManager.m
//  MonkeyDev
//
//  Created by AloneMonkey on 2018/3/8.
//  Copyright © 2018年 AloneMonkey. All rights reserved.
//

#import "MDCycriptManager.h"
#import "MDConfigManager.h"
#include <ifaddrs.h>
#include <arpa/inet.h>
#include <net/if.h>

#define IOS_CELLULAR    @"pdp_ip0"
#define IOS_WIFI        @"en0"
#define IP_ADDR_IPv4    @"ipv4"
#define IP_ADDR_IPv6    @"ipv6"
#define MDLog(fmt, ...) NSLog((@"[Cycript] " fmt), ##__VA_ARGS__)

@implementation MDCycriptManager{
    NSDictionary *_configItem;
    NSMutableDictionary* _loadModules;
    NSString* _cycriptDirectory;
}

+ (instancetype)sharedInstance{
    static MDCycriptManager *sharedInstance = nil;
    if (!sharedInstance){
        sharedInstance = [[MDCycriptManager alloc] init];
    }
    return sharedInstance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _loadModules = [NSMutableDictionary dictionary];
        
        [self check];
        [self createCycriptDirectory];
        [self readConfigFile];
    }
    return self;
}

-(void)check{
    NSString* ip = [self getIPAddress];
    if(ip != nil){
        printf("\nDownload cycript(https://cydia.saurik.com/api/latest/3) then run: ./cycript -r %s:%d\n\n", [ip UTF8String], PORT);
    }else{
        printf("\nPlease connect wifi before using cycript!\n\n");
    }
}

-(NSArray*)loadAtLaunchs{
    
    NSMutableArray* result = [NSMutableArray arrayWithCapacity:10];
    
    NSArray* sortedArray = [_loadModules.allKeys sortedArrayUsingComparator:^NSComparisonResult(NSNumber*  _Nonnull number1, NSNumber*  _Nonnull number2) {
        if ([number1 integerValue] > [number2 integerValue])
            return NSOrderedDescending;
        return NSOrderedAscending;
    }];
    
    for (NSNumber* item in sortedArray) {
        [result addObject:_loadModules[item]];
    }
    
    return [result copy];
}

-(void)createCycriptDirectory{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *documentsPath =[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES) firstObject];
    _cycriptDirectory = [documentsPath stringByAppendingPathComponent:@"cycript"];
    [fileManager createDirectoryAtPath:_cycriptDirectory withIntermediateDirectories:YES attributes:nil error:nil];
}

-(void)readConfigFile{
    MDConfigManager * configManager = [MDConfigManager sharedInstance];
    _configItem = [configManager readConfigByKey:MDCONFIG_CYCRIPT_KEY];
}

-(void)startDownloadCycript:(BOOL) update{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if(_configItem && _configItem.count > 0){
        for (NSString* moduleName in _configItem.allKeys) {
            NSDictionary* setting = _configItem[moduleName];
            NSString* url = setting[@"url"];
            NSString* content = setting[@"content"];
            NSNumber* priority = setting[@"priority"];
            BOOL loadAtLaunch = [setting[@"LoadAtLaunch"] boolValue];
            
            NSString *fullPath = [[_cycriptDirectory stringByAppendingPathComponent:moduleName] stringByAppendingPathExtension:@"cy"];
            
            if(url){
                if(![fileManager fileExistsAtPath:fullPath] || update){
                    [self downLoadUrl:url saveName:moduleName];
                }
            }else if(content){
                if(![fileManager fileExistsAtPath:fullPath] || update){
                    NSString* writeContent = [NSString stringWithFormat:@"(function(exports) { %@ })(exports);", content];
                    [writeContent writeToFile:fullPath atomically:YES encoding:NSUTF8StringEncoding error:nil];
                }
            }
            
            if(loadAtLaunch){
                [_loadModules setObject:fullPath forKey:priority];
            }
        }
    }
}

-(void)downLoadUrl:(NSString*) urlString saveName:(NSString*) filename{
    NSURLSession *session = [NSURLSession sharedSession];
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLSessionDownloadTask *downloadTask = [session downloadTaskWithURL:url completionHandler:^(NSURL * _Nullable location, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        if(error){
            MDLog(@"Failed download script [%@]: %@", filename, error.localizedDescription);
        }else{
            NSString *fullPath = [[_cycriptDirectory stringByAppendingPathComponent:filename] stringByAppendingPathExtension:@"cy"];
            [[NSFileManager defaultManager] moveItemAtURL:location toURL:[NSURL fileURLWithPath:fullPath] error:nil];
            
            MDLog(@"Successful download script [%@]", filename);
        }
    }];
    [downloadTask resume];
}

- (NSString *)getIPAddress{
    
    NSDictionary *addresses = [self getIPAddresses];
    
    if([addresses.allKeys containsObject:IOS_WIFI @"/" IP_ADDR_IPv4]){
        return addresses[IOS_WIFI @"/" IP_ADDR_IPv4];
    }
    
    return nil;
}

- (NSDictionary *)getIPAddresses{
    NSMutableDictionary *addresses = [NSMutableDictionary dictionaryWithCapacity:8];
    
    // retrieve the current interfaces - returns 0 on success
    struct ifaddrs *interfaces;
    if(!getifaddrs(&interfaces)) {
        // Loop through linked list of interfaces
        struct ifaddrs *interface;
        for(interface=interfaces; interface; interface=interface->ifa_next) {
            if(!(interface->ifa_flags & IFF_UP) /* || (interface->ifa_flags & IFF_LOOPBACK) */ ) {
                continue; // deeply nested code harder to read
            }
            const struct sockaddr_in *addr = (const struct sockaddr_in*)interface->ifa_addr;
            char addrBuf[ MAX(INET_ADDRSTRLEN, INET6_ADDRSTRLEN) ];
            if(addr && (addr->sin_family==AF_INET || addr->sin_family==AF_INET6)) {
                NSString *name = [NSString stringWithUTF8String:interface->ifa_name];
                NSString *type;
                if(addr->sin_family == AF_INET) {
                    if(inet_ntop(AF_INET, &addr->sin_addr, addrBuf, INET_ADDRSTRLEN)) {
                        type = IP_ADDR_IPv4;
                    }
                } else {
                    const struct sockaddr_in6 *addr6 = (const struct sockaddr_in6*)interface->ifa_addr;
                    if(inet_ntop(AF_INET6, &addr6->sin6_addr, addrBuf, INET6_ADDRSTRLEN)) {
                        type = IP_ADDR_IPv6;
                    }
                }
                if(type) {
                    NSString *key = [NSString stringWithFormat:@"%@/%@", name, type];
                    addresses[key] = [NSString stringWithUTF8String:addrBuf];
                }
            }
        }
        // Free memory
        freeifaddrs(interfaces);
    }
    return [addresses count] ? addresses : nil;
}

@end

#ifndef __OPTIMIZE__
static __attribute__((constructor)) void entry(){
    MDCycriptManager* manager = [MDCycriptManager sharedInstance];
    [manager startDownloadCycript:YES];
}
#endif
