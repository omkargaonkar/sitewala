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

/**
 * Implements hook_form_alter().
 */
function content_type_template_fields_form_alter(&$form, FormStateInterface $form_state, $form_id) {

  // ---------- EXISTING CODE ----------
  // your old code for node_type_edit_form remains same
  if ($form_id == 'node_type_edit_form') {
    // existing logic...
  }

  // ---------- NEW CODE FOR SUPPLIER REGISTRATION CONTACT FORM ----------
  if ($form_id == 'contact_message_supplier_registration_form') {

    // Check if field exists in form
    if (isset($form['field_ar'])) {

      // Get checkbox options
      $options = $form['field_ar']['widget']['#options'];

      // Convert "No" (0) into radio button
      $form['field_ar']['widget']['#type'] = 'radios';

      // Optional: ensure required attribute applies correctly
      $form['field_ar']['widget']['#required'] = TRUE;

      // Optional: set title if needed
      $form['field_ar']['widget']['#title'] = t('Are you a registered Diversity Supplier?');

      // Optional: Add attributes
      $form['field_ar']['widget']['#attributes']['class'][] = 'my-custom-radio';
    }
  }
}
