import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class EmergencyContactsScreen extends StatefulWidget {
  const EmergencyContactsScreen({super.key});

  @override
  State<EmergencyContactsScreen> createState() => _EmergencyContactsScreenState();
}

class _EmergencyContactsScreenState extends State<EmergencyContactsScreen> {
  final List<_Contact> _personal = [];

  final _name = TextEditingController();
  final _phone = TextEditingController();

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    super.dispose();
  }

  Future<void> _dial(String number) async {
    final uri = Uri(scheme: 'tel', path: number);
    if (!await canLaunchUrl(uri)) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Dialer not available on this device.")),
      );
      return;
    }
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  void _addPersonal() {
    final n = _name.text.trim();
    final p = _phone.text.trim();
    if (n.isEmpty || p.isEmpty) return;

    setState(() {
      _personal.add(_Contact(title: n, number: p));
      _name.clear();
      _phone.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    final emergency = <_Contact>[
      const _Contact(title: "Police", number: "15", icon: Icons.local_police_outlined),
      const _Contact(title: "Rescue", number: "1122", icon: Icons.health_and_safety_outlined),
      const _Contact(title: "Fire Brigade", number: "16", icon: Icons.local_fire_department_outlined),
      const _Contact(title: "Edhi Ambulance", number: "115", icon: Icons.emergency_outlined),
    ];

    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 20),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    height: 44,
                    width: 44,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      color: cs.primary.withOpacity(0.12),
                    ),
                    child: Icon(Icons.call_outlined, color: cs.primary),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Emergency Contacts",
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
                        SizedBox(height: 2),
                        Text("Tap to open phone dialer",
                            style: TextStyle(fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 14),
          const Text("Emergency Services",
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900)),
          const SizedBox(height: 10),

          ...emergency.map((c) => _tile(c, onTap: () => _dial(c.number))),

          const SizedBox(height: 16),
          const Divider(),

          const SizedBox(height: 12),
          const Text("Personal Contacts",
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900)),
          const SizedBox(height: 10),

          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                children: [
                  TextField(
                    controller: _name,
                    decoration: const InputDecoration(
                      labelText: "Name",
                      prefixIcon: Icon(Icons.person_outline),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _phone,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      labelText: "Phone",
                      prefixIcon: Icon(Icons.phone_outlined),
                    ),
                  ),
                  const SizedBox(height: 12),
                  FilledButton.icon(
                    onPressed: _addPersonal,
                    icon: const Icon(Icons.add),
                    label: const Text("Add Contact"),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 10),

          if (_personal.isEmpty)
            const Padding(
              padding: EdgeInsets.only(top: 14),
              child: Text("No personal contacts added yet.",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontWeight: FontWeight.w700)),
            )
          else
            ..._personal.map((c) => _tile(
              c,
              trailing: IconButton(
                icon: const Icon(Icons.delete_outline),
                onPressed: () => setState(() => _personal.remove(c)),
              ),
              onTap: () => _dial(c.number),
            )),
        ],
      ),
    );
  }

  Widget _tile(_Contact c, {Widget? trailing, VoidCallback? onTap}) {
    return Card(
      child: ListTile(
        onTap: onTap,
        leading: Icon(c.icon ?? Icons.contact_phone_outlined),
        title: Text(c.title, style: const TextStyle(fontWeight: FontWeight.w900)),
        subtitle: Text(c.number, style: const TextStyle(fontWeight: FontWeight.w700)),
        trailing: trailing ?? const Icon(Icons.chevron_right),
      ),
    );
  }
}

class _Contact {
  final String title;
  final String number;
  final IconData? icon;
  const _Contact({required this.title, required this.number, this.icon});
}
