// *****************************************
// REQUIRED CHECKBOX GROUP VALIDATION (YES/NO)
// *****************************************

var $checkboxGroups = {};

// Collect checkbox groups that belong together
$contactForm.find('input[type="checkbox"][required]').each(function () {
    var name = $(this).attr('name');
    if (!$checkboxGroups[name]) {
        $checkboxGroups[name] = $contactForm.find('input[name="' + name + '"]');
    }
});

// Validate each checkbox group
$.each($checkboxGroups, function (name, $group) {

    var $first = $group.first();

    // Drupal wraps checkboxes differently, so we use wider selector
    var $wrapper = $first.closest('.form-item, .js-form-item, .form-type-checkbox, fieldset');

    // Remove previous error states
    $wrapper.find('.error-msg').remove();
    $wrapper.removeClass('has-error');

    // If nothing is selected → ERROR
    if (!$group.is(':checked')) {

        $wrapper.addClass('has-error');

        $wrapper.append(
            '<span class="error-msg" style="color:red;">Please select a valid option.</span>'
        );

        errors = true;
    }
});