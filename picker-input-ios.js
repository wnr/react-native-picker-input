// This component enables the use of Picker keyboards for TextInput, as described by iOS guidelines https://developer.apple.com/ios/human-interface-guidelines/controls/pickers/
// React Native does not currently support this, see https://github.com/facebook/react-native/issues/3551 and https://github.com/facebook/react-native/issues/5210
//
// Building upon https://github.com/DickyT/react-native-textinput-utils, the main idea is to:
//
// 1. Expose a picker-input buildingblock that renders a normal React Native TextInput buildingblock, passing along the props.
// 2. When the TextInput buildingblock is mounted, invoke a native singleton object "WNRPickerInputHandler" that:
// 2.a. Converts the given React TextInput reference to a UITextField pointer.
// 2.b. Creates a UIPickerView and feeds it with the data given in :picker-items props.
// 2.c. Register the UIPickerView to the .inputView property of the native UITextField screen.
// 2.d. Reigster callbacks to UI events.
//
// Since it is a singleton object, UIDs are needed to identify the inputs between each other.
// Callbacks are registered in a global state atom.

import React, {Component} from 'react';
import ReactNative, {TextInput, NativeModules, NativeEventEmitter} from 'react-native';

var pickerInputHandler = NativeModules.WNRPickerInput;
var pickerInputHandlerEventEmitter = new NativeEventEmitter(pickerInputHandler);

var counter = 1;

function isPropsEqual(props1, props2) {
    var items1 = props1.options;
    var items2 = props2.options;
    var value1 = props1.value;
    var value2 = props2.value;

    if (value1 !== value2) {
        return false;
    }

    var l1 = items1.length;
    var l2 = items2.length;
    var lmax = l1 > l2 ? l1 : l2;

    if (l1 !== l2) {
        return false;
    }

    for (var i = 0; i < lmax; i++) {
        var i1 = items1[i];
        var i2 = items2[i];
        if (i1.value !== i2.value || i1.label !== i2.label) {
            return false;
        }
    }

    return true;
}

function getSelectedIndex(props) {
    var index = props.options.map((p) => p.value).indexOf(props.value);
    return index === -1 ? 0 : index;
}

function getSelectedLabel(props) {
    for (var i = 0; i < props.options.length; i++) {
        var item = props.options[i];
        if (item.value === props.value) {
            return item.label;
        }
    }
    return null;
}

export default class PickerInputIos extends Component {
    constructor(props) {
        super(props);

        this._id = counter++;
    }

    componentDidMount() {
        var thisComponent = this;
        var props = thisComponent.props;
        var nodeHandle = ReactNative.findNodeHandle(this.refs.input);
        pickerInputHandler.componentDidMount(nodeHandle, {
            pickerOptions: props.options,
            id: thisComponent._id,
            selectedIndex: getSelectedIndex(props)
        });
        this._didSelectedSubscription = pickerInputHandlerEventEmitter.addListener('WNRKeyboardPickerViewDidSelected', function (data) {
            props = thisComponent.props;
            if (props.onChange) {
                if (data.id === thisComponent._id) {
                    props.onChange(props.options[data.selectedIndex].value);
                }
            }
        });
    }

    componentDidUpdate(prevProps) {
        var newProps = this.props;
        if (!isPropsEqual(prevProps, newProps)) {
            pickerInputHandler.componentWillReceiveProps(ReactNative.findNodeHandle(this.refs.input), {
                pickerOptions: newProps.options,
                selectedIndex: getSelectedIndex(newProps)
            });
        }
    }

    render() {
        var props = this.props;
        return <TextInput {...props} ref="input" value={getSelectedLabel(props)}/>;
    }

    componentWillUnmount() {
        this._didSelectedSubscription.remove();
    }
}
