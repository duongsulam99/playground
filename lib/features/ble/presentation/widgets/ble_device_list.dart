import 'package:flutter/material.dart';
import 'package:vulcan_mobile_playground/features/ble/domain/entities/ble_discovered_device.dart';

class BleDeviceList extends StatelessWidget {
  const BleDeviceList({
    required this.devices,
    required this.onDeviceSelected,
    super.key,
  });

  final List<BleDiscoveredDevice> devices;
  final ValueChanged<String> onDeviceSelected;

  @override
  Widget build(BuildContext context) {
    if (devices.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(
          child: Text(
            'No devices found. Start scanning to discover BLE devices.',
          ),
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: devices.length,
      separatorBuilder: (_, _) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final device = devices[index];
        return ListTile(
          leading: const Icon(Icons.bluetooth),
          title: Text(device.displayName),
          subtitle: Text('${device.id}\nRSSI: ${device.rssi} dBm'),
          isThreeLine: true,
          trailing: device.isConnectable
              ? const Icon(Icons.link)
              : const Icon(Icons.link_off, color: Colors.grey),
          onTap: device.isConnectable
              ? () => onDeviceSelected(device.id)
              : null,
        );
      },
    );
  }
}
