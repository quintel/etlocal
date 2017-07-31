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
        analyze: function () {
            var form = $("form.dataset_editor"),
                previousAnalyzes = $(".boxes.previous").data('analyzes');

            if (!this.isRunning) {
                this.isRunning = true;

                $.ajax({
                    url: form.data('calculateUrl'),
                    type: "POST",
                    data: {
                        calculate: {
                            previous_analyzes: previousAnalyzes,
                            edits: formAttributesToJSON(form)
                        }
                    },
                    success: function () {
                        this.isRunning = false;
                    }.bind(this)
                });
            }
        }
    }
}());
