import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/home_viewmodel.dart';
import 'stats_screen.dart';
import 'alarms_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Escuchar cambios del ViewModel
    return ChangeNotifierProvider(
      create: (_) => HomeViewModel()..loadData(),
      child: const _HomeScreenContent(),
    );
  }
}

class _HomeScreenContent extends StatelessWidget {
  const _HomeScreenContent();

  @override
  Widget build(BuildContext context) {
    // Obtener el ViewModel
    final viewModel = context.watch<HomeViewModel>();

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFDEEBFF), Colors.white],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header con botones
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildIconButton(
                      context,
                      Icons.trending_up,
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const StatsScreen(),
                        ),
                      ),
                    ),
                    _buildIconButton(
                      context,
                      Icons.notifications,
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AlarmsScreen(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Información de meta
                    Text(
                      'Meta diaria: ${viewModel.waterIntake.dailyGoal} mL',
                      style: const TextStyle(
                        color: Color(0xFF1E3A8A),
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Litros del día: ${viewModel.waterIntake.milliliters} mL',
                      style: const TextStyle(
                        color: Color(0xFF3B82F6),
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 40),

                    // Gota de agua
                    Stack(
                      alignment: Alignment.center,
                      clipBehavior: Clip.none,
                      children: [
                        CustomPaint(
                          size: const Size(200, 240),
                          painter: WaterCirclePainter(
                            percentage: viewModel.percentage,
                          ),
                        ),

                        // Botón de agregar agua
                        Positioned(
                          bottom: -20,
                          child: _buildAddWaterButton(context, viewModel),
                        ),
                      ],
                    ),

                    const SizedBox(height: 60),

                    // Botón de recordatorio
                    ElevatedButton(
                      onPressed: () {
                        // Aquí podrías programar una notificación
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('¡Recordatorio activado! 💧'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1E3A8A),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 16,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 4,
                      ),
                      child: const Text(
                        'Recuerda tomar agua',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIconButton(
    BuildContext context,
    IconData icon,
    VoidCallback onPressed,
  ) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: const Color(0xFF60A5FA),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(icon, color: Colors.white, size: 28),
      ),
    );
  }

  Widget _buildAddWaterButton(BuildContext context, HomeViewModel viewModel) {
  return Container(
    width: 64,
    height: 64,
    decoration: BoxDecoration(
      color: Colors.white,
      shape: BoxShape.circle,
      border: Border.all(
        color: const Color(0xFF60A5FA),
        width: 4,
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.blue.withOpacity(0.3),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    child: IconButton(
      onPressed: () {
        // Verificar si ya se alcanzó el 100%
        if (viewModel.percentage >= 100.0) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('¡Ya alcanzaste tu meta diaria! 🎉'),
              duration: Duration(seconds: 2),
              backgroundColor: Colors.green,
            ),
          );
          return; // No agregar más agua
        }
        
        // Agregar agua normalmente
        viewModel.addWater(250); // Agregar 250ml (1 vaso)
        
        // Mensaje normal
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('¡Vaso de agua agregado! 💧'),
            duration: Duration(seconds: 2),
            backgroundColor: Colors.green,
          ),
        );
      },
      icon: const Icon(
        Icons.add,
        color: Color(0xFF3B82F6),
        size: 32,
      ),
    ),
  );
}
}

class WaterCirclePainter extends CustomPainter {
  final double percentage;

  WaterCirclePainter({required this.percentage});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2.0, size.height / 2.0);
    final radius = size.width / 2.0 * 0.8; // 80% del tamaño disponible

    // Pintura para el fondo del círculo (gris claro)
    final backgroundPaint = Paint()
      ..color = const Color(0xFFE5E7EB)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12.0
      ..isAntiAlias = true;

    // Pintura para el progreso (azul)
    final progressPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          const Color(0xFF3B82F6),
          const Color(0xFF60A5FA),
        ],
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12.0
      ..strokeCap = StrokeCap.round
      ..isAntiAlias = true;

    // Dibujar círculo de fondo
    canvas.drawCircle(center, radius, backgroundPaint);

    // Dibujar progreso (si hay porcentaje)
    if (percentage > 0.0) {
      final sweepAngle = (percentage / 100.0) * 2.0 * 3.14159; // Convertir a radianes
      final rect = Rect.fromCircle(center: center, radius: radius);
      
      canvas.drawArc(
        rect,
        -3.14159 / 2.0, // Comenzar desde la parte superior (-90°)
        sweepAngle,
        false,
        progressPaint,
      );
    }

    // Dibujar porcentaje en el centro
    final textStyle = TextStyle(
      color: const Color(0xFF1E3A8A),
      fontSize: 24.0,
      fontWeight: FontWeight.bold,
    );

    final textPainter = TextPainter(
      text: TextSpan(
        text: '${percentage.toStringAsFixed(0)}%',
        style: textStyle,
      ),
      textDirection: TextDirection.ltr,
    );
    
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        center.dx - textPainter.width / 2.0,
        center.dy - textPainter.height / 2.0,
      ),
    );

    // Dibujar información adicional debajo del porcentaje
    final infoTextStyle = TextStyle(
      color: const Color(0xFF6B7280),
      fontSize: 14.0,
    );

    final infoPainter = TextPainter(
      text: TextSpan(
        text: '${(percentage * 20).toInt()}/2000 ml', // Asumiendo que 100% = 2000ml
        style: infoTextStyle,
      ),
      textDirection: TextDirection.ltr,
    );
    
    infoPainter.layout();
    infoPainter.paint(
      canvas,
      Offset(
        center.dx - infoPainter.width / 2.0,
        center.dy + textPainter.height + 4.0,
      ),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return oldDelegate is WaterCirclePainter && 
           oldDelegate.percentage != percentage;
  }
}