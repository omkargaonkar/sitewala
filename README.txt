// >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
// >>> UPDATED YES/NO CHECKBOX VALIDATION — FINAL WORKING VERSION >>>
// >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

var $ynWrapper = $('.form-item--field-ar'); // your wrapper class OR update to actual wrapper
var $yes = $('#edit-field-ar-0-2');   // YES checkbox ID
var $no  = $('#edit-field-ar-0-1');   // NO checkbox ID

// Remove previous error
$ynWrapper.find('.error-msg').remove();

if (!$yes.is(':checked') && !$no.is(':checked')) {

    $ynWrapper.addClass('has-error');

    $ynWrapper.append(
        '<span class="error-msg" role="alert">Please select a valid option for "Are you a registered Diversity Supplier?".</span>'
    );

    errors = true;

} else {

    $ynWrapper.removeClass('has-error');

}