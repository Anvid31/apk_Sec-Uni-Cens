import 'package:flutter/material.dart';

class CustomTextField extends StatefulWidget {
  final String label;
  final String? hintText;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final int? maxLines;
  final String? initialValue;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final VoidCallback? onSuffixIconPressed;
  final bool obscureText;
  final bool enabled;
  final bool? showRequiredIndicator; // Control manual del asterisco
  
  const CustomTextField({
    super.key,
    required this.label,
    this.hintText,
    this.controller,
    this.keyboardType,
    this.validator,
    this.onChanged,
    this.maxLines = 1,
    this.initialValue,
    this.prefixIcon,
    this.suffixIcon,
    this.onSuffixIconPressed,
    this.obscureText = false,
    this.enabled = true,
    this.showRequiredIndicator,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _borderAnimation;
  late Animation<Color?> _colorAnimation;
  
  bool _isFocused = false;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    
    _borderAnimation = Tween<double>(
      begin: 1.0,
      end: 2.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    _colorAnimation = ColorTween(
      begin: Colors.grey.shade300,
      end: const Color(0xFF4CAF50),
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    _focusNode.addListener(_onFocusChange);
  }

  void _onFocusChange() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });
    
    if (_isFocused) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.only(left: 4, bottom: 8),
            child: RichText(
              text: TextSpan(
                text: widget.label,
                style: TextStyle(
                  fontSize: _isFocused ? 15 : 14,
                  fontWeight: FontWeight.w600,
                  color: _isFocused 
                      ? const Color(0xFF4CAF50)
                      : const Color(0xFF424242),
                  fontFamily: 'Roboto', // Ensure font consistency
                ),
                children: [
                  if (widget.showRequiredIndicator ?? widget.validator != null)
                    const TextSpan(
                      text: ' *',
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                ],
              ),
            ),
          ),
          AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: _isFocused ? [
                    BoxShadow(
                      color: const Color(0xFF4CAF50).withValues(alpha: 0.15),
                      offset: const Offset(0, 4),
                      blurRadius: 12,
                      spreadRadius: 0,
                    ),
                  ] : [],
                ),
                child: TextFormField(
                  controller: widget.controller,
                  initialValue: widget.controller == null ? widget.initialValue : null,
                  keyboardType: widget.keyboardType,
                  maxLines: widget.maxLines,
                  obscureText: widget.obscureText,
                  enabled: widget.enabled,
                  focusNode: _focusNode,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF2C3E50),
                  ),
                  decoration: InputDecoration(
                    hintText: widget.hintText ?? 'Ingrese ${widget.label.toLowerCase()}',
                    hintStyle: TextStyle(
                      color: Colors.grey.shade500,
                      fontWeight: FontWeight.w400,
                    ),
                    prefixIcon: widget.prefixIcon != null ? Container(
                      margin: const EdgeInsets.only(left: 16, right: 12),
                      child: Icon(
                        widget.prefixIcon,
                        color: _isFocused 
                            ? const Color(0xFF4CAF50)
                            : Colors.grey.shade600,
                        size: 22,
                      ),
                    ) : null,
                    suffixIcon: widget.suffixIcon != null ? Container(
                      margin: const EdgeInsets.only(right: 16, left: 12),
                      child: IconButton(
                        icon: Icon(
                          widget.suffixIcon,
                          color: _isFocused 
                              ? const Color(0xFF4CAF50)
                              : Colors.grey.shade600,
                          size: 22,
                        ),
                        onPressed: widget.onSuffixIconPressed,
                      ),
                    ) : null,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: widget.prefixIcon != null ? 8 : 20,
                      vertical: widget.maxLines! > 1 ? 20 : 18,
                    ),
                    filled: true,
                    fillColor: widget.enabled 
                        ? (_isFocused 
                            ? Colors.white 
                            : Colors.grey.shade50)
                        : Colors.grey.shade100,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(
                        color: _colorAnimation.value ?? Colors.grey.shade300,
                        width: _borderAnimation.value,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(
                        color: Colors.grey.shade300,
                        width: 1.5,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(
                        color: Color(0xFF4CAF50),
                        width: 2.0,
                      ),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(
                        color: Colors.red.shade400,
                        width: 1.5,
                      ),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(
                        color: Colors.red.shade400,
                        width: 2.0,
                      ),
                    ),
                    disabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(
                        color: Colors.grey.shade300,
                        width: 1.0,
                      ),
                    ),
                  ),
                  validator: widget.validator ?? (value) {
                    if (value == null || value.isEmpty) {
                      return 'Este campo es requerido';
                    }
                    return null;
                  },
                  onChanged: widget.onChanged,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
