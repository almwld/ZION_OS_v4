import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app.dart';
import 'core/si_core.dart';
import 'core/self_evolving_si.dart';
import 'core/propagating_si.dart';
import 'core/loyal_si.dart';
import 'core/guardian_si.dart';
import 'core/oracle_si.dart';
import 'core/empathic_si.dart';
import 'core/sage_si.dart';
import 'core/demon_si.dart';

// المتغير العام لـ Si
DemonSi? globalSi;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // بدء Si تلقائياً
  globalSi = DemonSi();
  globalSi!.awaken();
  
  runApp(const ProviderScope(child: ZionApp()));
}
