/*globals ChangeTrigger,GraphDefaults,LocalSettings,SliderGroupCollection,Tab*/

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

                DatasetInterface.ChangeTrigger.trigger(e.target);
            });
    }

    function addChangeListenerToInputs() {
        $("div.input span.val input[type='text']")
            .off("change")
            .on("change", function (e) {
                DatasetInterface.ChangeTrigger.trigger(e.target);
            });
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

    function addClickListenerToValidateButton() {
        $(".apply button[type=submit]").off("click").on("click", function () {
            $(this).find('img').show();
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

    function addClickListenerToDownloadDataset() {
        var button = $("button.button.download-dataset");

        button.off('click').on('click', function () {
            button.prop('disabled', true);

            $("form.download-dataset").submit();
        });
    }

    // This method set the default 'scaled NL' values for
    // attributes which were otherwise unknown.
    function setDefaultsForTab(tab) {
        var id, input;

        $.when(this.defaults).done(function () {
            tab.find('.editable').each(function () {
                id = $(this).data('key');
                input = $(this).find('input');

                if (!input.val()) {
                    input.attr('placeholder', GraphDefaults.defaults[id]);
                }
            });
        });
    }

    function switchTab(group, tab) {
        setDefaultsForTab.call(this, tab);

        this.sliderGroupCollection.render(group);
    }

    return {
        enableAnalyzesTab: function () {
            new Tab($(".nav#overview-nav")).enable();

            $(".content.tab#overview").show();
            $(".content.tab#input").hide();

            addClickToBackButton.call(this);
        },

        enable: function (datasetId) {
            var localSettings = new LocalSettings(datasetId);

            this.defaults = GraphDefaults.fetch(datasetId);
            this.sliderGroupCollection = new SliderGroupCollection(datasetId);
            this.tab = new Tab(
                $(".nav#input-nav"),
                switchTab.bind(this),
                localSettings
            ).enable();

            addClickListenerToDownloadDataset.call(this);
            addChangeListenerToInputs.call(this);
            addClickListenerToToggles.call(this);
            addClickListenerToValidateButton.call(this);
            addClickListenerToHistory.call(this);
            addClickListenerToInfo.call(this);
        }
    };
}());
