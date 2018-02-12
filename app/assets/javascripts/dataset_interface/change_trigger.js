DatasetInterface.ChangeTrigger = {
    trigger: function (attribute) {
        var showChanges;

        $(attribute).toggleClass("changed", $(attribute).val() !== '');

        showChanges = $('input.changed, div.slider.changed').length > 0;

        $('input.changed').removeClass('valid invalid');

        $(".overview-edits .apply.no-changes").toggle(!showChanges);
        $(".overview-edits .apply.changes")
            .removeClass('valid invalid')
            .toggle(showChanges);

        DatasetInterface.FormEnabler.enable(attribute);
    }
};
