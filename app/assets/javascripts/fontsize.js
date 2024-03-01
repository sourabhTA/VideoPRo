if (!RedactorPlugins) var RedactorPlugins = {};

(function ($) {
    RedactorPlugins.fontsize = function () {
        return {
            translations: {
                en: {
                    "size": "Size",
                    "remove-size": "Remove Font Size"
                }
            },
            init: function () {
                // this.app = app;
                // this.lang = app.lang;
                // this.inline = app.inline;
                // this.toolbar = app.toolbar;
                this.sizes = [10, 11, 12, 14, 16, 18, 20, 24, 28, 30, 36, 48, 64, 128, 144, 280];
                var dropdown = {};
                for (var i = 0; i < this.sizes.length; i++) {
                    var size = this.sizes[i];
                    dropdown[i] = {
                        title: size + 'px',
                        func: this.fontsize.set,
                        api: 'plugin.fontsize.set',
                        args: size
                    };
                }

                dropdown.remove = {
                    title: "Clear size",
                    func: this.fontsize.remove,
                    api: 'plugin.fontsize.remove'
                };

                var button = this.button.addBefore('bold', 'fontsize', "Font");
                this.button.addDropdown(button, dropdown);
            },
            set: function (index) {
                var size = this.sizes[index]
                this.inline.toggleStyle('font-size: ' + size + 'px')
                // var args = {
                //     tag: 'span',
                //     style: { 'font-size': size + 'px' },
                //     type: 'toggle'
                // };
                // this.inline.format(args);
            },
            remove: function () {
                this.inline.removeStyleRule('font-size')
            }
        };
    };
})(jQuery);