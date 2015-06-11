//
//  ZXUPCEWriter.m
//  TiEncode
//
//  Created by 明陈 on 1/21/14.
//  Copyright (c) 2014 sencloud. All rights reserved.
//

#import "ZXUPCEWriter.h"
#import "ZXErrors.h"
#import "ZXUPCEReader.h"
#import "ZXBoolArray.h"

@implementation ZXUPCEWriter

#define O_PATTERNS_LEN 10
#define O_PATTERNS_SUB_LEN 4

const int O_PATTERNS[O_PATTERNS_LEN][O_PATTERNS_SUB_LEN] = {
    { 3, 2, 1, 1 },
    { 2, 2, 2, 1 },
    { 2, 1, 2, 2 },
    { 1, 4, 1, 1 },
    { 1, 1, 3, 2 },
    { 1, 2, 3, 1 },
    { 1, 1, 1, 4 },
    { 1, 3, 1, 2 },
    { 1, 2, 1, 3 },
    { 3, 1, 1, 2 } };

#define E_PATTERNS_LEN 10
#define E_PATTERNS_SUB_LEN 4

const int E_PATTERNS[E_PATTERNS_LEN][E_PATTERNS_SUB_LEN] = {
    { 1, 1, 2, 3 },
    { 1, 2, 2, 2 },
    { 2, 2, 1, 2 },
    { 1, 1, 4, 1 },
    { 2, 3, 1, 1 },
    { 1, 3, 2, 1 },
    { 4, 1, 1, 1 },
    { 2, 1, 3, 1 },
    { 3, 1, 2, 1 },
    { 2, 1, 1, 3 } };

#define PARITY_PATTERNS_LEN 10
#define PARITY_PATTERNS_SUB_LEN 6

const int PARITY_PATTERNS[PARITY_PATTERNS_LEN][PARITY_PATTERNS_SUB_LEN] = {
    { 'E', 'E', 'E', 'O', 'O', 'O' },
    { 'E', 'E', 'O', 'E', 'O', 'O' },
    { 'E', 'E', 'O', 'O', 'E', 'O' },
    { 'E', 'E', 'O', 'O', 'O', 'E' },
    { 'E', 'O', 'E', 'E', 'O', 'O' },
    { 'E', 'O', 'O', 'E', 'E', 'O' },
    { 'E', 'O', 'O', 'O', 'E', 'E' },
    { 'E', 'O', 'E', 'O', 'E', 'O' },
    { 'E', 'O', 'E', 'O', 'O', 'E' },
    { 'E', 'O', 'O', 'E', 'O', 'E' } };


#define END_PATTERN_LEN 6

const int END_PATTERN[END_PATTERN_LEN] = { 1, 1, 1, 1, 1, 1 };

#define codeWidth 65

- (ZXBitMatrix *)encode:(NSString *)contents format:(ZXBarcodeFormat)format width:(int)width height:(int)height error:(NSError **)error {
    return [self encode:contents format:format width:width height:height hints:nil error:error];
}

- (ZXBoolArray *)encode:(NSString *)contents length:(int *)pLength {
    
    if (contents.length == 8){
        contents = [contents substringFromIndex:1];
    }
    
    if (contents.length != 7) {
        @throw [NSException exceptionWithName:NSInvalidArgumentException
                                       reason:[NSString stringWithFormat:@"Requested contents should be 7 digits long, but got %lu", (unsigned long)contents.length]
                                     userInfo:nil];
    }
    else
    {
        if (pLength) *pLength = codeWidth;
      
        ZXBoolArray *result = [[ZXBoolArray alloc] initWithLength:codeWidth];
      
//        BOOL *result = (BOOL *)malloc(codeWidth * sizeof(BOOL));
        int pos = 0;
        
        int wideWhite[] = {7};
        NSLog(@"pos is %d", pos);
        pos += [super appendPattern:result pos:pos pattern:wideWhite patternLen:1 startColor:FALSE];
        NSLog(@"pos is %d", pos);
        pos += [super appendPattern:result pos:pos pattern:(int *)ZX_UPC_EAN_START_END_PATTERN patternLen:ZX_UPC_EAN_START_END_PATTERN_LEN startColor:TRUE];
        NSLog(@"pos is %d", pos);
        
        int parity = [[contents substringWithRange:NSMakeRange(6, 1)] intValue];
        
        for (int i = 0; i < 6; i++) {
            int digit = [[contents substringWithRange:NSMakeRange(i, 1)] intValue];
            if (PARITY_PATTERNS[parity][i] == 'O'){
                NSLog(@"zero pos is %d", pos);
                pos += [super appendPattern:result pos:pos pattern:(int *)O_PATTERNS[digit] patternLen:4 startColor:FALSE];
            }
            else {
                NSLog(@"unzero pos is %d", pos);
                pos += [super appendPattern:result pos:pos pattern:(int *)E_PATTERNS[digit] patternLen:4 startColor:FALSE];
            }
        }
        
        NSLog(@"unzero pos is %d", pos);
        pos += [super appendPattern:result pos:pos pattern:(int *)END_PATTERN patternLen:END_PATTERN_LEN startColor:FALSE];
        NSLog(@"unzero pos is %d", pos);
        pos += [super appendPattern:result pos:pos pattern:wideWhite patternLen:1 startColor:0];
        NSLog(@"unzero pos is %d", pos);
        
        NSMutableString* total = [[NSMutableString alloc] init];
        
        for (int i = 0; i < 65; i++) {
            [total appendFormat:@"%d", result.array[i]];
        }
        
        NSLog(@"%@", total);
        
        return result;
    }
}

@end
