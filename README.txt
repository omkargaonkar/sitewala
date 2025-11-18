// *****************************************
// REQUIRED CHECKBOX GROUP VALIDATION (YES/NO)
// *****************************************

var $checkboxGroups = {};

$contactForm.find('input[type="checkbox"][required]').each(function () {
    var name = $(this).attr('name');

    // Group all checkboxes by name
    if (!$checkboxGroups[name]) {
        $checkboxGroups[name] = $contactForm.find('input[name="' + name + '"]');
    }
});

$.each($checkboxGroups, function (name, $group) {

    var $first = $group.first();

    // Select the closest FIELDSET — this is the correct wrapper in Drupal
    var $fieldset = $first.closest('fieldset');

    // Remove old errors
    $fieldset.find('.error-msg').remove();
    $fieldset.removeClass('has-error');

    // If none selected → error
    if (!$group.is(':checked')) {

        $fieldset.addClass('has-error');

        // Use fieldset legend as label
        var label = $fieldset.find('.fieldset-legend').text().trim();

        // Add proper accessible error message
        $fieldset.append(
            '<span class="error-msg" style="color:red; display:block; margin-top:4px;">' +
            'Please select a valid option for ' + label + '.' +
            '</span>'
        );

        errors = true;
    }
});