#import <UIKit/UIKit.h>

@interface UIReferenceLibraryViewController (DictGoogle)
- (id)modalHeaderView;
- (id)stringToDefine;
- (void)_dismissModalReferenceView:(id)button;
@end

@interface UIApplication (DictGoogle)
- (void)applicationOpenURL:(id)url;
@end

%hook UIReferenceLibraryViewController
- (void)viewDidLoad
{
  %orig;
  
  UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
  button.frame = CGRectMake(0, 0, 90, 48);
  NSString *pngPath = ([[UIScreen mainScreen] scale] == 2.0) ? @"/Applications/MobileSafari.app/UIButtonBarAction@2x.png" : @"/Applications/MobileSafari.app/UIButtonBarAction.png";
  UIImage *image = [[UIImage alloc] initWithContentsOfFile:pngPath];
  [button setImage:image forState:UIControlStateNormal];
  [button addTarget:self action:@selector(searchFromActionButton) forControlEvents:UIControlEventTouchUpInside];
  
  [[self modalHeaderView] addSubview:button];
  [image release];
}

%new(v@:)
- (void)searchFromActionButton
{
  NSMutableString *string = [[NSMutableString alloc] initWithString:@"x-web-search:///?"];
  
  [string appendFormat:@"%@", [[[self stringToDefine] copy] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
  [self _dismissModalReferenceView:nil];
  
  if ([[[NSBundle mainBundle] bundleIdentifier] isEqualToString:@"com.apple.mobilesafari"])
    [[UIApplication sharedApplication] applicationOpenURL:[NSURL URLWithString:string]];
  else
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:string]];
  
  [string release];
}
%end

/* vim: set filetype=objcpp textwidth=80 ff=unix: */
