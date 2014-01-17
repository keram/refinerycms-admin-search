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

        search: function () {
            var that = this,
                form = that.holder,
                data = form.serializeArray();

            that.searching = true;

            form.find(':input').prop('disabled', true);

            $.ajax(form.attr('action'), {
                'data': data
            }).done(function (response, status, xhr) {
               form.trigger('ajax:success', [response, status, xhr]);
            }).fail(function () {
                form.find(':input').prop('disabled', false);
            }).always(function () {
                that.searching = false;
            });
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

                if (!that.searching &&
                    input.length > 0 && input.val().length >= 3) {
                    that.search();
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
