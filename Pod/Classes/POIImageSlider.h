//
//  POIImageSlider.h
//  Pods
//
//  Created by 陈婧婷 on 15/7/13.
//
//

#import <UIKit/UIKit.h>

@interface POIImageSlider : UIView
@property (strong,nonatomic) NSArray *imageData;

+ (NSString*)nibName;

-(void)setImageViewData:(NSArray *)imageData;
- (void)startAutoPagingWithDuration:(NSTimeInterval)pagingInterval;
@end
