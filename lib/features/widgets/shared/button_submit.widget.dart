import 'package:flutter/material.dart';
import 'package:mvp_proex/app/app.color.dart';

class ButtonSubmitWidget extends StatefulWidget {
  final String textButton;
  final Function onPressed;
  final double d;
  final bool inversed;

  const ButtonSubmitWidget({
    Key? key,
    required this.textButton,
    required this.onPressed,
    this.d = 0.65,
    this.inversed = false,
  }) : super(key: key);
  @override
  _ButtonSubmitWidgetState createState() => _ButtonSubmitWidgetState();
}

class _ButtonSubmitWidgetState extends State<ButtonSubmitWidget> {
  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Container(
      width: size.width * widget.d,
      height: 60,
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: widget.inversed ? Colors.white : AppColors.primary,
          shadowColor: AppColors.primary,
          elevation: 10,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
            side: const BorderSide(
              color: AppColors.primary,
            ),
          ),
        ),
        child: Text(
          widget.textButton,
          style: TextStyle(
            fontSize: 20.0,
            color: widget.inversed ? AppColors.primary : Colors.white,
          ),
        ),
        onPressed: () {
          widget.onPressed();
        },
      ),
    );
  }
}
