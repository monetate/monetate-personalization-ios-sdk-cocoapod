//
//  documentation.h
//  monetate-ios-sdk
//
//  Created by DJ on 9/6/18.
//  Copyright © 2018 Monetate. All rights reserved.
//

// This header file is used for generating documentation on all classes
// in the SDK, both public and private.  This header should only be
// used by Jazzy for generating INTERNAL documentation.  DO NOT include
// this header file as part of the normal SDK build process, and DO NOT
// reference it for anything other than generating Jazzy documentation.

#pragma mark - Framework Public Headers -
#import "monetate_ios_sdk.h"

#pragma mark - Framework Private Headers -

#pragma mark Primary Interfaces
#import "ActionManager.h"
#import "ApiService.h"
#import "Config.h"
#import "EventManager.h"
#import "Response.h"

#pragma mark Actions
#import "Action.h"
#import "ReplaceTextAction.h"

#import mark Action models
#import "ImpressionRecording.h"
