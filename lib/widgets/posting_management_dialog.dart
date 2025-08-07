import 'package:flutter/material.dart';
import '../models/load_post.dart';
import '../models/user.dart';

class PostingManagementDialog extends StatefulWidget {
  final User user;
  final List<LoadPost> userPosts;
  final Function(List<String>) onDeletePosts;

  const PostingManagementDialog({
    super.key,
    required this.user,
    required this.userPosts,
    required this.onDeletePosts,
  });

  @override
  State<PostingManagementDialog> createState() => _PostingManagementDialogState();
}

class _PostingManagementDialogState extends State<PostingManagementDialog> {
  final Set<String> _selectedPostIds = {};
  bool _selectAll = false;

  @override
  Widget build(BuildContext context) {
    final hasOldPosts = widget.userPosts.isNotEmpty;

    if (!hasOldPosts) {
      // No old posts, just show welcome message
      return AlertDialog(
        title: Text('Welcome back, ${widget.user.name}!'),
        content: const Text('You have no previous postings. You can start creating new load posts.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Continue'),
          ),
        ],
      );
    }

    return AlertDialog(
      title: Text('Welcome back, ${widget.user.name}!'),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'You have ${widget.userPosts.length} previous posting(s). What would you like to do?',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Checkbox(
                  value: _selectAll,
                  onChanged: (value) {
                    setState(() {
                      _selectAll = value ?? false;
                      if (_selectAll) {
                        _selectedPostIds.addAll(widget.userPosts.map((p) => p.id));
                      } else {
                        _selectedPostIds.clear();
                      }
                    });
                  },
                ),
                const Text('Select All'),
              ],
            ),
            const SizedBox(height: 8),
            Flexible(
              child: Container(
                constraints: const BoxConstraints(maxHeight: 300),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: widget.userPosts.length,
                  itemBuilder: (context, index) {
                    final post = widget.userPosts[index];
                    final isSelected = _selectedPostIds.contains(post.id);
                    
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 2),
                      child: CheckboxListTile(
                        value: isSelected,
                        onChanged: (value) {
                          setState(() {
                            if (value == true) {
                              _selectedPostIds.add(post.id);
                            } else {
                              _selectedPostIds.remove(post.id);
                            }
                            _selectAll = _selectedPostIds.length == widget.userPosts.length;
                          });
                        },
                        title: Text(
                          '${post.origin} → ${post.destination}',
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Rate: \$${post.rate}'),
                            Text('Pickup: ${post.pickupDate}'),
                            if (post.equipment.isNotEmpty)
                              Text('Equipment: ${post.equipment.join(', ')}'),
                            Text('Status: ${post.status}'),
                          ],
                        ),
                        isThreeLine: true,
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Keep All'),
        ),
        if (_selectedPostIds.isNotEmpty)
          TextButton(
            onPressed: () {
              widget.onDeletePosts(_selectedPostIds.toList());
              Navigator.of(context).pop();
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: Text('Delete Selected (${_selectedPostIds.length})'),
          ),
        TextButton(
          onPressed: () {
            widget.onDeletePosts(widget.userPosts.map((p) => p.id).toList());
            Navigator.of(context).pop();
          },
          style: TextButton.styleFrom(
            foregroundColor: Colors.red,
          ),
          child: const Text('Delete All'),
        ),
      ],
    );
  }
}
