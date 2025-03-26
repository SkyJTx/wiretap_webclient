import 'package:hive_ce/hive.dart';
import 'package:wiretap_webclient/repo/database/entity/setting_entity.dart';

@GenerateAdapters([AdapterSpec<SettingEntity>()])
part 'hive_adapters.g.dart';
