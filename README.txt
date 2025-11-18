var diversityGroup = $('#supplier-diversity-group');
var diversityInputs = diversityGroup.find('input[type="checkbox"]');
var diversityError = $('#supplier-diversity-error');

if (!diversityInputs.is(':checked')) {
    diversityGroup.addClass('has-error');
    diversityError.text('Please select a valid option for “Are you a registered Diversity Supplier?”.');
    e.preventDefault();
    errors = true;
} else {
    diversityGroup.removeClass('has-error');
    diversityError.text('');
}