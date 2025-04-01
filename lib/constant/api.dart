import 'package:flutter/foundation.dart';

const hostname = !kDebugMode ? 'rookies111-pi.local:8080' : 'localhost:8080';
const baseUri = 'http://$hostname';
const wsSessionUri = 'ws://$hostname/ws/';
