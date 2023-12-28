import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import 'package:provider/provider.dart';

import '../helpers/constants.dart';
import '../providers/login_provider.dart';

class Header extends StatefulWidget {
  const Header({
    Key? key,
    required this.pageTitle,
  }) : super(key: key);

  final String pageTitle;

  @override
  State<Header> createState() => _Header();
}

class _Header extends State<Header> {
  late LoginProvider _loginProvider;

  @override
  void initState() {
    super.initState();
    _loginProvider = context.read<LoginProvider>();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            widget.pageTitle,
            style: TextStyle(color: Colors.white),
          ),
        ),
        ProfileCard(loginProvider: _loginProvider),
      ],
    );
  }
}

class ProfileCard extends StatefulWidget {
  final LoginProvider loginProvider;

  const ProfileCard({
    Key? key,
    required this.loginProvider,
  }) : super(key: key);

  @override
  State<ProfileCard> createState() => _ProfileCardState();
}

class _ProfileCardState extends State<ProfileCard> {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: const [
        SizedBox(width: 8),
        SizedBox(),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: defaultPadding / 2),
        ),

      ],
    );
  }
}