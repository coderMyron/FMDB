//
//  FMDBTools.h
//  FMDB
//
//  Created by Myron on 2019/8/17.
//  Copyright © 2019 Myron. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "fmdb/FMDB.h"

NS_ASSUME_NONNULL_BEGIN


@interface FMDBTools : NSObject

/**初始化*/
+(FMDBTools *)sharedManager;

//单线程创建数据库表
-(void)createTable;

//单线程创建数据库表
-(void)createTableWithSQL:(NSString *)sql;

//增
-(void)insertWithName:(NSString *)name withPhone:(NSString *)phone withScore:(int) score;

//改
-(void)updateWithName:(NSString *)name withPhone:(NSString *)phone;

//删
-(void)deleteWithName:(NSString *)name;

//查
-(NSArray *)queryInfo;

//事务
-(void)handleTransactio;

-(void)handleNotransaction;

//线程安全 事务
-(void)queue_insertWithName:(NSString *)name withPhone:(NSString *)phone withScore:(int)score;

//线程安全
-(void)queue_updateWithName:(NSString *)name withPhone:(NSString *)phone;

//数据库版本号
-(int)userVersion;

//设置数据库版本号
-(void)setUserVersion:(int)version;

//数据库升级 先把旧表重命名，再新建表，再把旧表数据复制到新表
- (BOOL)upgrade;

//数据库升级2 在原表上直接增加列
-(BOOL)upgrade2;

@end

NS_ASSUME_NONNULL_END
