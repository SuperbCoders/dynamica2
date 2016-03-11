$(function(){
	if($('.switcher').length){$("[data-toggle='switch']").bootstrapSwitch({baseClass: 'switch'});};
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
