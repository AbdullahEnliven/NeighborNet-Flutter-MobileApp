import 'package:flutter/material.dart';

import '../widgets/form_field_data.dart';


// 1. Ask for Help Form
class AskForHelpForm extends StatelessWidget {
  const AskForHelpForm({super.key});

  @override
  Widget build(BuildContext context) {
    return PostFormPage(
      title: 'Ask for Help',
      fields: [
        FormFieldData(label: 'Title', isRequired: true, isMultiline: true),
        FormFieldData(label: 'Details', isMultiline: true),
       // FormFieldData(label: 'Location'),
       // FormFieldData(label: 'Contact Number', inputType: TextInputType.phone),
        FormFieldData(
          label: 'Upload Image (optional)',
          isRequired: false,
          isImage: true,
        ),
      ],
    );
  }
}


// 2. Giveaway Item Form
class GiveawayItemForm extends StatelessWidget {
  const GiveawayItemForm({super.key});

  @override
  Widget build(BuildContext context) {
    return PostFormPage(
      title: 'Giveaway Item',
      fields: [
        FormFieldData(label: 'Item Name', isRequired: true),
        FormFieldData(label: 'Description', isMultiline: true),
        FormFieldData(label: 'Condition', hint: 'New, Used, etc.'),
        //(label: 'Location'),
       // FormFieldData(label: 'Contact Number', inputType: TextInputType.phone),
        FormFieldData(label: 'Item Image', isRequired: true, isImage: true),
      ],
    );
  }
}

// 3. Alert Form
class AlertForm extends StatelessWidget {
  const AlertForm({super.key});

  @override
  Widget build(BuildContext context) {
    return PostFormPage(
      title: 'Alert',
      fields: [
        FormFieldData(label: 'Alert Title', isRequired: true),
        FormFieldData(label: 'Details', isMultiline: true),
        //FormFieldData(label: 'Location'),
        FormFieldData(label: 'Item Image', isRequired: false, isImage: true),
      ],
    );
  }
}

// 4. Announcement Form
class AnnouncementForm extends StatelessWidget {
  const AnnouncementForm({super.key});

  @override
  Widget build(BuildContext context) {
    return PostFormPage(
      title: 'Announcement',
      fields: [
        FormFieldData(label: 'Announcement Title', isRequired: true),
        FormFieldData(label: 'Details', isMultiline: true),
        FormFieldData(
          label: 'Date',
          hint: 'Event date',
          inputType: TextInputType.datetime,
        ),
       // FormFieldData(label: 'Location'),
        FormFieldData(label: 'Item Image', isRequired: false, isImage: true),
      ],
    );
  }
}

// 5. Need Volunteers Form
class NeedVolunteersForm extends StatelessWidget {
  const NeedVolunteersForm({super.key});

  @override
  Widget build(BuildContext context) {
    return PostFormPage(
      title: 'Need Volunteers',
      fields: [
        FormFieldData(label: 'Task', isRequired: true),
        FormFieldData(label: 'Details', isMultiline: true),
        FormFieldData(
          label: 'Date & Time',
          hint: 'When?',
          inputType: TextInputType.datetime,
        ),
       // FormFieldData(label: 'Location'),
        //FormFieldData(label: 'Contact Number', inputType: TextInputType.phone),
        FormFieldData(label: 'Item Image', isRequired: false, isImage: true),
      ],
    );
  }
}
