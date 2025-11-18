// ===== Drupal-style Error for Diversity Supplier Yes/No =====
function addDrupalError($fieldset, message) {

    // Add Drupal error class to fieldset
    $fieldset.addClass('error');

    // Remove old error if exists
    $fieldset.find('.form-item--error-message').remove();

    // Add Drupal-style error markup
    $fieldset.append(
        '<div class="form-item--error-message"><strong>' + message + '</strong></div>'
    );
}

function clearDrupalError($fieldset) {
    $fieldset.removeClass('error');
    $fieldset.find('.form-item--error-message').remove();
}

// === Validation ===
var $fieldset = $('#edit-field-ar--2--wrapper');
var $checkboxes = $fieldset.find('input[type="checkbox"]');

if (!$checkboxes.is(':checked')) {
    addDrupalError($fieldset, 'Please select Yes or No for the “Are you a registered Diversity Supplier?” field.');
    e.preventDefault();
    return false;
} else {
    clearDrupalError($fieldset);
}