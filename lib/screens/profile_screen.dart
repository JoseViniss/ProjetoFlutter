// lib/screens/profile_screen.dart

import 'package:flutter/material.dart';
import 'package:pet_center/providers/auth_provider.dart'; 
import 'package:pet_center/services/db_service.dart';    
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart'; 
import 'package:pet_center/screens/my_dogs_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int _dogCount = 0;
  Map<String, int> _vaccinationStats = {};
  bool _isLoading = true;
  bool _isInit = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isInit) {
      _loadDashboardData();
    }
    _isInit = false;
  }

  Future<void> _loadDashboardData() async {
    setState(() => _isLoading = true);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final dbService = Provider.of<DBService>(context, listen: false);
    final userId = authProvider.currentUser?.id;
    if (userId == null) return; 

    final dogCount = await dbService.countDogsForUser(userId);
    final vacStats = await dbService.getVaccinationStatsForUser(userId);

    setState(() {
      _dogCount = dogCount;
      _vaccinationStats = vacStats;
      _isLoading = false;
    });
  }

  // --- NOVA FUNÇÃO DE NAVEGAÇÃO ---
  void _navigateToMyDogs() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const MyDogsScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.currentUser;

    if (user == null) {
      return const Center(child: Text('Erro: Nenhum usuário logado.'));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Meu Perfil'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Sair',
            onPressed: () => authProvider.logout(),
          )
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView( // O SingleChildScrollView agora é SEGURO
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // --- Card do Perfil ---
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(user.nome, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 16),
                          _buildProfileRow(Icons.email_outlined, user.email),
                          _buildProfileRow(Icons.phone_outlined, user.telefone ?? 'Não informado'),
                          _buildProfileRow(Icons.location_city_outlined, user.cidade ?? 'Não informada'),
                          const Divider(height: 24),
                          Text('Sobre:', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          Text(user.sobre ?? 'Nenhuma descrição fornecida.'),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 24),

                  // --- Seção do BI (Dashboard) ---
                  Text(
                    'Meu Dashboard (BI)',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),

                  Card(
                    elevation: 2,
                    child: InkWell( 
                      onTap: _navigateToMyDogs,
                      child: ListTile(
                        leading: Icon(Icons.pets, color: Theme.of(context).primaryColor),
                        title: Text('$_dogCount', style: Theme.of(context).textTheme.headlineMedium),
                        subtitle: const Text('Cães cadastrados por você'),
                        trailing: const Icon(Icons.arrow_forward_ios), // Seta
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  _buildPieChart(context),

                ],
              ),
            ),
    );
  }

  // Widget auxiliar para as linhas do perfil
  Widget _buildProfileRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey[600], size: 20),
          const SizedBox(width: 16),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 16))),
        ],
      ),
    );
  }

  // Widget auxiliar para o Gráfico de Pizza (BI)
  Widget _buildPieChart(BuildContext context) {
    if (_vaccinationStats.isEmpty) {
      return const Card(
        elevation: 2,
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Center(child: Text('Cadastre um cão para ver o gráfico de vacinação.')),
        ),
      );
    }

    // Prepara os dados para o gráfico
    List<PieChartSectionData> sections = _vaccinationStats.entries.map((entry) {
      final Color color = _getColorForStatus(entry.key);
      return PieChartSectionData(
        color: color,
        value: entry.value.toDouble(),
        title: '${entry.value}',
        radius: 80,
        titleStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
      );
    }).toList();

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              'Status de Vacinação (dos seus cães)',
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 200,
              child: PieChart(PieChartData(sections: sections)),
            ),
            const SizedBox(height: 16),
            // Legenda
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: _vaccinationStats.keys.map((key) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Row(
                    children: [
                      Container(width: 16, height: 16, color: _getColorForStatus(key)),
                      const SizedBox(width: 4),
                      Text(key),
                    ],
                  ),
                );
              }).toList(),
            )
          ],
        ),
      ),
    );
  }

  // Função auxiliar para dar cores ao gráfico
  Color _getColorForStatus(String status) {
    switch (status.toLowerCase()) {
      case 'vacinado':
        return Colors.green;
      case 'pendente':
        return Colors.orange;
      case 'não vacinado':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}