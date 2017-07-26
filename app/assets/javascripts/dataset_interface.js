/*globals ChangeTrigger,LocalSettings,SliderGroupCollection,Tab*/

var DatasetInterface = (function () {
    'use strict';

    function addClickListenerToToggles() {
        $("input[type='checkbox']")
            .off("click")
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
            .off("change")
            .on("change", DatasetInterface.ChangeTrigger.trigger);
    }

    function addClickListenerToHistory() {
        $("div.input span.history").off("click").on("click", function () {
            $("div.history." + $(this).data('key')).toggleClass("hidden");
        });
    }

    function addClickListenerToInfo() {
        var key, left, information;

        $("div.input span.info").off("click").on("click", function () {
            key         = $(this).data('key');
            left        = $(this).position().left - 35;
            information = $("div.information." + key);

            information.toggleClass("hidden");
            information.find(".line-arrow").css({ left: left });
        });
    }

    function addClickListenerToBoxes() {
        $(".boxes strong[data-key]").off("click").on("click", function () {
            $(".box." + $(this).data('key')).toggleClass("open");
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
            addClickListenerToBoxes.call(this);
            addClickListenerToHistory.call(this);
            addClickListenerToInfo.call(this);
        }
    };
}());
