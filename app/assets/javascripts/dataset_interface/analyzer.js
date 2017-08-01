DatasetInterface.Analyzer = (function () {
    'use strict';

    function formAttributesToJSON(form) {
        var value,
            result = {},
            object = form.serializeObject();

        object.edits.dataset_edits_attributes.forEach(function (el) {
            if (/^has/.test(el.key)) {
                value = (el.value === '1');
            } else {
                value = parseFloat(el.value);
            }

            result[el.key] = value;
        });

        return JSON.stringify(result);
    }

    return {
        isRunning: false,
        analyze: function (el) {
            var form = $("form.dataset_editor");

            $(el).prop('disabled', true)
                .find("img")
                .show();

            if (!this.isRunning) {
                this.isRunning = true;

                $.ajax({
                    url: form.data('calculateUrl'),
                    type: "POST",
                    data: {
                        calculate: {
                            edits: formAttributesToJSON(form)
                        }
                    },
                    success: function () {
                        $(el).prop('disabled', false)
                            .find("img")
                            .hide();

                        this.isRunning = false;
                    }.bind(this)
                });
            }
        }
    }
}());
