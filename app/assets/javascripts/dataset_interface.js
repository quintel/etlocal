/*globals ChangeTrigger,LocalSettings,SliderGroupCollection,Tab*/

var DatasetInterface = (function () {
    'use strict';

    function addClickListenerToToggles() {
        $("input[type='checkbox']")
            .on("click", function (e) {
                $(e.target)
                    .parent()
                    .find('.toggle-group')
                    .toggleClass('active', $(e.target).is(':checked'));

                DatasetInterface.ChangeTrigger.trigger(this);
            });
    }

    function addChangeListenerToInputs() {
        $("div.input span.val input[type='text']")
            .on("change", DatasetInterface.ChangeTrigger.trigger);
    }

    function addClickListenerToHistory() {
        $("div.input span.history").on("click", function () {
            $("div.history." + $(this).data('key')).toggleClass("hidden");
        });
    }

    function addClickListenerToInfo() {
        var key, left, information;

        $("div.input span.info").on("click", function () {
            key         = $(this).data('key');
            left        = $(this).position().left - 35;
            information = $("div.information." + key);

            information.toggleClass("hidden");
            information.find(".line-arrow").css({ left: left });
        });
    }

    return {
        enable: function (geoId) {
            var sliderGroupCollection = new SliderGroupCollection(),
                localSettings = new LocalSettings(geoId);

            this.tab = new Tab(
                $(".nav"),
                localSettings,
                sliderGroupCollection.render.bind(sliderGroupCollection)
            ).enable();

            addChangeListenerToInputs.call(this);
            addClickListenerToToggles.call(this);
            addClickListenerToHistory.call(this);
            addClickListenerToInfo.call(this);
        }
    };
}());
