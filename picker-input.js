import React, {Component} from 'react';
import ReactNative, {Picker} from 'react-native';
import PickerInputIos from './picker-input-ios';

export default function PickerInput(props) {
    if (ReactNative.Platform.OS === 'ios') {
        return <PickerInputIos {...props} caretHidden/>;
    } else {
        let style = props.style;
        delete style.fontFamily;
        delete style.fontWeight;
        delete style.fontSize;
        return (
            <Picker {...props} style={style} options={null} value={null} onChange={null} selectedValue={props.value} onValueChange={props.onChange} mode="dropdown">
                {props.options.map(function (option) {
                    return <Picker.Item key={option.value || option.label} {...option} />;
                })}
            </Picker>
        );
    }
}
