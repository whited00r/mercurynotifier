#import <Foundation/Foundation.h>
#import <CoreFoundation/CoreFoundation.h>
#import <CoreGraphics/CoreGraphics.h>
#import <UIKit/UIKit.h>
#import <Foundation/NSDistributedNotificationCenter.h>
#import <objc/runtime.h>
#import <substrate.h>

@interface BBBulletin : NSObject
- (id)sectionIconImageWithFormat:(int)format;
@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) NSString *message;
@property (nonatomic, retain) NSString *sectionID;
@end

@interface BBObserver

+ (void)initialize;
@end

@interface SBBulletinBannerController : NSObject
- (void)observer:(id)observer addBulletin:(id)bulletin forFeed:(int)feed;
+ (id)sharedInstance;
@end

@interface BBBulletinRequest : BBBulletin
@end


@implementation NSString (Localized)

-(NSString *)localizeForPath:(NSString*)path{

NSFileManager *fMgr = [NSFileManager defaultManager]; 
NSMutableDictionary *langDict;
if(!path){
if (![fMgr fileExistsAtPath:[NSString stringWithFormat:@"/var/mobile/Library/Mercury/Localization/%@.lproj/Mercury.strings", [[NSLocale preferredLanguages] objectAtIndex:0]]]) { 
langDict = [[NSMutableDictionary alloc] initWithContentsOfFile:[NSString stringWithFormat:@"/var/mobile/Library/Mercury/Localization/en.lproj/Mercury.strings"]];

}
else{
langDict = [[NSMutableDictionary alloc] initWithContentsOfFile:[NSString stringWithFormat:@"/var/mobile/Library/Mercury/Localization/%@.lproj/Mercury.strings", [[NSLocale preferredLanguages] objectAtIndex:0]]];

}
if([langDict objectForKey:self]){

return [langDict objectForKey:self];
}
else{
return self;
}
}
else{
if (![fMgr fileExistsAtPath:[NSString stringWithFormat:@"%@/%@.lproj/Mercury.strings", path, [[NSLocale preferredLanguages] objectAtIndex:0]]]) { 
return self;

}
else{
langDict = [[NSMutableDictionary alloc] initWithContentsOfFile:[NSString stringWithFormat:@"%@/%@.lproj/Mercury.strings", path, [[NSLocale preferredLanguages] objectAtIndex:0]]];

}
if([langDict objectForKey:self]){

return [langDict objectForKey:self];
}
else{
return self;
}
}
return self;
}

@end

@interface MercuryNotifier: NSObject <UIAlertViewDelegate>

-(void)handleNotification:(NSNotification*)notification;
@end



static BBBulletinRequest *updateBulletin;

@implementation MercuryNotifier
-(id)init{
	self = [super init];
	if(self){
		[[NSDistributedNotificationCenter defaultCenter] addObserver:self selector:@selector(handleNotification:) name:@"com.greyd00r.mercury.updateNotification" object:nil];
	}
	return self;
}


-(void)handleNotification:(NSNotification*)notification{

    NSLog(@"got event %@", notification);
    if([notification valueForKey:@"userInfo"]){
    	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    	NSLog(@"Notification has userInfo");
    	NSDictionary *userInfo = [notification valueForKey:@"userInfo"];
    	if([userInfo objectForKey:@"notificationType"]){
    		NSLog(@"UserInfo has notification type of %@", [userInfo objectForKey:@"notificationType"]);
    		if([[userInfo objectForKey:@"notificationType"] isEqualToString:@"updateNotification"]){
    			NSLog(@"UserInfo notification type was updateNotification");
    			if([userInfo objectForKey:@"identifier"]){

    				NSLog(@"MERCURYNOTIFIERDEBUG: Got update notification with info: %@ (%@) has %i updates available", [userInfo objectForKey:@"displayName"], [userInfo objectForKey:@"identifier"], [[userInfo objectForKey:@"componentUpdates"] intValue]);
    				//Class BBBulletinRequest = objc_getClass("BBBulletinRequest");
					//Class SBBulletinBannerController = objc_getClass("SBBulletinBannerController");
					/*
					BBBulletinRequest *request = [[[objc_getClass("BBBulletinRequest") alloc] init] autorelease];
					[request setTitle:[NSString stringWithFormat:@"Software Update Available"]];
					[request setMessage:[NSString stringWithFormat:@"%i updates are available for %@", [[userInfo objectForKey:@"componentUpdates"] intValue], [userInfo objectForKey:@"displayName"]]];
					[request setSectionID:@"com.greyd00r.mercuryupdater"];
					[[objc_getClass("SBBulletinBannerController") sharedInstance] observer:nil addBulletin:request forFeed:3];
					*/
					NSString *updateBody = [NSString stringWithFormat:[[NSString stringWithFormat:@"SOFTWARE_UPDATE_BODY"] localizeForPath:@"/var/mobile/Library/Mercury/Localization"], [[userInfo objectForKey:@"componentUpdates"] intValue], [userInfo objectForKey:@"displayName"]];
					NSString *updateTitle = [[NSString stringWithFormat:@"SOFTWARE_UPDATE_TITLE"] localizeForPath:@"/var/mobile/Library/Mercury/Localization"];
					if([[userInfo objectForKey:@"componentUpdates"] intValue] > 1){
						updateTitle = [[NSString stringWithFormat:@"SOFTWARE_UPDATE_TITLE_SINGLE"] localizeForPath:@"/var/mobile/Library/Mercury/Localization"];
						updateBody = [NSString stringWithFormat:[[NSString stringWithFormat:@"SOFTWARE_UPDATE_BODY_SINGLE"] localizeForPath:@"/var/mobile/Library/Mercury/Localization"], [[userInfo objectForKey:@"componentUpdates"] intValue], [userInfo objectForKey:@"displayName"]];
					}

					UIAlertView *alert = [[UIAlertView alloc] initWithTitle:updateTitle
                    message:updateBody
                    delegate:self 
                    cancelButtonTitle:@"Close"
                    otherButtonTitles:@"Open", nil];

		[alert show];
		[alert release];
/*

	id request = [[[%c(BBBulletinRequest) alloc] init] autorelease];
	BBObserver *observer = [[%c(BBObserver) alloc] init];
	//[observer initialize];
	[request setTitle:[NSString stringWithFormat:@"Software Update Available"]];


	[request setMessage:[NSString stringWithFormat:@"%i updates are available for %@", [[userInfo objectForKey:@"componentUpdates"] intValue], [userInfo objectForKey:@"displayName"]]];
	[request setSectionID: @"com.apple.Preferences"];
	//[request setClearable:FALSE];
	[request setDateIsAllDay:TRUE];
	[request setExpiresOnPublisherDeath:FALSE];
	//BBObserver *observer = [request firstValidObserver];
	[request setObserver:observer];

			[request setBulletinID:[userInfo objectForKey:@"identifier"]];
			[request setDate:[NSDate distantPast]];
			[request setLastInterruptDate:[NSDate date]];
	//[request setDefaultAction:[%c(BBAction) action]];

	id ctrl = [%c(SBBulletinBannerController) sharedInstance];



	NSLog(@"MERCURYNOTIFIERDEBUG: ctrl is %@", ctrl);
	
	[observer _registerBulletin:request withTransactionID:@"DEBUGGGYTHINGS"];
	//[ctrl observer:observer addBulletin:request forFeed:0];
	//[ctrl _reloadTableView];

*/

    		
}
}
   


    	}
    	[pool drain];
    }
}


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0)
    {
        //Code for OK button
    }
    if (buttonIndex == 1)
    {
        [[objc_getClass("SBUIController") sharedInstance] activateApplicationFromSwitcher:[[objc_getClass("SBApplicationController") sharedInstance] applicationWithDisplayIdentifier:@"com.greyd00r.mercury"]];
  
    }
}


@end

static MercuryNotifier *mNotifier;


%ctor{
	if(!mNotifier){
		mNotifier = [[MercuryNotifier alloc] init];
	}
	
}


