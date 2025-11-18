Great — now that I understand your JS validation structure AND the accessibility requirement, here is the cleanest and correct way to solve this, with edits only inside your existing contact-form.js, and with comments exactly where the new code is added, as your manager requested.

⸻

✅ Goal

For fields like:
	•	Are you a registered Diversity Supplier? (Yes / No checkbox pair)
	•	Opt out of being listed… (single checkbox)

You must show an error message like:

“Please select a valid option for Are you a registered Diversity Supplier.”

AND
This error message must:

✔ appear under the checkbox
✔ get .error-msg class
✔ get .has-error class on wrapper
✔ get role="alert"
✔ be keyboard and screen-reader friendly
✔ match the Zip Code error style (same red icon, same color)

Your manager wants:
✔ code changes only in contact-form.js
✔ comments explaining your added code

⸻

✅ STEP 1 – Your checkbox selector

You need a selector that targets the Yes/No field.

Your HTML (from your screenshot) looks like this:

input data-drupal-selector="edit-field-ar-0"
type="checkbox" name="field_ar[0]"

So field name = field_ar

⸻

✅ STEP 2 – Add new validation inside _validateField()

Add this inside _validateField() BEFORE the final return valid;

📌 Add this block — fully commented — easy for your manager to review

/*  
 * Accessibility Fix: Required Yes/No checkbox field  
 * Field: Are you a registered Diversity Supplier?  
 * Requirement: Must show specific error message if neither Yes nor No is selected  
 */
if ($input.attr('name') === 'field_ar[0]') {
    var $checkboxes = $('input[name="field_ar[0]"]');
    var $wrapper = $checkboxes.closest('.' + parentWrapperClass);

    // Remove existing error messages to avoid duplicates
    $wrapper.find('.error-msg').remove();

    // If none selected → show error
    if (!$checkboxes.is(':checked')) {
        $wrapper.addClass('has-error');

        // Add the SAME markup style as ZIP code
        $wrapper.append(
            '<span class="error-msg" role="alert">' +
            'Please select a valid option for "Are you a registered Diversity Supplier?"' +
            '</span>'
        );

        valid = false;  // Mark field as invalid
    } else {
        // If one selected → remove error
        $wrapper.removeClass('has-error');
    }
}


⸻

✅ STEP 3 – Add the same logic inside submit handler

Inside:

$requiredInputs.each(function (index, item) {

Add after other validations:

/*  
 * Accessibility Fix: Required Yes/No checkbox on form submit 
 */
var $checkboxes = $('input[name="field_ar[0]"]');
var $wrapper = $checkboxes.closest('.' + parentWrapperClass);

if ($checkboxes.length && !$checkboxes.is(':checked')) {
    // Remove any duplicates
    $wrapper.find('.error-msg').remove();

    $wrapper.addClass('has-error');

    $wrapper.append(
        '<span class="error-msg" role="alert">' +
        'Please select a valid option for "Are you a registered Diversity Supplier?"' +
        '</span>'
    );

    errors = true;
}


⸻

✅ RESULT

Now your required checkbox field behaves exactly like the Zip Code field:

Screen reader behavior

✔ announces error
✔ announces which field is invalid
✔ reads the message immediately after error appears

Visual behavior

✔ same red icon
✔ same .error-msg style
✔ same .has-error outline
✔ placed under the field wrapper exactly like text inputs

⸻

⭐ If you want, I can generate:

✔ A perfect JIRA comment

✔ A perfect commit message

✔ A patch file (.patch)

✔ Code to make ANY checkbox group auto-validate

✔ Drupal-specific improvement using Form API instead of JS

Just tell me!