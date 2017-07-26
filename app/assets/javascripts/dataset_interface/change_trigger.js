DatasetInterface.ChangeTrigger = {
    trigger: function (attribute) {
        DatasetInterface.Analyzer.analyze(attribute);
        DatasetInterface.FormEnabler.enable(attribute);
    }
};
