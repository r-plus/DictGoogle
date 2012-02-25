#import <UIKit/UIKit.h>

#define DAIJIRIN_SCHEME @"mkdaijirin://jp.monokakido.DAIJIRIN/search?text="
#define WISDOM_SCHEME @"mkwisdom://jp.monokakido.WISDOM/search?text="
#define RUIGO_SCHEME @"mkruigo://jp.monokakido.RUIGO/search?text="
#define EOW_SCHEME @"eow://search?query="
#define EBPOCKET_SCHEME @"ebpocket://search?text="
#define GURUDIC_SCHEME @"gurudic:"
#define LONGMAN_EJ_SCHEME @"lejdict://"
#define POCKET_PROGRESSIVE_EJ_SCHEME @"pocketprogressivee://"
#define DICTIONARYCOM_SCHEME @"dcom://dictionary/"
#define LONGMAN_EE_SCHEME @"ldoce://"
#define KOTOBA_SCHEME @"kotoba://dictionary?search="
#define SAFARI_SCHEME @"x-web-search:///?"

//#define tweet

@interface UIReferenceLibraryViewController (DictGoogle)
- (id)modalHeaderView;
- (id)stringToDefine;
- (id)definitionHTML;
- (void)_dismissModalReferenceView:(id)button;
@end

@interface UIApplication (DictGoogle)
- (void)applicationOpenURL:(id)url;
@end

@interface DictHandler : NSObject <UIActionSheetDelegate,NSXMLParserDelegate> {
@private
  NSString *defineString;
  UIReferenceLibraryViewController *vc;
}
@property (nonatomic, copy) NSString *defineString;
@property (nonatomic, assign) UIReferenceLibraryViewController *vc;

- (void)searchFromActionButton:(NSString *)URLWithString;
#ifdef tweet
- (BOOL)composeTweet;
#endif
@end

#ifdef tweet
@interface TWTweetComposeViewController : UIViewController
@property (nonatomic, copy) id completionHandler;
- (BOOL)setInitialText:(NSString *)text;
@end

@interface UIWindow (forTweet)
+ (id)keyWindow;
- (id)_firstResponder;
@end

@interface UIApplication (forTweet)
- (int)activeInterfaceOrientation;
@end

static NSMutableString *resultString = [[NSMutableString alloc] init];
static NSInteger spanCount = 0;
static BOOL acceptAppend = NO;
#endif

%hook UIReferenceLibraryViewController
- (void)viewDidLoad
{
  %orig;
  
  UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
  button.frame = CGRectMake(0, 0, 90, 48);
  NSString *pngPath = ([[UIScreen mainScreen] scale] == 2.0) ? @"/Applications/MobileSafari.app/UIButtonBarAction@2x.png" : @"/Applications/MobileSafari.app/UIButtonBarAction.png";
  UIImage *image = [[UIImage alloc] initWithContentsOfFile:pngPath];
  [button setImage:image forState:UIControlStateNormal];
  [button addTarget:self action:@selector(showActionSheet) forControlEvents:UIControlEventTouchUpInside];
  
  [[self modalHeaderView] addSubview:button];
  [image release];
}

%new(v@:)
- (void)showActionSheet
{
  // NOTE: dh release last line.
  DictHandler *dh = [[DictHandler alloc] init];
#ifdef tweet
  NSLog(@"%@", [self definitionHTML]);
  NSData *data = [[self definitionHTML] dataUsingEncoding:NSUTF8StringEncoding];  
  NSXMLParser *parser = [[NSXMLParser alloc] initWithData:data];
  parser.delegate = dh;
	[parser parse];
#endif
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
  if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:DICTIONARYCOM_SCHEME]])
    [sheet addButtonWithTitle:@"Dictionary.com"];
  if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:LONGMAN_EE_SCHEME]])
    [sheet addButtonWithTitle:@"Longman EE"];
  if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:KOTOBA_SCHEME]])
    [sheet addButtonWithTitle:@"Kotoba"];
#ifdef tweet
  [sheet addButtonWithTitle:@"Twitter"];
#endif
  if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:SAFARI_SCHEME]])
    [sheet addButtonWithTitle:@"Google"];
  
  [sheet setAlertSheetStyle:UIBarStyleBlackTranslucent];
  [sheet setCancelButtonIndex:[sheet addButtonWithTitle:@"Cancel"]];
  if (sheet.numberOfButtons == 2)
    [dh searchFromActionButton:SAFARI_SCHEME];
  else
    [sheet showInView:self.view];
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
  if ([buttonTitle isEqualToString:@"Dictionary.com"])
    [self searchFromActionButton:DICTIONARYCOM_SCHEME];
  if ([buttonTitle isEqualToString:@"Longman EE"])
    [self searchFromActionButton:LONGMAN_EE_SCHEME];
  if ([buttonTitle isEqualToString:@"Kotoba"])
    [self searchFromActionButton:KOTOBA_SCHEME];
#ifdef tweet
  if ([buttonTitle isEqualToString:@"Twitter"])
    [self composeTweet];
#endif
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

#ifdef tweet
- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
  NSLog(@"foundChar='%@'", string);
  if (![string hasPrefix:@"\n"])
//  NSRange searchResult = [string rangeOfString@"\n"];
//  if (searchResult.length == 0)
//  if(searchResult.location == NSNotFound)
    if (acceptAppend)// && [string length] != 0  [NSCharacterSet whitespaceAndNewlineCharacterSet])
      [resultString appendString:string];
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{
  NSLog(@"-------[didStart]");
  NSLog(@"elementName=%@", elementName);
  NSLog(@"namespaceURI=%@", namespaceURI);
  NSLog(@"qName=%@", qName);
  NSLog(@"attributeDict=%@", attributeDict);
  if ([elementName isEqualToString:@"span"])
    spanCount++;
  
  //
  //NSLog(@"class====%@", [attributeDict objectForKey:@"class"]);
  NSString *className = [attributeDict objectForKey:@"class"];
  if (spanCount > 0
      && (
          [className isEqualToString:@"headword"] ||
          [className isEqualToString:@"表記"] ||
          [className isEqualToString:@"meaning"] ||
          [className isEqualToString:@"subheadword"] ||
          [className isEqualToString:@"label"] ||
          //      [className isEqualToString:@"slabel"] ||
          [className isEqualToString:@"note"] ||
          // for en-en
          [className isEqualToString:@"hw"] ||
          [className isEqualToString:@"gp tg_pos"] ||
          [className isEqualToString:@"pr"] ||
          [className isEqualToString:@"gg"] ||
          [className isEqualToString:@"df"] ||
          
          [className isEqualToString:@"gp ty_label tg_se2"] ||
          [className isEqualToString:@"df"] ||
          [className isEqualToString:@"gp tg_df"]
          )
      )
    acceptAppend = YES;
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
  NSLog(@"-------[didEnd]");
  NSLog(@"elementName=%@", elementName);
  NSLog(@"namespaceURI=%@", namespaceURI);
  NSLog(@"qName=%@", qName);
  
  if ([elementName isEqualToString:@"span"])
    spanCount--;
  if (spanCount < 1)
    acceptAppend = NO;
}

// Twitter code copied from activator. http://goo.gl/eHMIt
static TWTweetComposeViewController *tweetComposer;
static UIWindow *tweetWindow;
static UIWindow *tweetFormerKeyWindow;

- (void)hideTweetWindow
{
  tweetWindow.hidden = YES;
  [tweetWindow release];
  tweetWindow = nil;
}

- (BOOL)composeTweet
{ 
  tweetComposer = [[objc_getClass("TWTweetComposeViewController") alloc] init];
  if (!tweetComposer)
    return NO;
  if (tweetWindow)
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hideTweetWindow) object:nil];
  else
    tweetWindow = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
  tweetWindow.windowLevel = UIWindowLevelStatusBar;
  [tweetFormerKeyWindow release];
  tweetFormerKeyWindow = [[UIWindow keyWindow] retain];
  UIViewController *vct = [[UIViewController alloc] init];//ActivatorEmptyViewController
  //vct.interfaceOrientation = [(SpringBoard *)[UIApplication sharedApplication] activeInterfaceOrientation];
  tweetWindow.rootViewController = vct;

  NSLog(@"result=%@", resultString);
  [resultString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
  NSLog(@"-------length=%d", [resultString length]);
  if ([resultString length] > 128)
    //resultString = [resultString substringToIndex:126];
  //  [resultString deleteCharactersInRange:NSMakeRange(0, 1)];
    [resultString deleteCharactersInRange:NSMakeRange(128,[resultString length] - 128)];
  [resultString appendString:@" #dictgoogle"];
  NSLog(@"result=%@", resultString);
  
  [tweetComposer setInitialText:resultString];
  tweetComposer.completionHandler = ^(int result) {
    [[tweetWindow _firstResponder] resignFirstResponder];
    [tweetFormerKeyWindow makeKeyWindow];
    [tweetFormerKeyWindow release];
    tweetFormerKeyWindow = nil;
    [self performSelector:@selector(hideTweetWindow) withObject:nil afterDelay:0.5];
    [vct dismissModalViewControllerAnimated:YES];
    [tweetComposer release];
    tweetComposer = nil;
    [resultString deleteCharactersInRange:NSMakeRange(0,[resultString length])];
  };
  [tweetWindow makeKeyAndVisible];
  [vct presentModalViewController:tweetComposer animated:YES];
  [vct release];
  // release dh.
  [self release];
  self = nil;
  return YES;
}
#endif
@end
/* vim: set filetype=objc textwidth=80 ff=unix: */
