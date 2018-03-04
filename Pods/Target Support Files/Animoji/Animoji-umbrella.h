#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "Animoji.h"
#import "AnimojiView.h"
#import "AVTAvatarInstance.h"
#import "AVTAvatarView.h"
#import "AVTPuppet.h"
#import "AVTPuppetView.h"

FOUNDATION_EXPORT double AnimojiVersionNumber;
FOUNDATION_EXPORT const unsigned char AnimojiVersionString[];

