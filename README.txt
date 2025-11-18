// *****************************************
// REQUIRED YES/NO CHECKBOX GROUP VALIDATION
// *****************************************

function validateCheckboxGroups() {
    var errors = false;

    // Find all required checkbox groups
    var $requiredCheckboxes = $contactForm.find('input[type="checkbox"][required]');

    if ($requiredCheckboxes.length === 0) {
        return false;
    }

    // Group checkboxes by name
    var groups = {};
    $requiredCheckboxes.each(function () {
        var name = $(this).attr('name');

        if (!groups[name]) {
            groups[name] = $contactForm.find('input[name="' + name + '"]');
        }
    });

    // Validate groups
    $.each(groups, function (name, $group) {

        var $first = $group.first();

        // ✔ IMPORTANT — Target FIELDSET (from your screenshot)
        var $fieldset = $first.closest('fieldset');

        if ($fieldset.length === 0) {
            // fallback
            $fieldset = $first.closest('.form-item');
        }

        // Remove old errors
        $fieldset.removeClass('has-error');
        $fieldset.find('.checkbox-error').remove();

        // If nothing selected → show the error
        if (!$group.is(':checked')) {

            errors = true;

            $fieldset.addClass('has-error');

            // Append clean error message below the checkboxes
            $fieldset.find('.fieldset-wrapper')
                .append('<div class="checkbox-error error-msg" style="color:red;margin-top:6px;">Please select a valid option from Are you a registered Diversity Supplier.</div>');
        }
    });

    return errors;
}