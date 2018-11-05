#ifndef EVRYPickerInputHandler_h
#define EVRYPickerInputHandler_h

// Based on: https://github.com/DickyT/react-native-textinput-utils/tree/master/RCTTextInputUtils

#if __has_include(<React/RCTBridgeModule.h>)
#import <React/RCTBridgeModule.h>
#import <React/RCTEventEmitter.h>
#else
#import "RCTBridgeModule.h"
#import "RCTEventEmitter.h"
#endif

#import <UIKit/UIKit.h>

@interface WNRPickerInput : RCTEventEmitter <RCTBridgeModule>
@end

#endif
