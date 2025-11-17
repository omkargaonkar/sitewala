/**
 * Implements hook_form_alter().
 */
function content_type_template_fields_form_alter(&$form, FormStateInterface $form_state, $form_id) {

  // --- Your existing module logic remains unchanged ---
  if ($form_id == 'node_type_edit_form') {
    // your previous logic...
  }

  // --- New code for Supplier Registration contact form ---
  if ($form_id == 'contact_message_contact_name_form') {

    // Ensure field exists
    if (isset($form['field_ar']['widget'])) {

      // Force radios instead of checkboxes
      $form['field_ar']['widget']['#type'] = 'radios';

      // Force options for radios
      $form['field_ar']['widget']['#options'] = [
        0 => t('No'),
        1 => t('Yes'),
      ];

      // Set default if needed (optional)
      if (empty($form['field_ar']['widget']['#default_value'])) {
        $form['field_ar']['widget']['#default_value'] = 0; // No by default
      }

      // Make sure only one required selection
      $form['field_ar']['widget']['#required'] = TRUE;

      // Set title again (not required but safe)
      $form['field_ar']['widget']['#title'] = t('Are you a registered Diversity Supplier?');
    }
  }
}