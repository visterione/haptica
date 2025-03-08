// lib/presentation/pages/profile_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_theme.dart';
import '../navigation/app_router.dart';
import '../viewmodels/auth_viewmodel.dart';
import '../widgets/app_button.dart';
import '../widgets/app_scaffold.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthViewModel>(
      builder: (context, authViewModel, child) {
        final isAuthenticated = authViewModel.isAuthenticated;
        final isLoading = authViewModel.isLoading;

        if (isLoading) {
          return AppScaffold(
            title: 'Профіль',
            currentTab: AppTab.profile,
            body: const Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        return AppScaffold(
          title: 'Профіль',
          currentTab: AppTab.profile,
          body: Padding(
            padding: const EdgeInsets.all(AppTheme.paddingMedium),
            child: isAuthenticated
                ? _buildAuthenticatedProfile(context, authViewModel)
                : _buildUnauthenticatedProfile(context, authViewModel),
          ),
        );
      },
    );
  }

  Widget _buildAuthenticatedProfile(BuildContext context, AuthViewModel authViewModel) {
    final user = authViewModel.currentUser!;

    return Column(
      children: [
        const SizedBox(height: AppTheme.paddingLarge),

        // Аватар користувача
        CircleAvatar(
          radius: 50,
          backgroundColor: AppTheme.primaryColor.withOpacity(0.2),
          backgroundImage: user.photoUrl != null ? NetworkImage(user.photoUrl!) : null,
          child: user.photoUrl == null
              ? Text(
            user.displayName?.isNotEmpty == true
                ? user.displayName!.substring(0, 1).toUpperCase()
                : '?',
            style: const TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryColor,
            ),
          )
              : null,
        ),

        const SizedBox(height: AppTheme.paddingMedium),

        // Ім'я користувача
        Text(
          user.displayName ?? 'Користувач',
          style: const TextStyle(
            fontSize: AppTheme.fontSizeXLarge,
            fontWeight: FontWeight.bold,
          ),
        ),

        // Email користувача
        Text(
          user.email ?? '',
          style: const TextStyle(
            fontSize: AppTheme.fontSizeRegular,
            color: AppTheme.textLightColor,
          ),
        ),

        const SizedBox(height: AppTheme.paddingLarge),
        const Divider(),

        // Список опцій
        ListTile(
          leading: const Icon(Icons.settings),
          title: const Text('Налаштування'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            Navigator.of(context).pushNamed(AppRouter.settings);
          },
        ),

        ListTile(
          leading: const Icon(Icons.history),
          title: const Text('Історія розпізнавання'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            // Навігація до історії розпізнавання
          },
        ),

        // Додаємо новий ListTile для "Допомога та підтримка"
        ListTile(
          leading: const Icon(Icons.help_outline),
          title: const Text('Допомога та підтримка'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            Navigator.of(context).pushNamed(AppRouter.help);
          },
        ),

        ListTile(
          leading: const Icon(Icons.device_hub),
          title: const Text('Мої пристрої'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            // Навігація до сторінки пристроїв
          },
        ),

        const Spacer(),

        // Кнопка виходу
        AppButton(
          text: 'Вийти з облікового запису',
          type: AppButtonType.danger,
          onPressed: () async {
            final confirmed = await showDialog<bool>(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Вихід з облікового запису'),
                content: const Text('Ви дійсно бажаєте вийти з облікового запису?'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: const Text('Скасувати'),
                  ),
                  ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    child: const Text('Вийти'),
                  ),
                ],
              ),
            );

            if (confirmed == true) {
              await authViewModel.signOut();
            }
          },
        ),

        const SizedBox(height: AppTheme.paddingMedium),
      ],
    );
  }

  Widget _buildUnauthenticatedProfile(BuildContext context, AuthViewModel authViewModel) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.account_circle,
            size: 100,
            color: AppTheme.primaryColor,
          ),

          const SizedBox(height: AppTheme.paddingMedium),

          const Text(
            'Увійдіть, щоб отримати доступ до всіх функцій',
            style: TextStyle(
              fontSize: AppTheme.fontSizeMedium,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: AppTheme.paddingRegular),

          const Text(
            'Авторизація дозволить вам синхронізувати налаштування та отримати доступ до персоналізованих функцій.',
            style: TextStyle(
              fontSize: AppTheme.fontSizeRegular,
              color: AppTheme.textLightColor,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: AppTheme.paddingLarge),

          // Кнопка входу через Google
          GestureDetector(
            onTap: () async {
              try {
                final success = await authViewModel.signInWithGoogle();
                if (!success && context.mounted && !authViewModel.isAuthenticated) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(authViewModel.error ?? 'Помилка входу'),
                      backgroundColor: AppTheme.errorColor,
                    ),
                  );
                }
              } catch (e) {
                // Ігноруємо цю помилку, якщо аутентифікація успішна
                if (!authViewModel.isAuthenticated && context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Помилка входу: ${e.toString()}'),
                      backgroundColor: AppTheme.errorColor,
                    ),
                  );
                }
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppTheme.paddingMedium,
                vertical: AppTheme.paddingRegular,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppTheme.borderRadiusRegular),
                boxShadow: AppTheme.lightShadow,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(
                    'assets/images/google_logo.png',
                    height: 24,
                  ),
                  const SizedBox(width: AppTheme.paddingRegular),
                  const Text(
                    'Увійти з Google',
                    style: TextStyle(
                      fontSize: AppTheme.fontSizeRegular,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: AppTheme.paddingLarge),
        ],
      ),
    );
  }
}