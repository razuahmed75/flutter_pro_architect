import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_pro_architect/flutter_pro_architect.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProArchitectExampleApp());
}

/// The main application class setting up the MaterialApp and standard dark/light themes.
class ProArchitectExampleApp extends StatelessWidget {
  const ProArchitectExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pro Architect Playroom',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6366F1), // Elegant Indigo
          brightness: Brightness.dark,
          surface: const Color(0xFF0F0F1A), // Deep dark premium space background
        ),
        textTheme: const TextTheme(
          titleLarge: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.5),
          bodyMedium: TextStyle(color: Color(0xFFC0C0CF)),
        ),
      ),
      home: const MainPlayroomScreen(),
    );
  }
}

/// The primary dashboard that holds all feature tabs.
class MainPlayroomScreen extends StatefulWidget {
  const MainPlayroomScreen({super.key});

  @override
  State<MainPlayroomScreen> createState() => _MainPlayroomScreenState();
}

class _MainPlayroomScreenState extends State<MainPlayroomScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _featureNameController = TextEditingController(text: 'user_profile');
  
  // States for name conversions
  String _snakeCaseOutput = 'user_profile';
  String _pascalCaseOutput = 'UserProfile';

  // State for templates
  String _selectedTemplateName = 'entity';
  String _generatedTemplateSource = '';

  // States for programmatic and CLI scaffolding
  Directory? _tempWorkspaceDir;
  bool _isGenerating = false;
  bool _generationSuccess = false;
  List<String> _generationLogs = [];
  int? _cliExitCode;
  List<FileSystemEntity> _generatedFiles = [];
  String? _selectedFileContent;
  String? _selectedFilePath;

  final List<Map<String, String>> _templateOptions = [
    {'label': 'Core UseCase (usecase.dart)', 'value': 'coreUseCase'},
    {'label': 'Core Failure (failure.dart)', 'value': 'coreFailure'},
    {'label': 'Domain Entity', 'value': 'entity'},
    {'label': 'Data Model', 'value': 'model'},
    {'label': 'Domain Repository', 'value': 'repository'},
    {'label': 'Remote Data Source', 'value': 'remoteDataSource'},
    {'label': 'Repository Implementation', 'value': 'repositoryImpl'},
    {'label': 'Get Items UseCase', 'value': 'getItemsUseCase'},
    {'label': 'Get Item By ID UseCase', 'value': 'getItemByIdUseCase'},
    {'label': 'Create Item UseCase', 'value': 'createItemUseCase'},
    {'label': 'Update Item UseCase', 'value': 'updateItemUseCase'},
    {'label': 'Patch Item UseCase', 'value': 'patchItemUseCase'},
    {'label': 'Delete Item UseCase', 'value': 'deleteItemUseCase'},
    {'label': 'BLoC Events', 'value': 'event'},
    {'label': 'BLoC States', 'value': 'state'},
    {'label': 'BLoC Core', 'value': 'bloc'},
    {'label': 'Presentation Page', 'value': 'page'},
    {'label': 'Presentation Card', 'value': 'card'},
    {'label': 'GetIt Dependency Injection', 'value': 'injection'},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    
    // Initial name calculation
    _updateNameCalculations(_featureNameController.text);
    _updateTemplateCode();

    // Set up a listener for real-time name conversion demo
    _featureNameController.addListener(() {
      setState(() {
        _updateNameCalculations(_featureNameController.text);
        _updateTemplateCode();
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _featureNameController.dispose();
    _cleanTempWorkspace();
    super.dispose();
  }

  /// Cleans up any files/folders created during testing
  void _cleanTempWorkspace() {
    try {
      if (_tempWorkspaceDir != null && _tempWorkspaceDir!.existsSync()) {
        _tempWorkspaceDir!.deleteSync(recursive: true);
      }
    } catch (_) {}
  }

  /// Demonstrates toSnakeCase and toPascalCase API utility methods
  void _updateNameCalculations(String input) {
    if (input.trim().isEmpty) {
      _snakeCaseOutput = '';
      _pascalCaseOutput = '';
      return;
    }
    // PUBLIC API DEMONSTRATION: toSnakeCase() and toPascalCase()
    _snakeCaseOutput = toSnakeCase(input);
    _pascalCaseOutput = toPascalCase(input);
  }

  /// Demonstrates Templates API by rendering templates dynamically in-app
  void _updateTemplateCode() {
    final snake = _snakeCaseOutput.isEmpty ? 'placeholder' : _snakeCaseOutput;
    final pascal = _pascalCaseOutput.isEmpty ? 'Placeholder' : _pascalCaseOutput;

    // PUBLIC API DEMONSTRATION: Templates class static methods
    switch (_selectedTemplateName) {
      case 'coreUseCase':
        _generatedTemplateSource = Templates.coreUseCase();
        break;
      case 'coreFailure':
        _generatedTemplateSource = Templates.coreFailure();
        break;
      case 'entity':
        _generatedTemplateSource = Templates.entity(featureSnake: snake, featurePascal: pascal);
        break;
      case 'model':
        _generatedTemplateSource = Templates.model(featureSnake: snake, featurePascal: pascal);
        break;
      case 'repository':
        _generatedTemplateSource = Templates.repository(featureSnake: snake, featurePascal: pascal);
        break;
      case 'remoteDataSource':
        _generatedTemplateSource = Templates.remoteDataSource(featureSnake: snake, featurePascal: pascal);
        break;
      case 'repositoryImpl':
        _generatedTemplateSource = Templates.repositoryImpl(featureSnake: snake, featurePascal: pascal);
        break;
      case 'getItemsUseCase':
        _generatedTemplateSource = Templates.getItemsUseCase(featureSnake: snake, featurePascal: pascal);
        break;
      case 'getItemByIdUseCase':
        _generatedTemplateSource = Templates.getItemByIdUseCase(featureSnake: snake, featurePascal: pascal);
        break;
      case 'createItemUseCase':
        _generatedTemplateSource = Templates.createItemUseCase(featureSnake: snake, featurePascal: pascal);
        break;
      case 'updateItemUseCase':
        _generatedTemplateSource = Templates.updateItemUseCase(featureSnake: snake, featurePascal: pascal);
        break;
      case 'patchItemUseCase':
        _generatedTemplateSource = Templates.patchItemUseCase(featureSnake: snake, featurePascal: pascal);
        break;
      case 'deleteItemUseCase':
        _generatedTemplateSource = Templates.deleteItemUseCase(featureSnake: snake, featurePascal: pascal);
        break;
      case 'event':
        _generatedTemplateSource = Templates.event(featureSnake: snake, featurePascal: pascal);
        break;
      case 'state':
        _generatedTemplateSource = Templates.state(featureSnake: snake, featurePascal: pascal);
        break;
      case 'bloc':
        _generatedTemplateSource = Templates.bloc(featureSnake: snake, featurePascal: pascal);
        break;
      case 'page':
        _generatedTemplateSource = Templates.page(featureSnake: snake, featurePascal: pascal);
        break;
      case 'card':
        _generatedTemplateSource = Templates.card(featureSnake: snake, featurePascal: pascal);
        break;
      case 'injection':
        _generatedTemplateSource = Templates.injection(featureSnake: snake, featurePascal: pascal);
        break;
      default:
        _generatedTemplateSource = '// Template not found';
    }
  }

  /// Sets up a safe, writable environment for generators to write files
  Future<Directory> _prepareWritableDirectory() async {
    _cleanTempWorkspace();
    final tempDir = Directory.systemTemp.createTempSync('pro_architect_playroom_');
    _tempWorkspaceDir = tempDir;
    
    // Change active working directory so files are generated in this temporary folder
    Directory.current = tempDir;

    // Create a dummy pubspec.yaml inside the working directory so CLI commands validate successfully
    final dummyPubspec = File('${tempDir.path}/pubspec.yaml');
    await dummyPubspec.writeAsString('''
name: mock_app
description: A mock app to test flutter_pro_architect.
version: 1.0.0
environment:
  sdk: '>=3.0.0 <4.0.0'
''');

    return tempDir;
  }

  /// Scan generated directory structure recursively
  void _scanGeneratedFiles() {
    if (_tempWorkspaceDir == null) return;
    final list = _tempWorkspaceDir!.listSync(recursive: true);
    
    // Sort directories first, then files alphabetically
    list.sort((a, b) {
      if (a is Directory && b is File) return -1;
      if (a is File && b is Directory) return 1;
      return a.path.compareTo(b.path);
    });

    setState(() {
      _generatedFiles = list;
      _selectedFileContent = null;
      _selectedFilePath = null;
    });
  }

  /// PUBLIC API DEMONSTRATION: Running FeatureGenerator programmatically
  Future<void> _runFeatureGenerator() async {
    if (_snakeCaseOutput.isEmpty) return;
    setState(() {
      _isGenerating = true;
      _cliExitCode = null;
      _generationLogs = ['Initializing programmatic FeatureGenerator...', 'Setting Directory.current to safe workspace...'];
    });

    try {
      final tempDir = await _prepareWritableDirectory();
      _generationLogs.add('Temporary directory allocated: ${tempDir.path}');

      // PUBLIC API DEMONSTRATION: Instantiating and using FeatureGenerator
      final generator = FeatureGenerator(colorEnabled: false);
      _generationLogs.add('Invoking FeatureGenerator.generate("$_snakeCaseOutput")...');
      
      // PUBLIC API DEMONSTRATION: Capturing and reading GenerationSummary
      final GenerationSummary summary = await generator.generate(_snakeCaseOutput);

      setState(() {
        _generationSuccess = summary.success;
        _generationLogs.addAll(summary.messages);
        _isGenerating = false;
      });

      _scanGeneratedFiles();
    } catch (e) {
      setState(() {
        _generationSuccess = false;
        _generationLogs.add('EXCEPTION ENCOUNTERED: $e');
        _isGenerating = false;
      });
    }
  }

  /// PUBLIC API DEMONSTRATION: Running FlutterProArchitectCli
  Future<void> _runCliCommand() async {
    if (_snakeCaseOutput.isEmpty) return;
    setState(() {
      _isGenerating = true;
      _cliExitCode = null;
      _generationLogs = ['Initializing FlutterProArchitectCli...', 'Setting Directory.current to safe workspace...'];
    });

    try {
      final tempDir = await _prepareWritableDirectory();
      _generationLogs.add('Temporary directory allocated: ${tempDir.path}');
      _generationLogs.add('Created mock pubspec.yaml for CLI execution check.');

      // PUBLIC API DEMONSTRATION: Instantiating and using FlutterProArchitectCli
      final cli = FlutterProArchitectCli();
      final command = 'create_bloc_$_snakeCaseOutput';
      _generationLogs.add('Executing command: ${FlutterProArchitectCli.executableName} $command --no-color');

      final exitCode = await cli.run([command, '--no-color']);
      
      setState(() {
        _cliExitCode = exitCode;
        _generationSuccess = (exitCode == 0);
        _generationLogs.add('CLI Exited with Code: $exitCode');
        if (exitCode == 0) {
          _generationLogs.add('Scaffolding generated successfully.');
        } else {
          _generationLogs.add('Scaffolding failed. Check console output.');
        }
        _isGenerating = false;
      });

      _scanGeneratedFiles();
    } catch (e) {
      setState(() {
        _generationSuccess = false;
        _generationLogs.add('EXCEPTION ENCOUNTERED: $e');
        _isGenerating = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(Icons.architecture, color: Color(0xFF818CF8), size: 30),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Pro Architect Playroom',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontSize: 20,
                        letterSpacing: 0.5,
                      ),
                ),
                const Text(
                  'Live interactive demonstration & workbench',
                  style: TextStyle(fontSize: 11, color: Color(0x99C0C0CF)),
                ),
              ],
            ),
          ],
        ),
        elevation: 0,
        backgroundColor: const Color(0xFF161626),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: const Color(0xFF6366F1),
          labelColor: Colors.white,
          unselectedLabelColor: const Color(0x88C0C0CF),
          indicatorSize: TabBarIndicatorSize.tab,
          tabs: const [
            Tab(icon: Icon(Icons.abc), text: 'Names'),
            Tab(icon: Icon(Icons.code), text: 'Templates'),
            Tab(icon: Icon(Icons.settings_suggest), text: 'Generator'),
            Tab(icon: Icon(Icons.terminal), text: 'CLI Runner'),
          ],
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF161626),
              Color(0xFF0F0F1A),
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Common feature name controller
              _buildFeatureInputSection(),
              const SizedBox(height: 16),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildNameConverterTab(),
                    _buildTemplatesExplorerTab(),
                    _buildGeneratorTab(programmatic: true),
                    _buildGeneratorTab(programmatic: false),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureInputSection() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E30),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF312E81), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6366F1).withValues(alpha:0.1),
            blurRadius: 16,
            offset: const Offset(0, 4),
          )
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'ACTIVE WORKBENCH FEATURE NAME',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: Color(0xFF818CF8),
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _featureNameController,
                  decoration: const InputDecoration(
                    hintText: 'Enter feature name (e.g. user_profile, product_details)...',
                    hintStyle: TextStyle(color: Color(0x55C0C0CF)),
                    border: InputBorder.none,
                    isDense: true,
                  ),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    fontFamily: 'monospace',
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.clear, color: Color(0xFF818CF8)),
                onPressed: () => _featureNameController.clear(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // TAB 1: Name converter demonstration
  Widget _buildNameConverterTab() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoBanner(
            'Dynamic casing conversion helper methods are essential for translating raw developer inputs (like commands) into proper code structures, class names, and files.',
          ),
          const SizedBox(height: 16),
          _buildValueDisplayCard(
            title: 'toSnakeCase(input)',
            description: 'Converts any raw module name into a lowercase, underscore-delimited format suitable for directories and filenames.',
            value: _snakeCaseOutput,
            accentColor: const Color(0xFFF59E0B),
            exampleUsage: "toSnakeCase('${_featureNameController.text}')",
          ),
          const SizedBox(height: 16),
          _buildValueDisplayCard(
            title: 'toPascalCase(input)',
            description: 'Converts any raw module name into CamelCase starting with a capital letter, perfectly formatting BLoCs, Entities, and Widget Classes.',
            value: _pascalCaseOutput,
            accentColor: const Color(0xFF10B981),
            exampleUsage: "toPascalCase('${_featureNameController.text}')",
          ),
        ],
      ),
    );
  }

  // TAB 2: Templates Explorer
  Widget _buildTemplatesExplorerTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'Select Code Template:',
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1E30),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFF4338CA)),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedTemplateName,
                    dropdownColor: const Color(0xFF1E1E30),
                    items: _templateOptions.map((opt) {
                      return DropdownMenuItem<String>(
                        value: opt['value']!,
                        child: Text(
                          opt['label']!,
                          style: const TextStyle(fontSize: 14, color: Colors.white),
                        ),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setState(() {
                          _selectedTemplateName = val;
                          _updateTemplateCode();
                        });
                      }
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _buildInfoBanner(
          'Static catalog generators dynamically produce high-quality boilerplates. Toggle templates above to view the generated outputs matching your current active name.',
        ),
        const SizedBox(height: 12),
        Expanded(
          child: _buildCodeViewer(
            title: 'Generated Source Code Preview',
            code: _generatedTemplateSource,
          ),
        ),
      ],
    );
  }

  // TAB 3 & 4: Generator & CLI Workspace simulator
  Widget _buildGeneratorTab({required bool programmatic}) {
    final title = programmatic ? 'Programmatic Scaffold' : 'Command Line Interface (CLI)';
    final subtitle = programmatic 
        ? 'Simulates `FeatureGenerator` API usage' 
        : 'Simulates `FlutterProArchitectCli().run()` execution';

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Operations and log output panel
        Expanded(
          flex: 4,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: programmatic 
                        ? [const Color(0xFF4F46E5), const Color(0xFF7C3AED)]
                        : [const Color(0xFF0D9488), const Color(0xFF0F766E)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
                    ),
                    Text(
                      subtitle,
                      style: const TextStyle(fontSize: 12, color: Color(0xFFC0C0CF)),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      icon: _isGenerating 
                          ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)) 
                          : Icon(programmatic ? Icons.play_arrow : Icons.terminal_outlined),
                      label: Text(_isGenerating ? 'Processing...' : (programmatic ? 'Run Generator' : 'Execute CLI Command')),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: _isGenerating ? null : (programmatic ? _runFeatureGenerator : _runCliCommand),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'SIMULATION OUTPUT STREAM & LOGS',
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF818CF8), letterSpacing: 1),
                  ),
                  if (_cliExitCode != null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: _cliExitCode == 0 ? Colors.green.withValues(alpha:0.2) : Colors.red.withValues(alpha:0.2),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: _cliExitCode == 0 ? Colors.green : Colors.red),
                      ),
                      child: Text(
                        'Exit Code: $_cliExitCode',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          color: _cliExitCode == 0 ? Colors.greenAccent : Colors.redAccent,
                        ),
                      ),
                    )
                  else if (_tempWorkspaceDir != null && !_isGenerating)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: _generationSuccess ? Colors.green.withValues(alpha:0.2) : Colors.red.withValues(alpha:0.2),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: _generationSuccess ? Colors.green : Colors.red),
                      ),
                      child: Text(
                        _generationSuccess ? 'Success' : 'Failed',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          color: _generationSuccess ? Colors.greenAccent : Colors.redAccent,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 6),
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: const Color(0xFF09090F),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF1E1E30)),
                  ),
                  padding: const EdgeInsets.all(12),
                  child: _generationLogs.isEmpty
                      ? const Center(child: Text('Press execution button to start workspace generation simulation', style: TextStyle(color: Color(0x33C0C0CF), fontSize: 13), textAlign: TextAlign.center))
                      : ListView.builder(
                          itemCount: _generationLogs.length,
                          itemBuilder: (context, index) {
                            final log = _generationLogs[index];
                            Color logColor = Colors.white;
                            if (log.startsWith('Created:')) {
                              logColor = Colors.greenAccent;
                            } else if (log.contains('Exists:')) {
                              logColor = Colors.yellowAccent;
                            } else if (log.contains('EXCEPTION') || log.contains('Error:')) {
                              logColor = Colors.redAccent;
                            } else if (log.startsWith('Temporary') || log.startsWith('Executing')) {
                              logColor = const Color(0xFF818CF8);
                            }
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 2.0),
                              child: Text(
                                log,
                                style: TextStyle(fontFamily: 'monospace', fontSize: 12, color: logColor),
                              ),
                            );
                          },
                        ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        // File explorer panel
        Expanded(
          flex: 5,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'GENERATED FILE EXPLORER',
                style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF818CF8), letterSpacing: 1),
              ),
              const SizedBox(height: 6),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E1E30),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF312E81)),
                  ),
                  child: Row(
                    children: [
                      // File tree list
                      Expanded(
                        flex: 3,
                        child: Container(
                          decoration: const BoxDecoration(
                            border: Border(right: BorderSide(color: Color(0xFF312E81))),
                          ),
                          child: _generatedFiles.isEmpty
                              ? const Center(child: Text('No files scaffolded yet', style: TextStyle(color: Color(0x44C0C0CF), fontSize: 12), textAlign: TextAlign.center))
                              : ListView.builder(
                                  itemCount: _generatedFiles.length,
                                  itemBuilder: (context, index) {
                                    final entity = _generatedFiles[index];
                                    final isDir = entity is Directory;
                                    // Make path relative for cleaner display
                                    final relPath = entity.path.replaceFirst(_tempWorkspaceDir!.path, '');
                                    
                                    if (relPath == '/pubspec.yaml' || relPath.isEmpty) return const SizedBox.shrink();

                                    final name = relPath.split('/').last;
                                    final depth = relPath.split('/').length - 2;

                                    return InkWell(
                                      onTap: isDir 
                                          ? null 
                                          : () async {
                                              try {
                                                final content = await (entity as File).readAsString();
                                                setState(() {
                                                  _selectedFileContent = content;
                                                  _selectedFilePath = relPath;
                                                });
                                              } catch (e) {
                                                setState(() {
                                                  _selectedFileContent = 'Error reading file: $e';
                                                  _selectedFilePath = relPath;
                                                });
                                              }
                                            },
                                      child: Padding(
                                        padding: EdgeInsets.only(
                                          left: 8.0 + (depth * 12.0),
                                          top: 6.0,
                                          bottom: 6.0,
                                        ),
                                        child: Row(
                                          children: [
                                            Icon(
                                              isDir ? Icons.folder : Icons.insert_drive_file,
                                              size: 16,
                                              color: isDir ? const Color(0xFFF59E0B) : const Color(0xFF818CF8),
                                            ),
                                            const SizedBox(width: 6),
                                            Expanded(
                                              child: Text(
                                                name,
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: _selectedFilePath == relPath ? Colors.white : const Color(0xFFC0C0CF),
                                                  fontWeight: _selectedFilePath == relPath ? FontWeight.bold : FontWeight.normal,
                                                  fontFamily: 'monospace',
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                        ),
                      ),
                      // File content previewer
                      Expanded(
                        flex: 4,
                        child: Container(
                          color: const Color(0xFF0F0F1A),
                          padding: const EdgeInsets.all(8.0),
                          child: _selectedFileContent == null
                              ? const Center(child: Text('Tap a file to inspect its scaffolded code', style: TextStyle(color: Color(0x33C0C0CF), fontSize: 11), textAlign: TextAlign.center))
                              : Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF1E1E30),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        _selectedFilePath ?? '',
                                        style: const TextStyle(fontSize: 10, fontFamily: 'monospace', color: Color(0xFF818CF8)),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Expanded(
                                      child: SingleChildScrollView(
                                        scrollDirection: Axis.horizontal,
                                        child: SingleChildScrollView(
                                          child: Text(
                                            _selectedFileContent!,
                                            style: const TextStyle(fontFamily: 'monospace', fontSize: 10, color: Color(0xFFC0C0CF)),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoBanner(String text) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E1B4B),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF312E81)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline, color: Color(0xFF818CF8), size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 12, color: Color(0xFFC7D2FE), height: 1.4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildValueDisplayCard({
    required String title,
    required String description,
    required String value,
    required Color accentColor,
    required String exampleUsage,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E30),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF2E2E3F)),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 6,
                height: 24,
                decoration: BoxDecoration(
                  color: accentColor,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white, fontFamily: 'monospace'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: const TextStyle(fontSize: 13, color: Color(0x88C0C0CF)),
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFF0F0F1A),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFF282837)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    value.isEmpty ? '—' : value,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: value.isEmpty ? Colors.grey : accentColor,
                      fontFamily: 'monospace',
                    ),
                  ),
                ),
                if (value.isNotEmpty)
                  IconButton(
                    icon: const Icon(Icons.copy_outlined, size: 18, color: Color(0x88C0C0CF)),
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: value));
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Copied "$value" to clipboard!'),
                          backgroundColor: accentColor.withValues(alpha:0.9),
                        ),
                      );
                    },
                  ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Example API Usage: $exampleUsage',
            style: const TextStyle(fontSize: 11, color: Color(0x44C0C0CF), fontFamily: 'monospace'),
          ),
        ],
      ),
    );
  }

  Widget _buildCodeViewer({required String title, required String code}) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF09090F),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF1E1E30)),
      ),
      child: Column(
        children: [
          // Header Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: const BoxDecoration(
              color: Color(0xFF1E1E30),
              borderRadius: BorderRadius.only(topLeft: Radius.circular(12), topRight: Radius.circular(12)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                Row(
                  children: [
                    const Text('Dart', style: TextStyle(fontSize: 11, color: Color(0x66C0C0CF))),
                    const SizedBox(width: 12),
                    IconButton(
                      icon: const Icon(Icons.copy_outlined, size: 16, color: Color(0x88C0C0CF)),
                      constraints: const BoxConstraints(),
                      padding: EdgeInsets.zero,
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: code));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Source code copied to clipboard!'),
                            backgroundColor: Color(0xFF6366F1),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Code Box
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                child: SelectableText(
                  code,
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 12,
                    color: Color(0xFFC0C0CF),
                    height: 1.4,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Simple color helper for typography styling inside elements
extension ColorHelper on TextStyle {
  TextStyle get whiteBD => copyWith(color: const Color(0xFFC0C0CF));
}
