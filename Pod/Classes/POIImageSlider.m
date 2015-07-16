//
//  POIImageSlider.m
//  Pods
//
//  Created by 陈婧婷 on 15/7/13.
//
//

#import "POIImageSlider.h"
@interface POIImageSlider()<UIScrollViewDelegate>
@property (unsafe_unretained, nonatomic) IBOutlet UIScrollView *scrollView;
@property (unsafe_unretained, nonatomic) IBOutlet UIPageControl *pageControl;

@property (strong,nonatomic) UIImageView *leftImageView;
@property (strong,nonatomic) UIImageView *currentImageView;
@property (strong,nonatomic) UIImageView *rightImageView;

@property (strong,nonatomic) NSTimer     *timer;
@property (assign,nonatomic) NSTimeInterval pagingInterval;
@end
@implementation POIImageSlider

-(void)awakeFromNib{
    [super awakeFromNib];
    [self setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self setup];
}


+ (NSString*)nibName
{
    return NSStringFromClass([self class]);
}
-(void)setup{
    [self initScrollView];
    [self initImageView];
}
-(void)initScrollView{
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.showsVerticalScrollIndicator = NO;
    self.scrollView.pagingEnabled = YES;
    self.scrollView.scrollEnabled = YES;
    self.scrollView.bounces=NO;
    self.scrollView.delegate=self;
}
-(void)initImageView{
    self.leftImageView=[[UIImageView alloc] init];
    self.currentImageView=[[UIImageView alloc] init];
    self.rightImageView=[[UIImageView alloc] init];
    
    self.leftImageView.contentMode=UIViewContentModeScaleAspectFill;
    self.currentImageView.contentMode=UIViewContentModeScaleAspectFill;
    self.rightImageView.contentMode=UIViewContentModeScaleAspectFill;
    
    [self.scrollView addSubview:self.leftImageView];
    [self.scrollView addSubview:self.currentImageView];
    [self.scrollView addSubview:self.rightImageView];
    
}
-(void)setImageViewData:(NSArray *)imageData{
    self.imageData=imageData;
    
    self.leftImageView.tag=0;
    self.currentImageView.tag=1;
    self.rightImageView.tag=self.imageData.count-1;
    
    [self.leftImageView setImage:self.imageData[self.leftImageView.tag]];
    [self.currentImageView setImage: self.imageData[self.currentImageView.tag]];
    [self.rightImageView setImage: self.imageData[self.rightImageView.tag]];
}
-(void)layoutSubviews{
    [super layoutSubviews];
    
    CGFloat width=self.scrollView.bounds.size.width;
    CGFloat height=self.scrollView.bounds.size.height;
    
    self.leftImageView.frame=CGRectMake(0, 0, width, height);
    self.currentImageView.frame=CGRectMake(width, 0, width, height);
    self.rightImageView.frame=CGRectMake(width*2, 0, width, height);
    
    self.scrollView.contentSize=CGSizeMake(width*3, height);
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        // 启动程序后第一次执行子控件调整时，改变一次偏移量值，使其显示中间的UIImageView
        [self.scrollView setContentOffset:CGPointMake(width, 0)];
        
    });
}
#pragma mark - scroll view delegate
-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    CGFloat width=self.scrollView.frame.size.width;
    if (self.scrollView.contentOffset.x>width*1.5) {
        self.pageControl.currentPage=self.rightImageView.tag;
    }else if(self.scrollView.contentOffset.x<width*0.5){
        self.pageControl.currentPage=self.leftImageView.tag;
    }else{
        self.pageControl.currentPage=self.currentImageView.tag;
    }
    
}
-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    [self updateContent];
}
-(void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView{
    [self updateContent];
}
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    [self stopTimer];
}
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    [self startTimer];
}
#pragma mark - auto paging content display
-(void)updateContent{
    CGFloat width=self.scrollView.bounds.size.width;
    if (self.scrollView.contentOffset.x>width) {
        self.leftImageView.tag=self.currentImageView.tag;
        self.currentImageView.tag=self.rightImageView.tag;
        self.rightImageView.tag=(self.rightImageView.tag+1)%self.imageData.count;
    }
    if (self.scrollView.contentOffset.x<width) {
        self.rightImageView.tag=self.currentImageView.tag;
        self.currentImageView.tag=self.leftImageView.tag;
        self.leftImageView.tag=(self.imageData.count+self.leftImageView.tag-1)%self.imageData.count;
    }
    [self.leftImageView setImage:self.imageData[self.leftImageView.tag]];
    [self.currentImageView setImage: self.imageData[self.currentImageView.tag]];
    [self.rightImageView setImage: self.imageData[self.rightImageView.tag]];
    
    [self.scrollView setContentOffset:CGPointMake(width, 0) animated:NO];
}


/**
 * 以duration时间间隔，开启定时切换图片
 */
- (void)startAutoPagingWithDuration:(NSTimeInterval)pagingInterval
{
    // 先停止正在执行的定时器
    [self stopTimer];
    self.pagingInterval = pagingInterval;
    [self startTimer];
}
-(void)nextPage{
    if (self.scrollView.contentOffset.x!=0) {
        [self.scrollView setContentOffset:CGPointMake(CGRectGetWidth(self.scrollView.frame)*2,0) animated:YES];
    }
}
/**
 * 开启定时器
 */
- (void)startTimer
{
    // 注册定时器
    self.timer = [NSTimer timerWithTimeInterval:self.pagingInterval target:self selector:@selector(nextPage) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
}

/**
 * 关闭定时器
 */
- (void)stopTimer
{
    if (self.timer) {
        [self.timer invalidate];
        self.timer = nil;
    }
}


@end
