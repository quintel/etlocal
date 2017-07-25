var DatasetInterface = (function () {
    'use strict';

    function addClickListenerToToggles() {
        $("input[type='checkbox']")
            .on("click", function (e) {
                var openToggle = $(e.target).data('open');

                $(e.target)
                    .parent()
                    .find('.toggle-group')
                    .toggleClass('active', $(e.target).is(':checked'));

                FormEnabler.enable(this);
            });
    }

    function addChangeListenerToInputs() {
        $("div.input span.val input[type='text']")
            .on("change", FormEnabler.enable);
    }

    function addClickListenerToHistory() {
        var key, left, information;

        $("div.input span.history").on("click", function () {
            key = $(this).data('key');

            $("div.history." + key).toggleClass("hidden");
        });

        $("div.input span.info").on("click", function () {
            key         = $(this).data('key'),
            left        = $(this).position().left - 35, // 35 is the padding of the bounding box + the padding between the unit and the value
            information = $("div.information." + key);

            information.toggleClass("hidden");
            information.find(".line-arrow").css({ left: left });
        });
    }

    DatasetInterface.prototype = {
        enable: function () {
            var sliderGroupCollection = new SliderGroupCollection();

            this.tab = new Tab($(".nav"),
                new LocalSettings(this.geoId),
                sliderGroupCollection.render.bind(sliderGroupCollection)
            ).enable();

            addChangeListenerToInputs.call(this);
            addClickListenerToToggles.call(this);
            addClickListenerToHistory.call(this);
            addSliders.call(this);
        }
    }

    function DatasetInterface(geoId) {
        this.geoId = geoId
    };

    return DatasetInterface;
}());
