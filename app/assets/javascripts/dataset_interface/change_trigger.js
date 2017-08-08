DatasetInterface.ChangeTrigger = {
    trigger: function (attribute) {
        $(this).addClass("changed");
        $(".overview-edits .apply.no-changes").hide();
        $(".overview-edits .apply.changes").show();

        DatasetInterface.FormEnabler.enable(attribute);
    }
};
