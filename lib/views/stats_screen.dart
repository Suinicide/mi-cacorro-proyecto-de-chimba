import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/stats_viewmodel.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => StatsViewModel()..loadWeeklyData(),
      child: const _StatsScreenContent(),
    );
  }
}

class _StatsScreenContent extends StatelessWidget {
  const _StatsScreenContent();

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<StatsViewModel>();
    final stats = viewModel.getWeeklyStats();
    
    final totalWeekly = stats['totalWeekly'] as int;
    final expectedWeekly = stats['expectedWeekly'] as int;
    final dailyStats = stats['dailyStats'] as Map<String, int>;
    final averageDaily = stats['averageDaily'] as int;
    final completionRate = stats['completionRate'] as double;
    final daysWithGoal = stats['daysWithGoal'] as int;

    if (viewModel.isLoading) {
      return Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFFDEEBFF), Colors.white],
            ),
          ),
          child: const Center(
            child: CircularProgressIndicator(),
          ),
        ),
      );
    }

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
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(
                        Icons.arrow_back_ios,
                        color: Color(0xFF3B82F6),
                      ),
                    ),
                    const Spacer(),
                    const Text(
                      'Estadísticas',
                      style: TextStyle(
                        color: Color(0xFF1E3A8A),
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () => viewModel.loadWeeklyData(),
                      icon: const Icon(
                        Icons.refresh,
                        color: Color(0xFF3B82F6),
                      ),
                    ),
                  ],
                ),
              ),
              
              Expanded( // ✅ SOLUCIÓN OVERFLOW: Usar Expanded
                child: _buildStatsContent(
                  context,
                  viewModel,
                  dailyStats,
                  totalWeekly,
                  expectedWeekly,
                  averageDaily,
                  completionRate,
                  daysWithGoal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatsContent(
    BuildContext context,
    StatsViewModel viewModel,
    Map<String, int> dailyStats,
    int totalWeekly,
    int expectedWeekly,
    int averageDaily,
    double completionRate,
    int daysWithGoal,
  ) {
    final days = viewModel.getWeekDays();
    final dayNames = viewModel.getFullDayNames();
    final weeklyData = viewModel.weeklyData;
    final maxData = viewModel.getMaxConsumption();
    
    // ✅ CORRECCIÓN DÍA DE LA SEMANA: Obtener el día actual (0=Domingo, 1=Lunes, etc.)
    final todayIndex = viewModel.getTodayIndex();

    return SingleChildScrollView( // ✅ SOLUCIÓN OVERFLOW: Scroll
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          // Selector de período
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildPeriodButton('Semana', true, viewModel),
                _buildPeriodButton('Mes', false, viewModel),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Días de la semana - CORREGIDO
          Row(
            children: List.generate(
              7,
              (index) => Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: index == todayIndex // ✅ USAR ÍNDICE CORREGIDO
                        ? const Color(0xFF60A5FA)
                        : const Color(0xFFBFDBFE),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    days[index],
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: index == todayIndex // ✅ USAR ÍNDICE CORREGIDO
                          ? Colors.white
                          : const Color(0xFF1E40AF),
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          
          // Gráfico de barras
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                const Text(
                  'Consumo de agua (ml) por día',
                  style: TextStyle(
                    color: Color(0xFF6B7280),
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  height: 200,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: List.generate(
                      7,
                      (index) {
                        final data = weeklyData.isNotEmpty 
                            ? weeklyData[index].milliliters 
                            : 0;
                        final height = maxData > 0 
                            ? (data / maxData) * 180.0
                            : 0.0;
                        return Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              '$data',
                              style: const TextStyle(
                                fontSize: 10,
                                color: Color(0xFF6B7280),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Container(
                              width: 32,
                              height: height,
                              decoration: BoxDecoration(
                                color: data >= 2000
                                    ? const Color(0xFF10B981)
                                    : const Color(0xFF93C5FD),
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Transform.rotate(
                              angle: -0.785,
                              child: Text(
                                dayNames[index],
                                style: const TextStyle(
                                  fontSize: 8,
                                  color: Color(0xFF9CA3AF),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          
          // Estadísticas principales
          _buildStatCard('Total semanal', '$totalWeekly mL', const Color(0xFF1E3A8A)),
          const SizedBox(height: 12),
          _buildStatCard('Meta semanal', '$expectedWeekly mL', const Color(0xFF1E3A8A)),
          const SizedBox(height: 12),
          _buildStatCard('Promedio diario', '$averageDaily mL', const Color(0xFF3B82F6)),
          const SizedBox(height: 12),
          _buildStatCard('Días con meta alcanzada', '$daysWithGoal/7', 
              daysWithGoal >= 4 ? const Color(0xFF10B981) : const Color(0xFFEF4444)),
          const SizedBox(height: 12),
          _buildStatCard('Tasa de cumplimiento', '${completionRate.toStringAsFixed(1)}%',
              completionRate >= 100 ? const Color(0xFF10B981) : const Color(0xFFF59E0B)),
          const SizedBox(height: 20), // ✅ ESPACIO EXTRA PARA EVITAR OVERFLOW
        ],
      ),
    );
  }

  Widget _buildPeriodButton(String period, bool isSelected, StatsViewModel viewModel) {
    return ElevatedButton(
      onPressed: () => viewModel.setSelectedPeriod(period),
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ? const Color(0xFF3B82F6) : Colors.transparent,
        foregroundColor: isSelected ? Colors.white : const Color(0xFF6B7280),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      ),
      child: Text(period),
    );
  }

  Widget _buildStatCard(String title, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded( // ✅ SOLUCIÓN OVERFLOW: Expanded para texto largo
            child: Text(
              title,
              style: const TextStyle(
                color: Color(0xFF1E3A8A),
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}