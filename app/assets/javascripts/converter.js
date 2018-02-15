var Converter = (function (){
    'use strict';

    return {
        reverseConvert: function (value) {
            var data = $(this).data();

            if (data.from === data.to) {
                return value;
            } else {
                return new Quantity(value, data.from).to(data.to).value;
            }
        },

        convert: function (value) {
            var data = $(this).data();

            if (data.from === data.to) {
                return value;
            } else {
                return new Quantity(value, data.to).to(data.from).value;
            }
        },

        convertRounded: function (value) {
            var data = $(this).data();

            if (data.from === data.to) {
                return value;
            } else {
                return new Quantity(value, data.to).to(data.from).roundedValue;
            }
        }
    }
}());
