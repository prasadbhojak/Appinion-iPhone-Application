#import <UIKit/UIKit.h>


@interface ActivityIndicator : NSObject {
	IBOutlet UIWindow *window;
	 
}

@property (nonatomic, readonly) UIWindow *window;
+ (ActivityIndicator *)sharedActivityIndicator;
//+ (ActivityIndicator *)sharedActivityIndicatorWithKey:(NSString *)key;
- (void)show;
- (void)hide;

@end
