// =============================
// NEW CODE: Yes/No checkbox validation
// Field machine name: field_ar
// =============================
var $yesNoField = $('input[name="field_ar[0]"]');
var $yesNoWrapper = $yesNoField.closest('.form-item');
var $yesNoError = $yesNoWrapper.find('.error-msg');

// Remove previous errors
$yesNoWrapper.removeClass('has-error');
$yesNoError.hide();

// Count checked boxes
var checkedCount = $('input[name="field_ar[0]"]:checked').length;

// Validation rules:
// ✔ If 1 checkbox selected (Yes OR No) → VALID
// ❌ If 0 or 2 checkboxes selected → INVALID
if (checkedCount !== 1) {
    e.preventDefault();
    $yesNoWrapper.addClass('has-error');

    // If no error span exists, append one
    if (!$yesNoError.length) {
        $yesNoWrapper.append(
            '<span class="error-msg" role="alert">Please select a valid option from “Are you a registered Diversity Supplier?”.</span>'
        );
    } else {
        $yesNoError.text('Please select a valid option from “Are you a registered Diversity Supplier?”.');
        $yesNoError.show();
    }

    errors = true;
}







_validatefield = function (ctx) {

    // ==========================
    // NEW CODE START (YES/NO VALIDATION)
    // ==========================

    // Select the Yes/No checkbox group
    var yesNoCheckboxes = ctx.find('input[name="field_ar[0]"]');

    // Remove previous error state
    yesNoCheckboxes.removeAttr('aria-invalid');
    yesNoCheckboxes.closest('.js-form-item').removeClass('has-error');
    ctx.find('#field-ar-error').remove();

    // Check if none of the options are selected
    if (!yesNoCheckboxes.is(':checked')) {

        // Add error icon + text message (matches AC and ZIP error style)
        yesNoCheckboxes
            .attr('aria-invalid', 'true')
            .closest('.js-form-item')
            .addClass('has-error')
            .append(
                '<span class="error-msg" id="field-ar-error" role="alert">' +
                '<span class="error-icon"></span>' +
                'Please select a valid option for "Are you a registered Diversity Supplier?".' +
                '</span>'
            );

        return false; // Stop form submission
    }

    // ==========================
    // NEW CODE END
    // ==========================


    // Existing validation logic continues below…
    // (Do NOT modify your other field validations)
};

