#import <UIKit/UIKit.h>

#define DAIJIRIN_SCHEME @"mkdaijirin://jp.monokakido.DAIJIRIN/search?text="
#define WISDOM_SCHEME @"mkwisdom://jp.monokakido.WISDOM/search?text="
#define RUIGO_SCHEME @"mkruigo://jp.monokakido.RUIGO/search?text="
#define EOW_SCHEME @"eow://search?query="
#define EBPOCKET_SCHEME @"ebpocket://search?text="
#define GURUDIC_SCHEME @"gurudic:"
#define LONGMAN_EJ_SCHEME @"lejdict://"
#define POCKET_PROGRESSIVE_EJ_SCHEME @"pocketprogressivee://"
#define LONGMAN_EE_SCHEME @"ldoce://"
#define KOTOBA_SCHEME @"kotoba://dictionary?search="
#define SAFARI_SCHEME @"x-web-search:///?"

//#define DEBUG

@interface UIReferenceLibraryViewController (DictGoogle)
@property(readonly) NSString * stringToDefine;
@property(readonly) UIWebView * definitionView;
@property(readonly) UIView * definitionContainerView;
@property(readonly) UIView * modalHeaderView;
@property(readonly) NSString * stylesheet;
@property(retain) NSString * definitionHTML;
@property(copy) id dismissCompletionHandler;
@property(setter=_setRotationDecider:,retain) UIWindow * _rotationDecider;

- (id)stringToDefine;
- (id)definitionHTML;
- (void)_dismissModalReferenceView:(id)button;
@end

@interface UIApplication (DictGoogle)
- (void)applicationOpenURL:(id)url;
@end

@interface UIDevice (Private)
- (BOOL)isWildcat;
@end

@interface DictHandler : NSObject <UIActionSheetDelegate,NSXMLParserDelegate> {
@private
  NSString *defineString;
  UIReferenceLibraryViewController *vc;
}
@property (nonatomic, copy) NSString *defineString;
@property (nonatomic, assign) UIReferenceLibraryViewController *vc;

- (void)searchFromActionButton:(NSString *)URLWithString;
@end


%hook UIReferenceLibraryViewController
- (void)viewDidLoad
{
  %orig;
  
  UISwipeGestureRecognizer *horizonSwipeGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeToDismiss:)];
  horizonSwipeGesture.direction = (UISwipeGestureRecognizerDirection)(UISwipeGestureRecognizerDirectionLeft | UISwipeGestureRecognizerDirectionRight);
  [self.definitionContainerView addGestureRecognizer:horizonSwipeGesture];
  [horizonSwipeGesture release];
  
  UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
  CGRect rect = [[UIDevice currentDevice] isWildcat] ? CGRectMake(self.definitionContainerView.frame.size.width - 50, 0, 50, 50) : CGRectMake(0, 0, 90, 50);
  button.frame = rect;
  NSString *pngPath = ([[UIScreen mainScreen] scale] == 2.0) ? @"/Applications/MobileSafari.app/UIButtonBarAction@2x.png" : @"/Applications/MobileSafari.app/UIButtonBarAction.png";
  UIImage *image = [[UIImage alloc] initWithContentsOfFile:pngPath];
  [button setImage:image forState:UIControlStateNormal];
  [button addTarget:self action:@selector(showActionSheet:) forControlEvents:UIControlEventTouchUpInside];
  
#ifdef DEBUG
  NSLog(@"modalHeaderView = %@", self.modalHeaderView);
  NSLog(@"definitionContainerView = %@", self.definitionContainerView);
  NSLog(@"definitionView = %@", self.definitionView);
  NSLog(@"%@", [self.view recursiveDescription]);
#endif

  if ([[UIDevice currentDevice] isWildcat])
    [[self.definitionView.subviews objectAtIndex:0] addSubview:button];
  else
    [self.modalHeaderView addSubview:button];
  [image release];
}

%new(v@:)
- (void)swipeToDismiss:(id)swipeGesture
{
  [self _dismissModalReferenceView:nil];
}

%new(v@:@)
- (void)showActionSheet:(UIButton *)button
{
  // NOTE: dh release last line.
  DictHandler *dh = [[DictHandler alloc] init];
  dh.vc = self;
  dh.defineString = [self stringToDefine];
  UIActionSheet *sheet = [[[UIActionSheet alloc] initWithTitle:nil
                                                      delegate:dh
                                             cancelButtonTitle:nil
                                        destructiveButtonTitle:nil
                                             otherButtonTitles:nil]
                          autorelease];
  
  if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:DAIJIRIN_SCHEME]])
    [sheet addButtonWithTitle:@"Daijirin"];
  if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:WISDOM_SCHEME]])
    [sheet addButtonWithTitle:@"Wisdom"];
  if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:RUIGO_SCHEME]])
    [sheet addButtonWithTitle:@"Ruigo"];
  if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:EOW_SCHEME]])
    [sheet addButtonWithTitle:@"EOW"];
  if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:LONGMAN_EJ_SCHEME]])
    [sheet addButtonWithTitle:@"Longman EJ"];
  if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:POCKET_PROGRESSIVE_EJ_SCHEME]])
    [sheet addButtonWithTitle:@"Pocket Progressive"];
  if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:EBPOCKET_SCHEME]])
    [sheet addButtonWithTitle:@"EBPocket"];
  if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:GURUDIC_SCHEME]])
    [sheet addButtonWithTitle:@"Gurudic"];
  if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:LONGMAN_EE_SCHEME]])
    [sheet addButtonWithTitle:@"Longman EE"];
  if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:KOTOBA_SCHEME]])
    [sheet addButtonWithTitle:@"Kotoba"];
  if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:SAFARI_SCHEME]])
    [sheet addButtonWithTitle:@"Google"];
  
  [sheet setAlertSheetStyle:UIBarStyleBlackTranslucent];
  [sheet setCancelButtonIndex:[sheet addButtonWithTitle:@"Cancel"]];
  if (sheet.numberOfButtons == 2)
    [dh searchFromActionButton:SAFARI_SCHEME];
  else
    [sheet showInView:[[UIDevice currentDevice] isWildcat] ? [UIApplication sharedApplication].keyWindow : self.view];
}
%end

@implementation DictHandler
@synthesize defineString, vc;

- (void)actionSheet:(id)sheet clickedButtonAtIndex:(int)index
{
  NSString *buttonTitle = [sheet buttonTitleAtIndex:index];
  
  if ([buttonTitle isEqualToString:@"Daijirin"])
    [self searchFromActionButton:DAIJIRIN_SCHEME];
  if ([buttonTitle isEqualToString:@"Wisdom"])
    [self searchFromActionButton:WISDOM_SCHEME];
  if ([buttonTitle isEqualToString:@"Ruigo"])
    [self searchFromActionButton:RUIGO_SCHEME];
  if ([buttonTitle isEqualToString:@"EOW"])
    [self searchFromActionButton:EOW_SCHEME];
  if ([buttonTitle isEqualToString:@"Longman EJ"])
    [self searchFromActionButton:LONGMAN_EJ_SCHEME];
  if ([buttonTitle isEqualToString:@"Pocket Progressive"])
    [self searchFromActionButton:POCKET_PROGRESSIVE_EJ_SCHEME];
  if ([buttonTitle isEqualToString:@"EBPocket"])
    [self searchFromActionButton:EBPOCKET_SCHEME];
  if ([buttonTitle isEqualToString:@"Gurudic"])
    [self searchFromActionButton:GURUDIC_SCHEME];
  if ([buttonTitle isEqualToString:@"Longman EE"])
    [self searchFromActionButton:LONGMAN_EE_SCHEME];
  if ([buttonTitle isEqualToString:@"Kotoba"])
    [self searchFromActionButton:KOTOBA_SCHEME];
  if ([buttonTitle isEqualToString:@"Google"])
    [self searchFromActionButton:SAFARI_SCHEME];
}

- (void)searchFromActionButton:(NSString *)URLString
{
  NSString *string = [URLString stringByAppendingString:[defineString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
  [vc _dismissModalReferenceView:nil];
  
  if ([[[NSBundle mainBundle] bundleIdentifier] isEqualToString:@"com.apple.mobilesafari"])
    [[UIApplication sharedApplication] applicationOpenURL:[NSURL URLWithString:string]];
  else
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:string]];
  
  // release dh.
  [self release];
  self = nil;
}
@end
/* vim: set filetype=objc textwidth=80 ff=unix: */
