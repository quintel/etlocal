/*globals GraphDefaults,SliderGroup*/

var SliderGroupCollection = (function () {
    'use strict';

    function setDefaults(sliderGroup) {
        var defaults = this.defaults;

        $.when(defaults.fetch()).done(function () {
            sliderGroup.updateSliderDefaults(defaults.data);
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

    function SliderGroupCollection(datasetId, defaults) {
        this.defaults     = defaults;
        this.datasetId    = datasetId;
        this.scope        = $('.group.slider-group');
        this.sliderGroups = $.map(this.scope, function (scope) {
            return new SliderGroup(scope);
        });
    }

    return SliderGroupCollection;
}());
