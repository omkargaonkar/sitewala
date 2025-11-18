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
    var $wrapper = $first.closest('.form-item');

    // Remove old error
    $wrapper.find('.error-msg').remove();
    $wrapper.removeClass('has-error');

    // If nothing selected – FAIL
    if (!$group.is(':checked')) {
        $wrapper.addClass('has-error');
        $wrapper.append(
            '<span class="error-msg">Please select a valid option.</span>'
        );
        errors = true;
    }
});