//
//  WNRPickerInput.m
//
//  Created by Lucas Wiener on 2018-05-22.
//
// Based on: https://github.com/DickyT/react-native-textinput-utils/tree/master/RCTTextInputUtils

#import "RCTWNRPickerInput.h"
#import "React/RCTLog.h"
#import <React/RCTUIManager.h>
#import <RCTText/RCTBaseTextInputView.h>

#import <objc/runtime.h>

@interface KeyboardPicker : UIPickerView<UIPickerViewDataSource, UIPickerViewDelegate>

@property (nonatomic, retain) NSMutableArray* viewData;
@property (nonatomic, retain) id callbackObject;
@property (nonatomic, assign) SEL callbackSelector;

- (void)setCallbackObject:(id)anObject withSelector:(SEL)selector;

- (void)setData:(NSArray*)viewData;

@end

@implementation KeyboardPicker

- (id)init
{
    self = [super init];
    self.delegate = self;
    self.dataSource = self;
    
    self.viewData = [[NSMutableArray alloc]init];
    return self;
}

- (void)setCallbackObject:(id)anObject withSelector:(SEL)selector
{
    self.callbackObject = anObject;
    self.callbackSelector = selector;
}

- (void)setData:(NSArray*)viewData
{
    self.viewData = [[NSMutableArray alloc]initWithArray:viewData];
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return [self.viewData count];
}

- (NSString*)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    NSString *label = [[self.viewData objectAtIndex:row] objectForKey:@"label"];
    return label;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    [self.callbackObject performSelector:self.callbackSelector withObject:self];
#pragma clang diagnostic pop
}

@end

#pragma mark -

@implementation RCTWNRPickerInput

- (dispatch_queue_t)methodQueue {
    return [self.bridge.uiManager methodQueue];
}

RCT_EXPORT_MODULE();

- (NSArray<NSString *> *)supportedEvents
{
    return @[@"WNRKeyboardPickerViewDidSelected"];
}

RCT_EXPORT_METHOD(componentDidMount:(nonnull NSNumber*)reactNode options:(NSDictionary *)options) {
    [self.bridge.uiManager addUIBlock:^(__unused RCTUIManager *uiManager, NSDictionary<NSNumber *, UIView *> *viewRegistry ) {
        UIView *view = viewRegistry[reactNode];
        if (!view) {
            RCTLogError(@"RCTKeyboardToolbar: TAG #%@ NOT FOUND", reactNode);
            return;
        }
        
        UITextField *textField = (UITextField*)[((RCTBaseTextInputView*)view) backedTextInputView];
        
        NSNumber *_id = [RCTConvert NSNumber:options[@"id"]];
        NSArray *pickerData = [RCTConvert NSArray:options[@"pickerOptions"]];
        NSInteger selectedIndex = [[RCTConvert NSNumber:options[@"selectedIndex"]] integerValue];
        
        KeyboardPicker *pickerView = [[KeyboardPicker alloc] init];
        pickerView.tag = [_id intValue];
        [pickerView setCallbackObject:self withSelector:@selector(valueSelected:)];
        [pickerView setData:pickerData];
        [pickerView selectRow:selectedIndex inComponent:0 animated:NO];
        textField.inputView = pickerView; // This is what we wanted.
    }];
}

RCT_EXPORT_METHOD(componentWillReceiveProps:(nonnull NSNumber*)reactNode options:(NSDictionary *)options) {
    [self.bridge.uiManager addUIBlock:^(__unused RCTUIManager *uiManager, NSDictionary<NSNumber *, UIView *> *viewRegistry ) {
        UIView *view = viewRegistry[reactNode];
        if (!view) {
            RCTLogError(@"RCTKeyboardToolbar: TAG #%@ NOT FOUND", reactNode);
            return;
        }
        
        UITextField *textField = (UITextField*)[((RCTBaseTextInputView*)view) backedTextInputView];
        
        NSArray *pickerData = [RCTConvert NSArray:options[@"pickerOptions"]];
        NSInteger selectedIndex = [[RCTConvert NSNumber:options[@"selectedIndex"]] integerValue];
        
        KeyboardPicker *pickerView = (KeyboardPicker*)[textField inputView];
        [pickerView setData:pickerData];
        [pickerView reloadAllComponents];
        [pickerView selectRow:selectedIndex inComponent:0 animated:YES];
    }];
}

- (void)valueSelected:(KeyboardPicker*)sender
{
    NSNumber *selectedIndex = [NSNumber numberWithLong:[sender selectedRowInComponent:0]];
    NSNumber *_id = [NSNumber numberWithLong:sender.tag];
    [self sendEventWithName:@"WNRKeyboardPickerViewDidSelected" body:@{@"id" : _id, @"selectedIndex": selectedIndex}];
}

@end
