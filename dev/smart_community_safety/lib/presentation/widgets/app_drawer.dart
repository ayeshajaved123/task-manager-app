import 'package:flutter/material.dart';

class AppDrawer extends StatelessWidget {
  final int selectedIndex;
  final void Function(int index) onSelect;

  const AppDrawer({
    super.key,
    required this.selectedIndex,
    required this.onSelect,
  });

  static const _bg = Color(0xFFF6F2FA); // app background
  static const _purple = Color(0xFF6C4AB6);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: _bg,
      child: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 12),

            // Header (matches your app style)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFEDE7F6),
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Row(
                children: [
                  CircleAvatar(
                    radius: 22,
                    backgroundColor: _purple,
                    child: Icon(Icons.security, color: Colors.white),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Smart Community Safety",
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 14,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          "Menu",
                          style: TextStyle(color: Colors.black54),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            Expanded(
              child: ListView(
                children: [
                  _item(context, 0, Icons.home_rounded, "Home"),
                  _item(context, 1, Icons.add_circle_outline, "Report Incident"),
                  _item(context, 2, Icons.map_outlined, "Map"),
                  _item(context, 3, Icons.notifications_none, "Alerts"),
                  _item(context, 4, Icons.bar_chart_rounded, "Analytics"),
                  _item(context, 5, Icons.person_outline, "Profile"),
                  _item(context, 6, Icons.sos_rounded, "SOS Emergency"),
                  _item(context, 7, Icons.settings_outlined, "Settings"),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _item(BuildContext context, int index, IconData icon, String title) {
    final bool isSelected = index == selectedIndex;

    return ListTile(
      leading: Icon(icon, color: isSelected ? _purple : Colors.black54),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
          color: isSelected ? _purple : Colors.black87,
        ),
      ),
      selected: isSelected,
      selectedTileColor: const Color(0xFFEDE7F6),
      onTap: () {
        Navigator.pop(context); // close drawer
        onSelect(index);
      },
    );
  }
}
