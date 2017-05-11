var SliderGroup = (function () {
    'use strict';

    SliderGroup.prototype = {
        render: function () {
            var balancer = new $.Quinn.Balancer();

            this.sliders = $.map($(this.scope).find('.editable.slider'), function (scope) {
                return new Slider(scope);
            });

            this.sliders.forEach(function (slider) {
                balancer.add(slider.create());
            });
        },

        updateSliderDefaults: function (defaults) {
            this.sliders.forEach(function (slider) {
                if (slider.input.val() === "") {
                    slider.slider.setValue(defaults[slider.key].default * 100);
                }
            });
        }
    };

    function SliderGroup(scope) {
        this.scope = scope;
        this.key   = $(this.scope).data('tab');
    }

    return SliderGroup;
}());
