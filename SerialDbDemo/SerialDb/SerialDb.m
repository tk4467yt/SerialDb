//
//  SerialDb.m
//  SerialDbDemo
//
//  Created by kingsoft on 2019/1/3.
//  Copyright © 2019 kingsoft. All rights reserved.
//

#import "SerialDb.h"

static dispatch_queue_t serialDbQueue;

@interface SerialDb ()
@property (nonatomic, strong) NSMutableDictionary *dbContentDict;
@end

@implementation SerialDb
+(SerialDb *)sharedInstance
{
    static SerialDb *sharedDb=nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        serialDbQueue = dispatch_queue_create("serial_db_queue", DISPATCH_QUEUE_SERIAL);
        
        sharedDb = [SerialDb new];
        
        sharedDb.dbContentDict = [NSMutableDictionary new];
    });
    
    return sharedDb;
}

-(void)initDbFileWithinDocumentsWithName:(NSString *)dbFileName
{
    if (nil == dbFileName || ![dbFileName isKindOfClass:NSString.class] || dbFileName.length <= 0) {
        return;
    }
    
    dispatch_async(serialDbQueue, ^(){
        NSArray *documentDirectories = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                                           NSUserDomainMask,
                                                                           YES);
        NSString *directory = [documentDirectories objectAtIndex:0];
        NSString * commonDbPath = [directory stringByAppendingPathComponent:[NSString stringWithFormat:@".%@",dbFileName]];
        FMDatabase *dbCreated = [FMDatabase databaseWithPath:commonDbPath];
        if (nil == dbCreated) {
            NSLog(@"Initialized database at %@ failed", dbFileName);
        } else {
            if ([dbCreated open]) {
                NSLog(@"Opened database at %@ success", dbFileName);
                
                [[SerialDb sharedInstance].dbContentDict setObject:dbCreated forKey:dbFileName];
            } else {
                NSLog(@"Open database at %@ failed", dbFileName);
                dbCreated = nil;
            }
        }
    });
}

-(void)resetDbContent
{
    dispatch_async(serialDbQueue, ^(){
        NSArray *allKeys = [SerialDb sharedInstance].dbContentDict.allKeys;
        for (NSString *aFileKey in allKeys) {
            FMDatabase *aDbCreated=[[SerialDb sharedInstance].dbContentDict objectForKey:aFileKey];
            
            [aDbCreated close];
            
            NSLog(@"db %@ closed",aFileKey);
        }
        
        [[SerialDb sharedInstance].dbContentDict removeAllObjects];
    });
}
@end
