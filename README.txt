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


xxx


// Checkbox group validation (Yes/No Supplier Diversity)
if ($input.attr('name') === 'supplier_diversity') {

    var $group = $('#supplier-diversity-group');
    var $error = $('#supplier-diversity-error');
    var $checkboxes = $group.find('input[type="checkbox"]');

    // Check if any checkbox is selected
    var isChecked = $checkboxes.is(':checked');

    if (!isChecked) {
        $group.addClass('has-error');
        $error.text('Please select a valid option for "Are you a registered Diversity Supplier?".');
        return false;
    } else {
        $group.removeClass('has-error');
        $error.text('');
        return true;
    }
}