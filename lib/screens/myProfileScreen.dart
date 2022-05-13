import 'package:flutter/material.dart';

class MyProfileScreen extends StatelessWidget {
  const MyProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context).size;
    return SafeArea(
      child: Scaffold(
        body: CustomScrollView(
          slivers: [
            SliverAppBar(
              pinned: true,
              floating: false,
              snap: false,
              expandedHeight: mediaQuery.height * 0.43,
              flexibleSpace: FlexibleSpaceBar(
                titlePadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 5,
                ),
                background: Image.asset(
                  'assets/images/404.webp',
                  fit: BoxFit.cover,
                ),
                title: const Text(
                  'hello there ',
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 25,
                  ),
                ),
              ),
            ),
            SliverList(
              delegate: SliverChildListDelegate(
                [const Text('HEY SAN', style: TextStyle(fontSize: 550))],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
