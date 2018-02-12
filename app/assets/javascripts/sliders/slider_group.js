var SliderGroup = (function () {
    'use strict';

    SliderGroup.prototype = {
        render: function () {
            this.balancer = new $.Quinn.Balancer();

            this.sliders = $.map($(this.scope).find('.editable.slider'), function (scope) {
                return new Slider(scope);
            });

            this.sliders.forEach(function (slider) {
                this.balancer.add(slider.create());
            }.bind(this));
        },

        updateSliderDefaults: function (defaults) {
            var flexibleSlider,
                value,
                oldValue,
                flex = 1.0;

            this.sliders.forEach(function (slider) {
                value    = defaults[slider.key];
                oldValue = slider.input.val() / 100.0;

                if (!slider.flexible) {
                    if (slider.isEdited()) {
                        flex -= oldValue
                    } else {
                        flex -= value;
                    }

                    slider.setDefaultValue(value * 100.0);
                } else {
                    flexibleSlider = slider;
                }
            });

            flexibleSlider.setDefaultValue(flex * 100.0);
        }
    };

    function SliderGroup(scope) {
        this.scope = scope;
        this.key   = $(this.scope).parents('.group.tab').data('tab');
    }

    return SliderGroup;
}());
