(function (refinery) {

    'use strict';

    /**
     * @constructor
     * @extends {refinery.admin.Search}
     * @param {Object=} options
     */
    refinery.Object.create({
        name: 'Search',

        module: 'admin',

        search: function (str) {
            var that = this,
                form = that.holder,
                url = form.attr('action');

            if (str.length > 0) {
                url += (/\?/.test(url) ? '&' : '?' ) + $.param(form.serializeArray());
            }

            form.find(':input').prop('disabled', true);
            Turbolinks.visit(url);
        },

        focus: function (elm) {
            var val = elm.val();
            elm.focus();
            elm.val('');
            elm.val(val);
        },

        bind_events: function () {
            var that = this,
                form = that.holder;

            form.on('submit', function (e) {
                var input = form.find('input[type=search]:valid');

                e.preventDefault();
                e.stopPropagation();

                if (input.length > 0) {
                    that.search(input.val());
                }
            });
        },

        /**
         * @expose
         * @param {jQuery} holder
         * @return {Object} self
         */
        init: function (holder) {
            if (this.is('initialisable')) {
                this.is('initialising', true);
                this.holder = holder;
                this.searching = false;
                this.bind_events();

                // sometime after page refresh input fields
                // stay disabled so we here will enable them for sure
                holder.find(':input').prop('disabled', false);

                // always focus search input
                this.focus(holder.find('input[type=search]'));

                this.is({'initialised': true, 'initialising': false});
                this.trigger('init');
            }

            return this;
        }
    });

    refinery.admin.ui.search = function (holder, ui) {
        holder.find('.search_form').each(function () {
            ui.addObject( refinery('admin.Search').init($(this)) );
        });
    };

}(refinery));
