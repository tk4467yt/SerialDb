//
//  SerialDb.m
//  SerialDbDemo
//
//  Created by kingsoft on 2019/1/3.
//  Copyright © 2019 kingsoft. All rights reserved.
//

#import "SerialDb.h"

@interface SerialDb ()

@end

@implementation SerialDb
+(BOOL)initDbFileWithinDocumentsWithName:(NSString *)dbFileName
{
    BOOL retFlag = TRUE;
    
    NSArray *documentDirectories = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                                       NSUserDomainMask,
                                                                       YES);
    NSString *directory = [documentDirectories objectAtIndex:0];
    NSString * commonDbPath = [directory stringByAppendingPathComponent:[NSString stringWithFormat:@".%@",dbFileName]];
    FMDatabase *dbCreated = [FMDatabase databaseWithPath:commonDbPath];
    if (nil == dbCreated) {
        NSLog(@"Initialized database at %@ failed", dbFileName);
        retFlag = FALSE;
    } else {
        if ([dbCreated open]) {
            NSLog(@"Opened database at %@", dbFileName);
        } else {
            NSLog(@"Open database at %@ failed", dbFileName);
            dbCreated = nil;
            retFlag = FALSE;
        }
    }
    
    return retFlag;
}
@end
