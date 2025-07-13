import 'package:flutter/material.dart';

import '../pages/post_form_page.dart';



class PostOptionsSheet extends StatelessWidget {
  const PostOptionsSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final options = [
      {'icon': Icons.help_outline, 'label': 'Ask for Help'},
      {'icon': Icons.card_giftcard, 'label': 'Giveaway Item'},
      {'icon': Icons.warning_amber, 'label': 'Alert'},
      {'icon': Icons.announcement, 'label': 'Announcement'},
      {'icon': Icons.volunteer_activism, 'label': 'Need Volunteers'},
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'What would you like to post?',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),

          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 3,
            mainAxisSpacing: 20,
            crossAxisSpacing: 20,
            childAspectRatio: 0.9,
            children: options.map((option) {
              return GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                  // Inside onTap of option
                  //Navigator.pop(context); // Close sheet first

                  switch (option['label']) {
                    case 'Ask for Help':
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const AskForHelpForm(),
                        ),
                      );
                      break;
                    case 'Giveaway Item':
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const GiveawayItemForm(),
                        ),
                      );
                      break;
                    case 'Alert':
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const AlertForm()),
                      );
                      break;
                    case 'Announcement':
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const AnnouncementForm(),
                        ),
                      );
                      break;
                    case 'Need Volunteers':
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const NeedVolunteersForm(),
                        ),
                      );
                      break;
                  }
                },
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.green.shade100,
                      child: Icon(
                        option['icon'] as IconData,
                        color: Colors.green,
                        size: 30,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Flexible(
                      child: Text(
                        option['label'] as String,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        softWrap: true,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
