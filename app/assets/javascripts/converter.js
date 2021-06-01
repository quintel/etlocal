var Converter = (function (){
    'use strict';

    function roundToPrecision(value, precision) {
        var multiple = Math.pow(10, precision || 2)
        return Math.round(value * multiple) / multiple;
    }

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

        convertRounded: function (value, precision) {
            var data = $(this).data();

            if (data.from === data.to) {
                return roundToPrecision(value, precision);
            } else {
                return roundToPrecision(
                    new Quantity(value, data.to).to(data.from).value,
                    precision
                );
            }
        }
    }
}());
