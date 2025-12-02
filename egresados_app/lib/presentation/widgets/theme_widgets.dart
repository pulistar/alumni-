import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/providers/theme_provider.dart';
import 'package:provider/provider.dart';

/// Widget para cambiar entre modo claro y oscuro
class ThemeToggleButton extends StatelessWidget {
  const ThemeToggleButton({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return IconButton(
      icon: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder: (child, animation) {
          return RotationTransition(
            turns: animation,
            child: FadeTransition(
              opacity: animation,
              child: child,
            ),
          );
        },
        child: Icon(
          themeProvider.isDarkMode 
              ? Icons.light_mode_rounded 
              : Icons.dark_mode_rounded,
          key: ValueKey(themeProvider.isDarkMode),
        ),
      ),
      onPressed: () {
        themeProvider.toggleTheme();
      },
      tooltip: themeProvider.isDarkMode 
          ? 'Modo claro' 
          : 'Modo oscuro',
    );
  }
}

/// Widget de ejemplo mostrando todas las micro-interacciones
class MicroInteractionsDemo extends StatelessWidget {
  const MicroInteractionsDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Micro-Interacciones'),
        actions: const [
          ThemeToggleButton(),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // TapAnimation
          const Text(
            'Tap Animation',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          
          TapAnimation(
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('¡Tap con animación!')),
              );
            },
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(
                child: Text(
                  'Presiona aquí',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 32),
          
          // PulseButton
          const Text(
            'Pulse Button',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          
          PulseButton(
            onPressed: () {},
            color: AppColors.secondary,
            width: double.infinity,
            height: 56,
            child: const Text(
              'Botón con Pulso',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          
          const SizedBox(height: 32),
          
          // AnimatedCard
          const Text(
            'Animated Cards',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          
          ...List.generate(3, (index) {
            return AnimatedCard(
              delay: index * 100,
              child: Card(
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: AppColors.primary,
                    child: Text('${index + 1}'),
                  ),
                  title: Text('Card ${index + 1}'),
                  subtitle: const Text('Con animación de entrada'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                ),
              ),
            );
          }),
          
          const SizedBox(height: 32),
          
          // RippleButton
          const Text(
            'Ripple Button',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          
          RippleButton(
            onTap: () {},
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.primary, width: 2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(
                child: Text(
                  'Botón con Ripple Effect',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 32),
          
          // SuccessAnimation
          const Text(
            'Success Animation',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          
          const Center(
            child: SuccessAnimation(size: 100),
          ),
        ],
      ),
    );
  }
}
