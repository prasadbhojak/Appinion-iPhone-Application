#import "ActivityIndicator.h"
#import <QuartzCore/QuartzCore.h>


@implementation ActivityIndicator
@synthesize window;
static ActivityIndicator *activityIndicator;
UILabel *lblLoading;
- (id) init
{
	self = [super init];
	if (self != nil) {
		[[NSBundle mainBundle] loadNibNamed:@"ActivityIndicator" owner:self options:nil];
	}
	return self;
}

+ (ActivityIndicator *)sharedActivityIndicator 
{
	if (!activityIndicator)
	{	
		activityIndicator = [[ActivityIndicator alloc] init];
		activityIndicator.window.windowLevel = UIWindowLevelAlert;

		float originX=[[UIApplication sharedApplication] statusBarFrame].size.width/2.0;
		
		UIView *activityView = [[UIView alloc]initWithFrame:CGRectMake(abs(originX-80),220, 160, 40)];
		[activityView setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.5]];
		activityView.layer.cornerRadius = 10;
		[activityIndicator.window addSubview:activityView];	
		[activityView release];
		
		UIActivityIndicatorView *mainActivityIndicator = [[UIActivityIndicatorView alloc]initWithFrame:CGRectMake(activityView.frame.origin.x+10,230,20,20)];
		[mainActivityIndicator setHidesWhenStopped:YES];
		[activityIndicator.window addSubview:mainActivityIndicator];
		mainActivityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhite;
		[mainActivityIndicator startAnimating];
		[mainActivityIndicator release];
		
		
		//CGSize theSize = [Delegate.resultStr sizeWithFont:[UIFont boldSystemFontOfSize:12.0f] constrainedToSize:CGSizeMake(300.0, 6000.0) lineBreakMode:UILineBreakModeWordWrap];
		
		UILabel *lblLoading =[[UILabel alloc]initWithFrame:CGRectMake(mainActivityIndicator.frame.origin.x+mainActivityIndicator.frame.size.width+10,230,160,20)];
		[lblLoading setText:@"Loading ..."];
		[lblLoading setTextAlignment:UITextAlignmentLeft];
		[lblLoading setFont:[UIFont fontWithName:@"Helvetica" size:14]];
		lblLoading.font=[UIFont boldSystemFontOfSize:14];
		[lblLoading setTextColor:[UIColor whiteColor]];
		[lblLoading setBackgroundColor:[UIColor clearColor]];
		[activityIndicator.window addSubview:lblLoading];
		[lblLoading release];	
	}
	return activityIndicator;
}


- (void)show {
	[window makeKeyAndVisible];
	window.hidden = NO;
}

- (void)hide {
	[window resignKeyWindow];
	window.hidden = YES;
}

@end
