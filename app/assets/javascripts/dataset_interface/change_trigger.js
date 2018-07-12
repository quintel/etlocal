DatasetInterface.ChangeTrigger = {
    trigger: function (attribute) {
        var showChanges;
        var attributeEl = $(attribute);

        attributeEl.toggleClass("changed", attributeEl.val() !== '');

        showChanges = $('input.changed').length > 0;

        $('input.changed').removeClass('valid invalid');

        $(".overview-edits .apply.no-changes").toggle(!showChanges);
        $(".overview-edits .apply.changes")
            .removeClass('valid invalid')
            .toggle(showChanges);

        DatasetInterface.FormEnabler.enable(attribute);
    }
};
