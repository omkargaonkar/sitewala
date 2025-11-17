/**
 * Validation for Supplier Registration contact form.
 */
function YOURMODULE_form_contact_message_contact_name_form_validate(&$form, &$form_state) {
  // Get value of field_ar (0/1 checkboxes).
  $value = $form_state->getValue('field_ar');

  // field_ar returns an array like: [0 => '0'] or []
  // If empty => no selection.
  if (empty(array_filter($value))) {
    $form_state->setErrorByName(
      'field_ar',
      t('Please select a valid option for “Are you a registered Diversity Supplier?”.')
    );
  }
}