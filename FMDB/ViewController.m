//
//  ViewController.m
//  FMDB
//
//  Created by Myron on 2019/8/17.
//  Copyright © 2019 Myron. All rights reserved.
//

#import "ViewController.h"
#import "FMDBTools.h"
#import "StudentInfo.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    FMDBTools *dbTools = [FMDBTools sharedManager];
    
    [dbTools createTable];
    
    [dbTools insertWithName:@"LISI" withPhone:@"18300000000" withScore:90];
    [dbTools insertWithName:@"王五" withPhone:@"18300000000" withScore:90];
    
//    [dbTools updateWithName:@"王五" withPhone:@"15811111111"];
    
//    [dbTools deleteWithName:@"LISI"];
    
//    [dbTools queue_insertWithName:@"小五1" withPhone:@"13711111111" withScore:99];
    
//    [dbTools queue_updateWithName:@"小五1" withPhone:@"12300000000"];
    
//    NSArray *infos = [dbTools queryInfo];
//    for (int i = 0; i < infos.count; i++) {
//        StudentInfo *info = [infos objectAtIndex:i];
//        NSLog(@"name:%@,phone:%@,score:%d",info.name,info.phone,info.score);
//    }
    
//    [dbTools handleTransactio];
    
//    [dbTools handleNotransaction];
    
//    [dbTools setUserVersion:2];
    int version = [dbTools userVersion];
    NSLog(@"%d",version);
    
//    BOOL isUpgrade = [dbTools upgrade];
    
    BOOL isUpgrade = [dbTools upgrade2];
    
    NSLog(@"升级%@",(isUpgrade == NO) ? @"失败" : @"成功");
    

}


@end
