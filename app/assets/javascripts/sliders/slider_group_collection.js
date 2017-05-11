var SliderGroupCollection = (function () {
    'use strict';

    function setDefaults(sliderGroup) {
        $.when(SliderDefaults.fetch()).done(function () {
            sliderGroup.updateSliderDefaults(
                SliderDefaults.defaults[sliderGroup.key.replace('#', '')]
            );
        });
    }

    SliderGroupCollection.prototype = {
        render: function (group) {
            var sliderGroup = this.sliderGroups.find(function (el) {
                return el.key === group;
            });

            if (sliderGroup) {
                sliderGroup.render();
                setDefaults.call(this, sliderGroup);
            }
        }
    }

    function SliderGroupCollection () {
        this.scope        = $('.group.slider-group');
        this.sliderGroups = $.map(this.scope, function (scope) {
            return new SliderGroup(scope);
        });
    }

    return SliderGroupCollection;
}());
