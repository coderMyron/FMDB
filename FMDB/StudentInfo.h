//
//  StudentInfo.h
//  FMDB
//
//  Created by Myron on 2019/8/17.
//  Copyright © 2019 Myron. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface StudentInfo : NSObject

@property(nonatomic,strong) NSString *name;
@property(nonatomic,strong) NSString *phone;
@property(nonatomic,assign) int score;

@end

NS_ASSUME_NONNULL_END
