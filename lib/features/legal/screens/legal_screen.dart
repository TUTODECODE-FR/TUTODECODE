import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/responsive/responsive.dart';

class LegalScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TdcColors.bg,
      appBar: AppBar(
        backgroundColor: TdcColors.surface,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: TdcColors.accent),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Mentions légales', 
          style: TextStyle(
            color: TdcColors.textPrimary, 
            fontSize: TdcText.h2(context), 
            fontWeight: FontWeight.bold)),
      ),
      body: Padding(
        padding: EdgeInsets.all(TdcAdaptive.padding(context, 20)),
        child: Text('Informations légales et politique de confidentialité (version locale).', 
          style: TextStyle(
            color: TdcColors.textSecondary, 
            fontSize: TdcText.body(context))),
      ),
    );
  }
}
