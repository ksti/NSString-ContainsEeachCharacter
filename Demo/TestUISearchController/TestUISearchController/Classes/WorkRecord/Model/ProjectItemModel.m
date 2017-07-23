//
//  ProjectItemModel.m
//  eForp
//
//  Created by G on 2017/7/14.
//
//

#import "ProjectItemModel.h"

@implementation ProjectItemModel

- (instancetype)init
{
    self = [super init];
    if (self) {
        //
    }
    return self;
}

- (instancetype)initWithDict:(NSDictionary *)dict
{
    self = [super init];
    if (self) {
        //
        self.itemID = dict[@"itemID"];
        self.itemName = dict[@"itemName"];
    }
    return self;
}

@end
