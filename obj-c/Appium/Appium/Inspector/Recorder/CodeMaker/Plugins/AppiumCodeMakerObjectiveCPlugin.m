//
//  AppiumCodeMakerObjectiveCPlugin.m
//  Appium
//
//  Created by Dan Cuellar on 5/5/13.
//  Copyright (c) 2013 Appium. All rights reserved.
//

#import "AppiumCodeMakerObjectiveCPlugin.h"
#import "AppiumCodeMakerActions.h"

@interface AppiumCodeMakerObjectiveCPlugin ()

@property (readonly) NSString* indentation;

@end

@implementation AppiumCodeMakerObjectiveCPlugin

-(id) initWithCodeMaker:(AppiumCodeMaker*)codeMaker
{
	self = [super init];
    if (self) {
        [self setCodeMaker:codeMaker];
    }
    return self;
}

#pragma mark - AppiumCodeMakerPlugin Implementation
-(NSString*) name { return @"Objective-C"; }

-(NSString*) preCodeBoilerplateAndroid
{
    return [NSString stringWithFormat:@"#import <Selenium/SERemoteWebDriver.h>\n\
\n\
@implementation SeleniumTest\n\
\n\
-(void) run\n\
{\n\
\tSECapabilities *caps = [SECapabilities new];\n\
\t[caps setPlatform:@\"Mac\"];\n\
\t[caps setBrowserName:@\"\"];\n\
\t[caps setVersion:@\"4.2\"];\n\
\t[caps addCapabilityForKey:@\"device\" andValue:@\"Android\"];\n\
\t[caps addCapabilityForKey:@\"app\" andValue:@\"%@\"];\n\
\t[caps addCapabilityForKey:@\"app-package\" andValue:@\"%@\"];\n\
\t[caps addCapabilityForKey:@\"app-activity\" andValue:@\"%@\"];\n\
\tNSError *error;\n\
\tSERemoteWebDriver *wd = [[SERemoteWebDriver alloc] initWithServerAddress:@\"%@\" port:%@ desiredCapabilities:caps requiredCapabilities:nil error:&error];\n", self.model.appPath, self.model.androidPackage, self.model.androidActivity, self.model.ipAddress, self.model.port];
}

-(NSString*) preCodeBoilerplateiOS
{
    return [NSString stringWithFormat:@"#import <Selenium/SERemoteWebDriver.h>\n\
\n\
@implementation SeleniumTest\n\
\n\
-(void) run\n\
{\n\
\tSECapabilities *caps = [SECapabilities new];\n\
\t[caps setPlatform:@\"Mac\"];\n\
\t[caps setBrowserName:@\"iOS\"];\n\
\t[caps setVersion:@\"6.1\"];\n\
\t[caps addCapabilityForKey:@\"app\" andValue:@\"%@\"];\n\
\tNSError *error;\n\
\tSERemoteWebDriver *wd = [[SERemoteWebDriver alloc] initWithServerAddress:@\"%@\" port:%@ desiredCapabilities:caps requiredCapabilities:nil error:&error];\n", self.model.appPath, self.model.ipAddress, self.model.port];}

-(NSString*) postCodeBoilerplate
{
    return
@"}\n\
\n\
@end\n";
}

-(NSString*) acceptAlert
{
	return [NSString stringWithFormat:@"%@[wd acceptAlert];\n", self.indentation];
}

-(NSString*) comment:(AppiumCodeMakerActionComment*)action
{
	return [self commentWithString:action.comment];
}

-(NSString*) commentWithString:(NSString *)comment
{
	return [NSString stringWithFormat:@"%@// %@\n", self.indentation, comment];
}

-(NSString*) dismissAlert
{
	return [NSString stringWithFormat:@"%@[wd dismissAlert];\n", self.indentation];
}

-(NSString*) executeScript:(AppiumCodeMakerActionExecuteScript*)action
{
    return [NSString stringWithFormat:@"%@[wd executeScript:@\"%@\"];\n", self.indentation, [self escapeString:action.script]];
}

-(NSString*) preciseTap:(AppiumCodeMakerActionPreciseTap*)action
{
    NSDictionary *args = [((NSArray*)[action.params objectForKey:@"args"]) objectAtIndex:0];
    return [NSString stringWithFormat:@"\[wd executeScript:@\"mobile: tap\" arguments:\
[[NSArray alloc] initWithObjects:[[NSDictionary alloc] initWithObjectsAndKeys:\
[NSNumber numberWithInteger:%@, @\"tapCount\", \
[NSNumber numberWithInteger:%@, @\"touchCount\", \
[NSNumber numberWithFloat:%@f, @\"duration\", \
[NSNumber numberWithFloat:%@f, @\"x\", \
[NSNumber numberWithFloat:%@f, @\"y\", \
nil], nil]];\n", [args objectForKey:@"tapCount"], [args objectForKey:@"touchCount"], [args objectForKey:@"duration"], [args objectForKey:@"x"], [args objectForKey:@"y"]];
}

-(NSString*) sendKeys:(AppiumCodeMakerActionSendKeys*)action
{
	return [NSString stringWithFormat:@"%@[[wd findElementBy:%@] sendKeys:@\"%@\"];\n", self.indentation, [self locatorString:action.locator], [self escapeString:action.keys]];
}

-(NSString*) shake:(AppiumCodeMakerActionShake*)action
{
    return [NSString stringWithFormat:@"%@[wd executeScript:@\"mobile: shake\"];\n", self.indentation];
}

-(NSString*) swipe:(AppiumCodeMakerActionSwipe*)action
{
    NSDictionary *args = [((NSArray*)[action.params objectForKey:@"args"]) objectAtIndex:0];
    return [NSString stringWithFormat:@"\[wd executeScript:@\"mobile: swipe\" arguments:\
[[NSArray alloc] initWithObjects:[[NSDictionary alloc] initWithObjectsAndKeys:\
[NSNumber numberWithInteger:%@, @\"touchCount\", \
[NSNumber numberWithFloat:%@f, @\"startX\", \
[NSNumber numberWithFloat:%@f, @\"startY\", \
[NSNumber numberWithFloat:%@f, @\"endX\", \
[NSNumber numberWithFloat:%@f, @\"endY\", \
[NSNumber numberWithFloat:%@f, @\"duration\", \
nil], nil]];\n", [args objectForKey:@"touchCount"], [args objectForKey:@"startX"], [args objectForKey:@"startY"], [args objectForKey:@"endX"], [args objectForKey:@"endY"], [args objectForKey:@"duration"]];
}

-(NSString*) tap:(AppiumCodeMakerActionTap*)action
{
	return [NSString stringWithFormat:@"%@[[wd findElementBy:%@] click];\n", self.indentation, [self locatorString:action.locator]];
}

#pragma mark - Helper Methods
-(NSString*) escapeString:(NSString *)string
{
    return [string stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""];
}

-(NSString*) indentation { return [self.codeMaker.useBoilerPlate boolValue] ? @"\t" : @""; }

-(NSString*) locatorString:(AppiumCodeMakerLocator*)locator
{
	AppiumCodeMakerLocator *newLocator = [self.codeMaker.useXPathOnly boolValue] ? [[AppiumCodeMakerLocator alloc] initWithLocatorType:APPIUM_CODE_MAKER_LOCATOR_TYPE_XPATH locatorString:locator.xPath xPath:locator.xPath] : [locator copy];
	
	switch(newLocator.locatorType)
	{
		case APPIUM_CODE_MAKER_LOCATOR_TYPE_NAME:
			return [NSString stringWithFormat:@"[SEBY name:@\"%@\"]", [self escapeString:newLocator.locatorString]];
		case APPIUM_CODE_MAKER_LOCATOR_TYPE_XPATH:
			return [NSString stringWithFormat:@"[SEBY xPath:@\"%@\"]", [self escapeString:newLocator.locatorString]];
		default: return nil;
	}
}
@end
