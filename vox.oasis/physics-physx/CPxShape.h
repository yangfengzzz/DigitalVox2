//
//  CPxShape.h
//  DigitalVox2
//
//  Created by 杨丰 on 2021/10/28.
//

#ifndef CPxShape_h
#define CPxShape_h

#import <Foundation/Foundation.h>
#import "CPxGeometry.h"

@interface CPxShape : NSObject

- (void)setFlags:(uint8_t)inFlags;

- (void)setQueryFilterData:(uint32_t)w0 w1:(uint32_t)w1 w2:(uint32_t)w2 w3:(uint32_t)w3;

- (void)setGeometry:(CPxGeometry *)geometry;

@end

#endif /* CPxShape_h */
