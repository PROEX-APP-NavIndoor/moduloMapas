import 'package:flutter/material.dart';
import 'package:mvp_proex/app/app.color.dart';

class FormFieldWidget extends StatefulWidget {
  final String title;
  final String description;
  final Function validator;
  final Function onChanged;
  final TextInputType keyboardType;
  final TextEditingController controller;
  final bool obscure;
  final int? maxLines;
  final AutovalidateMode auto;
  final Widget icon;

  const FormFieldWidget({
    Key? key,
    required this.title,
    required this.description,
    required this.validator,
    required this.onChanged,
    required this.keyboardType,
    this.obscure = false,
    this.maxLines = 1,
    required this.icon,
    required this.controller,
    this.auto = AutovalidateMode.onUserInteraction,
  }) : super(key: key);
  @override
  _FormFieldWidgetState createState() => _FormFieldWidgetState();
}

class _FormFieldWidgetState extends State<FormFieldWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.title,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 16,
              fontWeight: FontWeight.bold,
              fontFamily: 'Manrope',
            ),
            textAlign: TextAlign.left,
          ),
          const SizedBox(
            height: 5,
          ),
          TextFormField(
            obscureText: widget.obscure,
            controller: widget.controller,
            onChanged: (String value) {
              widget.onChanged(value);
            },
            maxLines: widget.maxLines,
            keyboardType: widget.keyboardType,
            validator: (value) {
              return widget.validator(value);
            },
            autovalidateMode: widget.auto,
            decoration: InputDecoration(
              focusedBorder: const OutlineInputBorder(
                  borderSide: BorderSide(
                    color: AppColors.primary,
                  ),
                  borderRadius: BorderRadius.all(Radius.circular(20.0))),
              enabledBorder: const OutlineInputBorder(
                  borderSide: BorderSide(
                    color: AppColors.primary,
                  ),
                  borderRadius: BorderRadius.all(Radius.circular(20.0))),
              border: const OutlineInputBorder(
                  borderSide: BorderSide(
                    color: AppColors.primary,
                  ),
                  borderRadius: BorderRadius.all(Radius.circular(20.0))),
              hintText: widget.description,
              hintStyle: const TextStyle(
                color: AppColors.primary,
                fontSize: 12,
                fontWeight: FontWeight.w400,
              ),
              suffixIcon: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: widget.icon,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
