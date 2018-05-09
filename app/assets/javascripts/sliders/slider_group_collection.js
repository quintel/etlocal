/*globals SliderGroup*/

var SliderGroupCollection = (function () {
    'use strict';

    SliderGroupCollection.prototype = {
        render: function (group) {
            var sliderGroups = this.sliderGroups.filter(function (el) {
                return el.key === group;
            });

            if (sliderGroups.length > 0) {
                sliderGroups.forEach(function (sliderGroup) {
                    sliderGroup.render();
                    sliderGroup.setFlexSlider();
                }.bind(this));
            }
        }
    };

    function SliderGroupCollection(datasetId) {
        this.datasetId    = datasetId;
        this.scope        = $('.group.slider-group');
        this.sliderGroups = $.map(this.scope, function (scope) {
            return new SliderGroup(scope);
        });
    }

    return SliderGroupCollection;
}());
