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

    function addClickListenerToAnalyzesButton() {
        $(".apply button.run_analyzes").off("click").on("click", function (e) {
            e.preventDefault();

            DatasetInterface.Analyzer.analyze(this);
        });
    }

    function addClickToBackButton() {
        $(".overview .buttons button.back")
            .off("click").on("click", function (e) {
                e.preventDefault();

                $(".content.tab#overview").hide();
                $(".content.tab#input").show();
            });
    }

    return {
        enableAnalyzesTab: function () {
            new Tab($(".nav#overview-nav")).enable();

            $(".content.tab#overview").show();
            $(".content.tab#input").hide();

            addClickToBackButton.call(this);
        },

        enable: function (geoId) {
            var sliderGroupCollection = new SliderGroupCollection(),
                localSettings = new LocalSettings(geoId);

            this.tab = new Tab(
                $(".nav#input-nav"),
                sliderGroupCollection.render.bind(sliderGroupCollection)
            ).enable();

            addChangeListenerToInputs.call(this);
            addClickListenerToToggles.call(this);
            addClickListenerToAnalyzesButton.call(this);
            addClickListenerToHistory.call(this);
            addClickListenerToInfo.call(this);
        }
    };
}());
