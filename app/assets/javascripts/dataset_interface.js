var DatasetInterface = (function () {
    'use strict';

    return {
        enable: function () {
            var key,
                scope = $("form#new_edits");

            $("div.input span.history").on("click", function () {
                key = $(this).data('key');

                $("div.history." + key).toggleClass("hidden");
            });

            $("div.input span.val input[type='text']").on("change", function () {
                $(this).addClass("changed");

                scope.find("input[type='submit']").prop('disabled', false);
            });
        }
    }
}());
