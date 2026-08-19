package com.smaraaccounting.smara_accounting

import io.flutter.embedding.android.FlutterFragmentActivity

// FlutterFragmentActivity, not FlutterActivity: local_auth (app-lock)
// requires a FragmentActivity host to show Android's biometric prompt.
class MainActivity : FlutterFragmentActivity()
