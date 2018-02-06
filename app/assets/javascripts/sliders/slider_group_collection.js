/*globals GraphDefaults,SliderGroup*/

var SliderGroupCollection = (function () {
    'use strict';

    function setDefaults(sliderGroup) {
        $.when(GraphDefaults.fetch(this.datasetId)).done(function () {
            sliderGroup.updateSliderDefaults(
                GraphDefaults.defaults
            );
        });
    }

    SliderGroupCollection.prototype = {
        render: function (group) {
            var sliderGroups = this.sliderGroups.filter(function (el) {
                return el.key === group;
            });

            if (sliderGroups.length > 0) {
                sliderGroups.forEach(function (sliderGroup) {
                    sliderGroup.render();
                    setDefaults.call(this, sliderGroup);
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
