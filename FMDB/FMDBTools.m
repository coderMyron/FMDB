//
//  FMDBTools.m
//  FMDB
//
//  Created by Myron on 2019/8/17.
//  Copyright © 2019 Myron. All rights reserved.
//

#import "FMDBTools.h"
#import "StudentInfo.h"

/**数据库路径*/
static NSString *DBPath;

/**数据库名*/
static NSString *DBName = @"test.db";

/**表名*/
static NSString *tbName = @"t_student";

/**最新版本号*/
const int kDBVersion = 6;


@implementation FMDBTools
{
    
    FMDatabase *db;
    FMDatabaseQueue *queueDB;
    
}

#pragma mark - 单例
+ (FMDBTools *)sharedManager {
    static FMDBTools *DBTools;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        DBTools = [[FMDBTools alloc] init];
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentDirectory = [paths objectAtIndex:0];
        DBPath = [documentDirectory stringByAppendingPathComponent:DBName];
        NSLog(@"数据库路径:%@",DBPath);
        
    });
    return DBTools;
}

#pragma mark - 创建表
-(void)createTable {
    NSString *sql = @"create table if not exists t_student (id integer primary key autoincrement ,name text not null, phone text not null,score integer not null)";
    [self createTableWithSQL:sql];

}

- (void)createTableWithSQL:(NSString *)sql {
    db = [FMDatabase databaseWithPath:DBPath];
    //打开数据库
    if ([db open]) {
        BOOL result = [db executeUpdate:sql];
        if (result) {
            NSLog(@"create table success");
        }else {
            NSLog(@"create table error");
        }
        [db close];
    }else {
        db = nil;
        NSLog(@"db open fail");
    }
}

#pragma mark - 插入
- (void)insertWithName:(NSString *)name withPhone:(NSString *)phone withScore:(int)score{
    if (!db) {
        db = [FMDatabase databaseWithPath:DBPath];
    }
    //打开数据库
    if (![db open]) {
        db = nil;
        NSLog(@"db open fail");
        return;
    }
    NSString *sql = @"insert into t_student(name,phone,score) values(?,?,?)";
    BOOL result = [db executeUpdate:sql withArgumentsInArray:@[name,phone,[NSNumber numberWithInt:score]]];
    if (result) {
        NSLog(@"insertWithSQL success");
    }else {
        NSLog(@"insertWithSQL error");
    }
    [db close];
}

#pragma mark - 更新
-(void)updateWithName:(NSString *)name withPhone:(NSString *)phone {
    if (!db) {
        db = [FMDatabase databaseWithPath:DBPath];
    }
    //打开数据库
    if (![db open]) {
        db = nil;
        NSLog(@"db open fail");
        return;
    }
    NSString *sql = @"update t_student set phone = ? where name = ?";
    BOOL result = [db executeUpdate:sql withArgumentsInArray:@[phone,name]];
    if (result) {
        NSLog(@"update success");
    }else {
        NSLog(@"update error");
    }
    [db close];
}

#pragma mark - 删除
-(void)deleteWithName:(NSString *)name {
    if (!db) {
        db = [FMDatabase databaseWithPath:DBPath];
    }
    //打开数据库
    if (![db open]) {
        db = nil;
        NSLog(@"db open fail");
        return;
    }
    NSString *sql = @"delete from t_student where name = ?";
    BOOL result = [db executeUpdate:sql,name];
    if (result) {
        NSLog(@"delete success");
    }else {
        NSLog(@"delete error");
    }
    [db close];

}

#pragma mark - 查询
-(NSArray *)queryInfo {
    if (!db) {
        db = [FMDatabase databaseWithPath:DBPath];
    }
    //打开数据库
    if (![db open]) {
        db = nil;
        NSLog(@"db open fail");
        return nil;
    }

    NSString *sql = @"select * from t_student";
    FMResultSet *result = [db executeQuery:sql];
    NSMutableArray *arr = [NSMutableArray array];
    while ([result next]) {
        StudentInfo *student = [[StudentInfo alloc] init];
//        student.ID = [result intForColumn:@"ID"];
        student.name = [result stringForColumn:@"name"];
        student.phone = [result stringForColumn:@"phone"];
        student.score = [result intForColumn:@"score"];
        [arr addObject:student];
    }
    [db close];
    return arr;

}

#pragma mark - 事务操作时间短
-(void)handleTransactio {
    if (!db) {
        db = [FMDatabase databaseWithPath:DBPath];
    }
    //打开数据库
    if (![db open]) {
        db = nil;
        NSLog(@"db open fail");
        return;
    }
    //1.开启事务
    [db beginTransaction];
    NSDate *begin = [NSDate date];
    BOOL rollBack = NO;
    @try {
        //2.在事务中执行任务
        for (int i = 0; i< 500; i++) {
            NSString *name = [NSString stringWithFormat:@"text_%d",i];
            NSInteger age = i;
            NSString *phone = @"123456789101";
            
            BOOL result = [db executeUpdate:@"insert into t_student(name,phone,score) values(:name,:phone,:score)" withParameterDictionary:@{@"name":name,@"phone":phone,@"score":[NSNumber numberWithInteger:age]}];
            if (result) {
                NSLog(@"在事务中insert success");
            }
        }
    } @catch (NSException *exception) {
        //3.在事务中执行任务失败，退回开启事务之前的状态
        rollBack = YES;
        [db rollback];

    } @finally {
        //4. 在事务中执行任务成功之后
        rollBack = NO;
        [db commit];
    }
    NSDate *end = [NSDate date];
    NSTimeInterval time = [end timeIntervalSinceDate:begin];
    NSLog(@"在事务中执行插入任务 所需要的时间 = %f",time);
}


#pragma mark - 不是事务操作时间长
-(void)handleNotransaction {
    if (!db) {
        db = [FMDatabase databaseWithPath:DBPath];
    }
    //打开数据库
    if (![db open]) {
        db = nil;
        NSLog(@"db open fail");
        return;
    }
    NSDate *begin = [NSDate date];
    for (int i = 0; i< 500; i++) {
        NSString *name = [NSString stringWithFormat:@"text_%d",i];
        NSInteger age = i;
        NSString *phone = @"123456789101";
        
        BOOL result = [db executeUpdate:@"insert into t_student(name,phone,score) values(:name,:phone,:score)" withParameterDictionary:@{@"name":name,@"phone":phone,@"score":[NSNumber numberWithInteger:age]}];
        if (result) {
            NSLog(@"不在事务中insert success");
        }
    }
    
    NSDate *end = [NSDate date];
    NSTimeInterval time = [end timeIntervalSinceDate:begin];
    NSLog(@"不在事务中执行插入任务 所需要的时间 = %f",time);

}

#pragma mark - 线程安全 事务
-(void)queue_insertWithName:(NSString *)name withPhone:(NSString *)phone withScore:(int)score {
    queueDB = [FMDatabaseQueue databaseQueueWithPath:DBPath];
    [queueDB inTransaction:^(FMDatabase * _Nonnull db, BOOL * _Nonnull rollback) {
        NSString *sql = @"insert into t_student(name,phone,score) values(?,?,?)";
        BOOL result = [db executeUpdate:sql withArgumentsInArray:@[name,phone,[NSNumber numberWithInt:score]]];
        BOOL result2 = [db executeUpdate:sql withArgumentsInArray:@[name,phone,@60]];
        if (result && result2) {
            NSLog(@"update success");
        }else {
            NSLog(@"update error");
            *rollback = YES;
            return;
        }
    }];
    
}

#pragma mark - 线程安全
-(void)queue_updateWithName:(NSString *)name withPhone:(NSString *)phone {
    queueDB = [FMDatabaseQueue databaseQueueWithPath:DBPath];
    [queueDB inDatabase:^(FMDatabase * _Nonnull db) {
        NSString *sql = @"update t_student set phone = ? where name = ?";
        BOOL result = [db executeUpdate:sql withArgumentsInArray:@[phone,name]];
        if (result) {
            NSLog(@"update success");
        }else {
            NSLog(@"update error");
        }
        
    }];

}

#pragma mark - 数据库版本号
-(int)userVersion {
    int version = 0;
    if (!db) {
        db = [FMDatabase databaseWithPath:DBPath];
    }
    //打开数据库
    if ([db open]) {
        version = [db userVersion];
    }
    
    return version;
}

- (void)setUserVersion:(int)version {
    if (!db) {
        db = [FMDatabase databaseWithPath:DBPath];
    }
    //打开数据库
    if ([db open]) {
        [db setUserVersion:version];
    }
}

#pragma mark - 数据库升级
/**
 先把旧表重命名，再新建表，再把旧表数据复制到新表
 */
-(BOOL)upgrade {
    __block BOOL isSuccess = NO;
    int version = [self userVersion];
    if (kDBVersion > version) {
        if (!queueDB) {
            queueDB = [FMDatabaseQueue databaseQueueWithPath:DBPath];
        }
        
        [queueDB inDatabase:^(FMDatabase * _Nonnull db) {
        
            if ([db open]) {
                //先重命名表
                NSString *sql = [NSString stringWithFormat:@"alter table %@ rename to %@", tbName,
                                 [tbName stringByAppendingString:@"_old"]];
                BOOL result = [db executeUpdate:sql];
                
                if (result) {
                    //创建新的表
                    NSString *executeStr = [NSString stringWithFormat:@"create table if not exists %@ (id integer primary key autoincrement,name text not null, phone text not null,score integer not null,class Text)",tbName];


                    BOOL newTable = [db executeUpdate:executeStr];
                    if (newTable) {
                        // 从旧数据表把旧数据插入新的数据表中

                        NSString *insertSql = [NSString stringWithFormat:@"insert into %@ select * ,'' from %@", tbName, [tbName stringByAppendingString:@"_old"]];

                        BOOL copy = [db executeUpdate:insertSql];
                        if (copy) {
                            // 删除旧的数据表
                            [db executeUpdate:[NSString stringWithFormat:@"drop table %@", [tbName stringByAppendingString:@"_old"]]];

                            [db close];
                            isSuccess = YES;
                            [self setUserVersion:kDBVersion];
                        }
                    }
                    
                    
                }
            }
            [db close];

        }];
    }
    return isSuccess;
}

#pragma mark - 数据库升级 add column
-(BOOL)upgrade2 {
    __block BOOL isSuccess = NO;
    int version = [self userVersion];
    if (kDBVersion > version) {
        if (!queueDB) {
            queueDB = [FMDatabaseQueue databaseQueueWithPath:DBPath];
        }
        [queueDB inDatabase:^(FMDatabase * _Nonnull db) {
            if ([db open]) {
                NSString *new_column = @"new_column";
                if (![db columnExists:@"new_column" inTableWithName:tbName]) {
                    NSString *sql = [NSString stringWithFormat:@"alter table %@ add column %@ integer default 0",tbName,new_column];
                    BOOL result = [db executeUpdate:sql];
                    if (result) {
                        isSuccess = YES;
                        [self setUserVersion:kDBVersion];
                    }
                }
                
            }
            [db close];
        }];
    }
    return isSuccess;
}

@end
