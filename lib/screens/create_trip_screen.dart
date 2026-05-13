import 'package:flutter/material.dart';
import '../models/tour.dart';

class CreateTripScreen extends StatefulWidget {
  const CreateTripScreen({Key? key}) : super(key: key);

  @override
  _CreateTripScreenState createState() => _CreateTripScreenState();
}

class _CreateTripScreenState extends State<CreateTripScreen> {
  final TextEditingController _locationController = TextEditingController(text: 'Danang, Vietnam');
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _timeFromController = TextEditingController();
  final TextEditingController _timeToController = TextEditingController();
  int _numTravelers = 1;
  final TextEditingController _feeController = TextEditingController();
  final List<String> _languages = ['Korean', 'English', 'Vietnamese'];
  final Set<String> _selectedLanguages = {'Korean', 'English'};
  final List<_Attraction> _attractions = [
    _Attraction('Dragon Bridge', 'https://picsum.photos/seed/dragon/300/200'),
    _Attraction('Cham Museum', 'https://picsum.photos/seed/cham/300/200'),
    _Attraction('My Khe Beach', 'https://picsum.photos/seed/mykhe/300/200'),
  ];

  @override
  void dispose() {
    _locationController.dispose();
    _dateController.dispose();
    _timeFromController.dispose();
    _timeToController.dispose();
    _feeController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
    );
    if (date != null) {
      _dateController.text = '${date.month}/${date.day}/${date.year.toString().substring(2)}';
    }
  }

  Future<void> _selectTime(TextEditingController controller) async {
    final time = await showTimePicker(context: context, initialTime: TimeOfDay.now());
    if (time != null) {
      controller.text = time.format(context);
    }
  }

  void _toggleAttraction(int index) {
    setState(() {
      _attractions[index].selected = !_attractions[index].selected;
    });
  }

  void _toggleLanguage(String language) {
    setState(() {
      if (_selectedLanguages.contains(language)) {
        _selectedLanguages.remove(language);
      } else {
        _selectedLanguages.add(language);
      }
    });
  }

  void _saveTrip() {
    if (_locationController.text.trim().isEmpty) {
      _showSnackbar('Vui lòng nhập địa điểm');
      return;
    }
    if (_dateController.text.trim().isEmpty) {
      _showSnackbar('Vui lòng chọn ngày');
      return;
    }
    if (_timeFromController.text.trim().isEmpty || _timeToController.text.trim().isEmpty) {
      _showSnackbar('Vui lòng chọn khoảng thời gian');
      return;
    }
    if (_feeController.text.trim().isEmpty || int.tryParse(_feeController.text.trim()) == null) {
      _showSnackbar('Vui lòng nhập phí hợp lệ');
      return;
    }

    final selected = _attractions.where((e) => e.selected).toList();
    final tour = Tour(
      title: 'Chuyến đến ${_locationController.text.trim()}',
      location: _locationController.text.trim(),
      price: int.parse(_feeController.text.trim()),
      image: selected.isNotEmpty ? selected.first.image : 'https://picsum.photos/300/200',
      description:
          'Date: ${_dateController.text}\nTime: ${_timeFromController.text} - ${_timeToController.text}\nTravelers: $_numTravelers\nLanguages: ${_selectedLanguages.join(', ')}',
      status: 'Next',
    );

    Navigator.pop(context, tour);
  }

  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 8),
                _buildLabel('Bạn muốn khám phá đâu'),
                const SizedBox(height: 8),
                _buildField(
                  controller: _locationController,
                  hint: 'Đà Nẵng, Việt Nam',
                  icon: Icons.location_on,
                  readOnly: false,
                ),
                const SizedBox(height: 16),

                _buildLabel('Ngày'),
                const SizedBox(height: 8),
                _buildField(
                  controller: _dateController,
                  hint: 'mm/yy',
                  icon: Icons.calendar_today,
                  readOnly: true,
                  onTap: _selectDate,
                ),
                const SizedBox(height: 16),

                _buildLabel('Thời gian'),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: _buildField(
                        controller: _timeFromController,
                        hint: 'Bắt đầu',
                        icon: Icons.access_time,
                        readOnly: true,
                        onTap: () => _selectTime(_timeFromController),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildField(
                        controller: _timeToController,
                        hint: 'Kết thúc',
                        icon: Icons.access_time,
                        readOnly: true,
                        onTap: () => _selectTime(_timeToController),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                _buildLabel('Số lượng khách'),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove_circle_outline),
                        onPressed: () {
                          if (_numTravelers > 1) setState(() => _numTravelers--);
                        },
                      ),
                      Text('$_numTravelers', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      IconButton(
                        icon: const Icon(Icons.add_circle_outline),
                        onPressed: () => setState(() => _numTravelers++),
                      ),
                      const Spacer(),
                      Text('$_numTravelers khách', style: TextStyle(color: Colors.grey.shade600)),

                    ],
                  ),
                ),
                const SizedBox(height: 16),

                _buildLabel('Phí'),
                const SizedBox(height: 8),
                _buildField(
                  controller: _feeController,
                  hint: 'Phí',
                  icon: Icons.attach_money,
                  suffix: '(\$/hour)',
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),

                _buildLabel('Ngôn ngữ hướng dẫn'),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _languages.map((lang) {
                    final selected = _selectedLanguages.contains(lang);
                    return ChoiceChip(
                      label: Text(lang),
                      selected: selected,
                      selectedColor: const Color(0xFF00D1A3),
                      backgroundColor: Colors.grey.shade200,
                      labelStyle: TextStyle(color: selected ? Colors.white : Colors.black87),
                      onSelected: (_) => _toggleLanguage(lang),
                    );
                  }).toList(),
                ),

                const SizedBox(height: 16),
                _buildLabel('Điểm tham quan'),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    GestureDetector(
                      onTap: () {},
                      child: Container(
                        width: (MediaQuery.of(context).size.width - 56) / 2,
                        height: 100,
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Center(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              Icon(Icons.add, color: Color(0xFF00D1A3)),
                              SizedBox(width: 6),
                              Text('Thêm mới', style: TextStyle(color: Color(0xFF00D1A3), fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      ),
                    ),
                    ..._attractions.asMap().entries.map((entry) {
                      final index = entry.key;
                      final item = entry.value;
                      return GestureDetector(
                        onTap: () => _toggleAttraction(index),
                        child: Stack(
                          children: [
                            Container(
                              width: (MediaQuery.of(context).size.width - 56) / 2,
                              height: 100,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                image: DecorationImage(image: NetworkImage(item.image), fit: BoxFit.cover),
                              ),
                            ),
                            Container(
                              width: (MediaQuery.of(context).size.width - 56) / 2,
                              height: 100,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                gradient: LinearGradient(
                                  colors: [Colors.black26, Colors.black54],
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                ),
                              ),
                            ),
                            Positioned(
                              top: 6,
                              right: 6,
                              child: CircleAvatar(
                                radius: 12,
                                backgroundColor: item.selected ? Colors.green : Colors.white,
                                child: Icon(item.selected ? Icons.check : Icons.add, size: 14, color: item.selected ? Colors.white : Colors.black54),
                              ),
                            ),
                            Positioned(
                              left: 8,
                              bottom: 8,
                              right: 8,
                              child: Text(item.name,
                                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ],
                ),

                const SizedBox(height: 24),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00D1A3),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: _saveTrip,
                  child: const Text('XONG', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),

                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(text, style: const TextStyle(fontSize: 13, color: Colors.grey, fontWeight: FontWeight.w600));
  }

  Widget _buildField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool readOnly = false,
    String? suffix,
    TextInputType keyboardType = TextInputType.text,
    VoidCallback? onTap,
  }) {
    return TextField(
      controller: controller,
      readOnly: readOnly,
      keyboardType: keyboardType,
      onTap: onTap,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, color: Colors.grey[600]),
        suffixText: suffix,
        contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        filled: true,
        fillColor: Colors.grey.shade100,
      ),
    );
  }
}

class _Attraction {
  final String name;
  final String image;
  bool selected = false;

  _Attraction(this.name, this.image);
}

