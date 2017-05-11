var SliderGroup = (function () {
    'use strict';

    SliderGroup.prototype = {
        render: function () {
            var balancer = new $.Quinn.Balancer();

            this.sliders = $.map($(this.scope).find('.editable.slider'), function (scope) {
                return new Slider(scope).create();
            });

            this.sliders.forEach(function (slider) {
                balancer.add(slider);
            });
        }
    };

    function SliderGroup(scope) {
        this.scope = scope;
        this.key   = $(this.scope).data('tab');
    }

    return SliderGroup;
}());
