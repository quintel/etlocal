var SliderGroup = (function () {
    'use strict';

    SliderGroup.prototype = {
        render: function () {
            var controls;
            var balancer;

            this.sliders = $.map($(this.scope).find('.editable.slider'), function (scope) {
                return new Slider(scope);
            });

            controls = this.sliders.map(function(slider) {
                return slider.create();
            });

            if (this.isFlexGroup()) {
                balancer = new $.Quinn.Balancer();
                controls.forEach(balancer.add.bind(balancer));

                // Update the value for each slider in the group; this is needed
                // to ensure that default slider values -- which may contain
                // many decimal places -- are replaced with rounded versions,
                // ensuring the group still sums to 100%.
                balancer.on('change', function() {
                    // There are no subordinates when the event is fired after
                    // the user stops dragging the slider. That's fine: the
                    // group will have been set correctly by the previous
                    // invocation of the callback.
                    if (balancer.subordinates) {
                        balancer.subordinates.forEach(function(slider) {
                            slider.setValue(slider.model.value, false, true);
                        });
                    }
                });

                this.setFlexSlider();
            }
        },

        isFlexGroup: function() {
            return this.sliders.length > 1 &&
                this.sliders.some(function(slider) { return slider.flexible });
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
