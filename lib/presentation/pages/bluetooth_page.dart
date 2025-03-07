import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_theme.dart';
import '../../domain/services/bluetooth_service.dart';
import '../viewmodels/bluetooth_viewmodel.dart';
import '../widgets/app_button.dart';

/// Екран підключення Bluetooth
class BluetoothPage extends StatefulWidget {
  /// Шлях до сторінки
  static const String routeName = '/bluetooth';

  /// Конструктор
  const BluetoothPage({Key? key}) : super(key: key);

  @override
  State<BluetoothPage> createState() => _BluetoothPageState();
}

class _BluetoothPageState extends State<BluetoothPage> {
  /// Контролер для оновлення списку
  final RefreshController _refreshController = RefreshController();

  @override
  void initState() {
    super.initState();

    // Перевірка доступності Bluetooth та початок сканування
    Future.delayed(Duration.zero, () async {
      final bluetoothViewModel = Provider.of<BluetoothViewModel>(context, listen: false);

      // Перевірка дозволів
      final hasPermission = await bluetoothViewModel.checkPermissions();

      if (hasPermission) {
        // Початок сканування
        _startScan();
      } else {
        // Показ діалогу про відсутність дозволів
        _showPermissionDialog();
      }
    });
  }

  @override
  void dispose() {
    _refreshController.dispose();
    super.dispose();
  }

  /// Початок сканування пристроїв
  Future<void> _startScan() async {
    final bluetoothViewModel = Provider.of<BluetoothViewModel>(context, listen: false);

    try {
      await bluetoothViewModel.scanForDevices();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Помилка сканування: ${e.toString()}'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    } finally {
      _refreshController.refreshCompleted();
    }
  }

  /// Показ діалогу про відсутність дозволів
  void _showPermissionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Потрібен дозвіл'),
        content: const Text(
          'Для використання Bluetooth необхідні дозволи. '
              'Будь ласка, надайте дозвіл на використання Bluetooth і місцезнаходження.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: const Text('Відмінити'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();

              final bluetoothViewModel = Provider.of<BluetoothViewModel>(context, listen: false);
              final hasPermission = await bluetoothViewModel.checkPermissions();

              if (hasPermission) {
                _startScan();
              } else {
                Navigator.of(context).pop();
              }
            },
            child: const Text('Надати дозвіл'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Підключення пристрою'),
        backgroundColor: AppTheme.primaryColor,
      ),
      body: Consumer<BluetoothViewModel>(
        builder: (context, bluetoothViewModel, child) {
          final isConnected = bluetoothViewModel.connectionStatus == BluetoothConnectionStatus.connected;
          final isScanning = bluetoothViewModel.isScanning;
          final devices = bluetoothViewModel.devices;

          return Column(
            children: [
              // Секція статусу Bluetooth
              _buildBluetoothStatusSection(bluetoothViewModel),

              // Заголовок списку
              Padding(
                padding: const EdgeInsets.all(AppTheme.paddingMedium),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Доступні пристрої',
                      style: TextStyle(
                        fontSize: AppTheme.fontSizeLarge,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.refresh),
                      onPressed: isScanning ? null : () => _startScan(),
                      tooltip: 'Оновити список',
                    ),
                  ],
                ),
              ),

              // Індикатор сканування
              if (isScanning)
                const LinearProgressIndicator(
                  backgroundColor: Colors.transparent,
                  valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
                ),

              // Список пристроїв
              Expanded(
                child: devices.isEmpty
                    ? _buildEmptyDevicesList(isScanning)
                    : _buildDevicesList(devices, bluetoothViewModel),
              ),
            ],
          );
        },
      ),
    );
  }

  /// Побудова секції статусу Bluetooth
  Widget _buildBluetoothStatusSection(BluetoothViewModel bluetoothViewModel) {
    final status = bluetoothViewModel.connectionStatus;
    final statusName = bluetoothViewModel.getStatusName();

    Color statusColor;
    IconData statusIcon;

    switch (status) {
      case BluetoothConnectionStatus.connected:
        statusColor = AppTheme.successColor;
        statusIcon = Icons.bluetooth_connected;
        break;
      case BluetoothConnectionStatus.connecting:
        statusColor = AppTheme.warningColor;
        statusIcon = Icons.bluetooth_searching;
        break;
      case BluetoothConnectionStatus.disconnecting:
        statusColor = AppTheme.warningColor;
        statusIcon = Icons.bluetooth_disabled;
        break;
      case BluetoothConnectionStatus.disabled:
        statusColor = AppTheme.errorColor;
        statusIcon = Icons.bluetooth_disabled;
        break;
      case BluetoothConnectionStatus.unauthorized:
        statusColor = AppTheme.errorColor;
        statusIcon = Icons.block;
        break;
      case BluetoothConnectionStatus.disconnected:
      default:
        statusColor = AppTheme.textLightColor;
        statusIcon = Icons.bluetooth;
        break;
    }

    return Container(
      padding: const EdgeInsets.all(AppTheme.paddingMedium),
      color: statusColor.withOpacity(0.1),
      child: Row(
        children: [
          Icon(statusIcon, color: statusColor),
          const SizedBox(width: AppTheme.paddingRegular),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  statusName,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: statusColor,
                  ),
                ),
                if (status == BluetoothConnectionStatus.connected && bluetoothViewModel.selectedDevice != null)
                  Text(
                    bluetoothViewModel.selectedDevice!.name ?? 'Невідомий пристрій',
                    style: const TextStyle(
                      fontSize: AppTheme.fontSizeSmall,
                      color: AppTheme.textLightColor,
                    ),
                  ),
              ],
            ),
          ),
          if (status == BluetoothConnectionStatus.connected)
            AppButton(
              text: 'Відключити',
              type: AppButtonType.secondary,
              onPressed: () async {
                await bluetoothViewModel.disconnect();
              },
            ),
        ],
      ),
    );
  }

  /// Побудова порожнього списку пристроїв
  Widget _buildEmptyDevicesList(bool isScanning) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.bluetooth_searching,
            size: 80,
            color: AppTheme.textLightColor,
          ),
          const SizedBox(height: AppTheme.paddingMedium),
          Text(
            isScanning
                ? 'Пошук пристроїв...'
                : 'Пристрої не знайдено',
            style: const TextStyle(
              fontSize: AppTheme.fontSizeMedium,
              color: AppTheme.textLightColor,
            ),
          ),
          const SizedBox(height: AppTheme.paddingLarge),
          if (!isScanning)
            AppButton(
              text: 'Сканувати знову',
              icon: Icons.refresh,
              onPressed: () => _startScan(),
            ),
        ],
      ),
    );
  }

  /// Побудова списку пристроїв
  Widget _buildDevicesList(List<BluetoothDevice> devices, BluetoothViewModel bluetoothViewModel) {
    final isConnecting = bluetoothViewModel.connectionStatus == BluetoothConnectionStatus.connecting;

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.paddingMedium),
      itemCount: devices.length,
      itemBuilder: (context, index) {
        final device = devices[index];
        final isSelected = bluetoothViewModel.selectedDevice?.address == device.address;

        return Card(
          margin: const EdgeInsets.only(bottom: AppTheme.paddingRegular),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.borderRadiusRegular),
            side: isSelected
                ? const BorderSide(color: AppTheme.primaryColor, width: 2)
                : BorderSide.none,
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.all(AppTheme.paddingRegular),
            leading: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.bluetooth,
                color: AppTheme.primaryColor,
              ),
            ),
            title: Text(
              device.name?.isNotEmpty == true ? device.name! : 'Невідомий пристрій',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Text(
              device.address,
              style: const TextStyle(
                fontSize: AppTheme.fontSizeSmall,
                color: AppTheme.textLightColor,
              ),
            ),
            trailing: isSelected
                ? const Icon(
              Icons.check_circle,
              color: AppTheme.successColor,
            )
                : AppButton(
              text: 'Підключити',
              type: AppButtonType.primary,
              loadingState: isConnecting ? AppButtonLoadingState.loading : AppButtonLoadingState.idle,
              onPressed: isConnecting
                  ? null
                  : () async {
                try {
                  final result = await bluetoothViewModel.connectToDevice(device);

                  if (result && mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Успішно підключено'),
                        backgroundColor: AppTheme.successColor,
                      ),
                    );
                    Navigator.of(context).pop();
                  } else if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Помилка підключення'),
                        backgroundColor: AppTheme.errorColor,
                      ),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Помилка: ${e.toString()}'),
                        backgroundColor: AppTheme.errorColor,
                      ),
                    );
                  }
                }
              },
            ),
          ),
        );
      },
    );
  }
}

/// Контролер для оновлення списку
class RefreshController {
  /// Функція виклику при завершенні оновлення
  VoidCallback? _onRefreshCompleted;

  /// Встановлення функції виклику при завершенні оновлення
  set onRefreshCompleted(VoidCallback callback) {
    _onRefreshCompleted = callback;
  }

  /// Виклик функції завершення оновлення
  void refreshCompleted() {
    _onRefreshCompleted?.call();
  }

  /// Звільнення ресурсів
  void dispose() {
    _onRefreshCompleted = null;
  }
}