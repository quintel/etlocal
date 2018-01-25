DatasetInterface.Analyzer = (function () {
    'use strict';

    function formAttributesToJSON(form) {
        var value,
            key,
            result = {},
            object = form.serializeObject();

        for (key in object.edits) {
            if (object.edits.hasOwnProperty(key)) {
                if (key != 'dataset_id') {
                    result[key] = object.edits[key];
                }
            }
        }

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
