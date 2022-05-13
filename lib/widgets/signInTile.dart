import 'package:flutter/material.dart';

class SignInTile extends StatelessWidget {
  SignInTile({
    Key? key,
    required this.imageName,
    required this.textMessage,
    required this.onPressed,
  }) : super(key: key);

  String textMessage;
  String imageName;
  Function onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      padding: const EdgeInsets.all(4),
      child: InkWell(
        splashColor: Theme.of(context).primaryColor,
        onTap: () => onPressed(),
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 10,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(
                  child: Image.asset('assets/images/$imageName'),
                  width: 50,
                ),
              ),
              const SizedBox(width: 10),
              SizedBox(
                width: 180,
                child: Text(
                  textMessage,
                  style: TextStyle(
                    fontSize: 21,
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 25),
            ],
          ),
        ),
      ),
    );
  }
}
