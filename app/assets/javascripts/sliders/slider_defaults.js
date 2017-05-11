var SliderDefaults = {
    fetch: function () {
        if (this.defaults) {
            return null;
        } else {
            return $.ajax({
                url: "datasets/defaults",
                dataType: "json",
                success: function (data) {
                    this.defaults = data;
                }.bind(this)
            });
        }
    }
};
