var SliderGroupCollection = (function () {
    'use strict';

    SliderGroupCollection.prototype = {
        render: function (group) {
            var sliderGroup = this.sliderGroups.find(function (el) {
                return el.key === group;
            });

            if (sliderGroup) {
                sliderGroup.render();
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
