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

        setFlexSlider: function () {
            var flexibleSlider,
                flex = 1.0;

            this.sliders.forEach(function (slider) {
                if (slider.flexible) {
                    flexibleSlider = slider;
                }

                if (!slider.flexible && slider.isEnabled()) {
                    flex -= slider.input.val();
                }
            });

            flexibleSlider.setDefaultValue(flex);
        }
    };

    function SliderGroup(scope) {
        this.scope = scope;
        this.key   = $(this.scope).parents('.group.tab').data('tab');
    }

    return SliderGroup;
}());
