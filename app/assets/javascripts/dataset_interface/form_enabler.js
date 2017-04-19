var FormEnabler = {
    enable: function (attribute) {
        $('form#new_edits')
            .find("input[type='submit']")
            .prop('disabled', false);

        $(attribute).addClass("changed");
    }
};
