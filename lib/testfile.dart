import 'package:flutter/material.dart';

class DataTableExample extends StatefulWidget {
  const DataTableExample({super.key});

  @override
  _DataTableExampleState createState() => _DataTableExampleState();
}

class _DataTableExampleState extends State<DataTableExample> {
  int? _hoveredRowIndex; // To track hovered row

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Table with Animation')),
      body: Center(
        child: SingleChildScrollView(
          child: DataTable(
            columns: const [
              DataColumn(label: Text('ID')),
              DataColumn(label: Text('Name')),
              DataColumn(label: Text('Age')),
            ],
            rows: List<DataRow>.generate(
              10,
              (index) {
                final bool isHovered = index == _hoveredRowIndex;
                final Color rowColor = index.isEven ? Colors.blue[100]! : Colors.white;

                return DataRow(
                  cells: [
                    DataCell(_buildAnimatedCell('ID $index', index, isHovered, rowColor)),
                    DataCell(_buildAnimatedCell('Name $index', index, isHovered, rowColor)),
                    DataCell(_buildAnimatedCell('Age $index', index, isHovered, rowColor)),
                  ],
                  onSelectChanged: (bool? selected) {
                    print('Row $index clicked');
                  },
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  // Custom animated row cell
  Widget _buildAnimatedCell(String text, int index, bool isHovered, Color baseColor) {
    return MouseRegion(
      onEnter: (_) {
        setState(() {
          _hoveredRowIndex = index; // Track hover
        });
      },
      onExit: (_) {
        setState(() {
          _hoveredRowIndex = null; // Reset hover
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: EdgeInsets.all(isHovered ? 16.0 : 8.0), // Hover effect
        color: isHovered ? Colors.grey[300] : baseColor, // Hover color
        child: Text(text),
      ),
    );
  }
}

