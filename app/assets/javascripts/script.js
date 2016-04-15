$(function(){
	if($('.switcher').length){$("[data-toggle='switch']").bootstrapSwitch({baseClass: 'switch'});};
    $('body')
        .delegate('.bootstrap-select.filterSelect', 'hide.bs.dropdown', function () {
            $(this).closest('.hover-select-box').removeClass('opened');
        })
        .delegate('.bootstrap-select.filterSelect', 'click', function () {
            $(this).closest('.hover-select-box').addClass('opened');
        })
        .delegate('.dropdown.filterSelect', 'hide.bs.dropdown', function () {
            $(this).closest('.hover-select-box').removeClass('opened');
        })
        .delegate('.dropdown.filterSelect', 'click', function () {
            $(this).closest('.hover-select-box').addClass('opened');
        })
        .delegate('.filter-mod.hover-select-box .filterSelect.selectpicker', 'change', function () {
            $(this).closest('.filter-holder').addClass('current').siblings().removeClass('current');
        })
        .delegate('.hoverCatcher', 'mouseenter', function () {
            var firedEl = $($(this).attr('data-area'));

            activeFamilyGraph = $(this).attr('data-area').replace(/\D/g, '') * 1;

            firedEl.css('opacity', 1).siblings('.area').css('opacity', .15);

        })
        .delegate('.hoverCatcher', 'mouseleave', function () {
            var firedEl = $($(this).attr('data-area'));

            firedEl.css('opacity', .5).siblings('.area').css('opacity', .5);
        });
});

Number.prototype.number_with_delimiter = function(delimiter) {
    var number = this + '', delimiter = delimiter || ',';
    var split = number.split('.');
    split[0] = split[0].replace(
        /(\d)(?=(\d\d\d)+(?!\d))/g,
        '$1' + delimiter
    );
    return split.join('.');
};
