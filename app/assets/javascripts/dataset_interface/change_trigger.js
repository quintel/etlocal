DatasetInterface.ChangeTrigger = {
    trigger: function (attribute) {
        DatasetInterface.Analyzer.analyze();
        DatasetInterface.FormEnabler.enable(attribute);
    }
};
