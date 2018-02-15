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
                window.DatasetInterface.ChangeTrigger.trigger(e.target);
                $(e.target).setConvertedValue();
            });
    }

    function addClickListenerToHistory() {
        $("div.input span.history").off("click").on("click", function () {
            $("div.history." + $(this).data('key')).toggleClass("hidden");
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
        var key,
            converted,
            displayInput,
            span,
            readOnly,
            defaultVal,
            defaults = this.defaults;

        $.when(defaults.fetch()).done(function () {
            tab.find('.editable').each(function () {
                span         = $(this).find('span.val');
                displayInput = span.find('input.display_input');
                readOnly     = span.find('.read-only');
                defaultVal   = defaults.data[$(this).data('key')];
                converted    = Converter.convertRounded.call(span, defaultVal);

                if (defaultVal) {
                    if (displayInput.length > 0) {
                        displayInput.attr('placeholder', converted);
                    }

                    if (readOnly.length > 0) {
                        readOnly.text(converted);
                    }
                }
            });
        });
    }

    function switchTab(group, tab) {
        setDefaultsForTab.call(this, tab);

        this.sliderGroupCollection.render(group);
    }

    function loadValues() {
        var value;

        $('input.value_input').each(function () {
            value = $(this).val();

            if (value) {
                $(this).prev(".display_input").val(
                    Converter.convertRounded.call(this, value)
                );
            }
        });
    }

    DatasetInterface.prototype = {
        enable: function () {
            this.tab = new Tab(
                $(".nav#input-nav"),
                switchTab.bind(this),
                this.localSettings
            ).enable();

            loadValues.call(this);
            addClickListenerToDownloadDataset.call(this);
            addChangeListenerToInputs.call(this);
            addClickListenerToToggles.call(this);
            addClickListenerToValidateButton.call(this);
            addClickListenerToHistory.call(this);
        }
    }

    function DatasetInterface(datasetId) {
        this.datasetId             = datasetId;
        this.localSettings         = new LocalSettings(datasetId);
        this.defaults              = new GraphDefaults(datasetId);
        this.sliderGroupCollection = new SliderGroupCollection(datasetId, this.defaults);
    }

    return {
        enable: function (datasetId) {
            var datasetInterface = new DatasetInterface(datasetId);

            datasetInterface.enable();

            return datasetInterface;
        }
    };
}());
