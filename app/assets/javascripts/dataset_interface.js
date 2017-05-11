var DatasetInterface = (function () {
    'use strict';

    function addChangeListenerToInputs() {
        $("div.input span.val input[type='text']").on("change", function () {
            FormEnabler.enable(this);
        });
    }

    function addClickListenerToHistory() {
        var key;

        $("div.input span.history").on("click", function () {
            key = $(this).data('key');

            $("div.history." + key).toggleClass("hidden");
        });
    }

    DatasetInterface.prototype = {
        enable: function () {
            var sliderGroupCollection = new SliderGroupCollection();

            this.tab = new Tab($("ul.tab-nav"),
                new LocalSettings(this.geoId),
                sliderGroupCollection.render.bind(sliderGroupCollection)
            ).enable();

            addChangeListenerToInputs.call(this);
            addClickListenerToHistory.call(this);
            addSliders.call(this);
        }
    }

    function DatasetInterface(geoId) {
        this.geoId = geoId
    };

    return DatasetInterface;
}());
