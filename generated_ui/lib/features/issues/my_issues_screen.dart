import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../widgets/custom_search_bar.dart';
import '../../widgets/issue_card.dart';
import '../../widgets/loading_skeleton.dart';
import '../../widgets/empty_state.dart';

class MyIssuesScreen extends StatefulWidget {
  final Function(String)? onSelectIssue;

  const MyIssuesScreen({Key? key, this.onSelectIssue}) : super(key: key);

  @override
  State<MyIssuesScreen> createState() => _MyIssuesScreenState();
}

class _MyIssuesScreenState extends State<MyIssuesScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedFilter = 'All';
  bool _isLoading = false;

  final List<Map<String, String>> _allIssues = [
    {
      'id': '#IC-204',
      'title': 'Broken AC Unit in Library 2nd Floor',
      'location': 'Main Library, 2nd Floor',
      'date': 'Oct 24, 14:30',
      'status': 'In Progress',
      'priority': 'High',
    },
    {
      'id': '#IC-203',
      'title': 'Network Switch Outage in Engineering',
      'location': 'Engineering Bldg A, Server Room',
      'date': 'Oct 24, 10:15',
      'status': 'Open',
      'priority': 'Critical',
    },
    {
      'id': '#IC-202',
      'title': 'Leaking Water Pipe near Cafeteria',
      'location': 'Science Hall Block B, Basement',
      'date': 'Oct 23, 16:45',
      'status': 'Resolved',
      'priority': 'Low',
    },
    {
      'id': '#IC-201',
      'title': 'Flickering Elevator Lights in Student Center',
      'location': 'Campus Student Center, Elevator 2',
      'date': 'Oct 22, 09:20',
      'status': 'In Progress',
      'priority': 'Medium',
    },
    {
      'id': '#IC-200',
      'title': 'Door Access Card Reader Malfunction',
      'location': 'Technology Labs Wing, Room 102',
      'date': 'Oct 20, 11:00',
      'status': 'Resolved',
      'priority': 'Low',
    },
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Map<String, String>> get _filteredIssues {
    return _allIssues.where((issue) {
      final matchesSearch = issue['title']!.toLowerCase().contains(_searchController.text.toLowerCase()) ||
          issue['id']!.toLowerCase().contains(_searchController.text.toLowerCase()) ||
          issue['location']!.toLowerCase().contains(_searchController.text.toLowerCase());

      if (_selectedFilter == 'All') return matchesSearch;
      return matchesSearch && issue['status']!.toLowerCase() == _selectedFilter.toLowerCase();
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredIssues;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('My Reported Issues'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() => _isLoading = true);
              Future.delayed(const Duration(milliseconds: 600), () {
                if (mounted) setState(() => _isLoading = false);
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search & Filter Header Section
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                CustomSearchBar(
                  controller: _searchController,
                  onChanged: (val) => setState(() {}),
                  onClear: () => setState(() {}),
                ),
                const SizedBox(height: 14),

                // Filter Chips List
                SizedBox(
                  height: 38,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: AppConstants.issueStatuses.length,
                    itemBuilder: (context, index) {
                      final status = AppConstants.issueStatuses[index];
                      final isSelected = _selectedFilter == status;

                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(status),
                          selected: isSelected,
                          selectedColor: AppColors.primary,
                          backgroundColor: AppColors.surface,
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.white : AppColors.textSecondary,
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                            fontSize: 13,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                            side: BorderSide(
                              color: isSelected ? AppColors.primary : AppColors.cardBorder,
                            ),
                          ),
                          onSelected: (selected) {
                            if (selected) {
                              setState(() => _selectedFilter = status);
                            }
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          // Issues List Body
          Expanded(
            child: _isLoading
                ? ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: 4,
                    itemBuilder: (context, index) => const IssueCardSkeleton(),
                  )
                : filtered.isEmpty
                    ? EmptyState(
                        title: 'No Issues Found',
                        description: 'Try adjusting your search terms or filters.',
                        icon: Icons.search_off_rounded,
                        buttonText: 'Reset Filters',
                        onButtonPressed: () {
                          setState(() {
                            _searchController.clear();
                            _selectedFilter = 'All';
                          });
                        },
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: filtered.length,
                        itemBuilder: (context, index) {
                          final issue = filtered[index];
                          return IssueCard(
                            issueId: issue['id']!,
                            title: issue['title']!,
                            location: issue['location']!,
                            date: issue['date']!,
                            status: issue['status']!,
                            priority: issue['priority']!,
                            onTap: () {
                              if (widget.onSelectIssue != null) {
                                widget.onSelectIssue!(issue['id']!);
                              }
                            },
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
