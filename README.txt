// === Diversity Supplier Checkbox Validation ===
var $diversityGroup = $('#edit-field-ar--2--wrapper');
var $diversityError = $('#field-ar-error');
var $diversityCheckboxes = $diversityGroup.find('input[type="checkbox"]');

$contactForm.on('submit', function (e) {

    var isChecked = $diversityCheckboxes.is(':checked');

    if (!isChecked) {
        $diversityGroup.addClass('has-error');
        $diversityError.text('Please select Yes or No for “Are you a registered Diversity Supplier?”.');
        e.preventDefault();
        return false;
    } else {
        $diversityGroup.removeClass('has-error');
        $diversityError.text('');
    }
});