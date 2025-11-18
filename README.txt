// *****************************************
// REQUIRED CHECKBOX GROUP VALIDATION (YES/NO)
// *****************************************

var $checkboxGroups = {};

$contactForm.find('input[type="checkbox"][required]').each(function () {
    var name = $(this).attr('name');
    if (!$checkboxGroups[name]) {
        $checkboxGroups[name] = $contactForm.find('input[name="' + name + '"]');
    }
});

// Validate each checkbox group
$.each($checkboxGroups, function (name, $group) {

    var $first = $group.first();

    // IMPORTANT: get fieldset wrapper (correct Drupal container)
    var $fieldset = $first.closest('fieldset');

    // fallback if no fieldset
    if (!$fieldset.length) {
        $fieldset = $first.closest('.form-item');
    }

    // remove old error
    $fieldset.find('.checkbox-error-msg').remove();
    $fieldset.removeClass('has-error');

    // If none selected, show error
    if (!$group.is(':checked')) {

        $fieldset.addClass('has-error');

        $fieldset.find('.fieldset-wrapper').append(
            '<div class="checkbox-error-msg error-msg" role="alert" style="color:red;margin-top:6px;">' +
            'Please select a valid option from "Are you a registered Diversity Supplier?".' +
            '</div>'
        );

        errors = true;
    }
});