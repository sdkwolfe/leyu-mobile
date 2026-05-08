import 'package:get/get.dart';
import 'package:leyu_mobile/core/api/api_client.dart';
import 'package:leyu_mobile/features/withdraw/data/datasources/withdraw_remote_data_source.dart';
import 'package:leyu_mobile/features/withdraw/domain/repositories/withdraw_repository.dart';
import 'package:leyu_mobile/features/withdraw/domain/usecases/withdraw_usecase.dart';
import 'package:leyu_mobile/features/withdraw/presentation/controllers/withdraw_controller.dart';

class WithdrawBinding extends Bindings {
  @override
  void dependencies() {
    // Read arguments here — called at navigation time, not at route list build time
    final walletBalance = Get.arguments as double? ?? 0.0;
    Get.lazyPut(() => WithdrawRemoteDataSource(Get.find<ApiClient>()));
    Get.lazyPut(() => WithdrawRepository(Get.find<WithdrawRemoteDataSource>()));
    Get.lazyPut(() => WithdrawUsecase(Get.find<WithdrawRepository>()));
    Get.lazyPut(() => WithdrawController(
          Get.find<WithdrawUsecase>(),
          initialBalance: walletBalance,
        ));
  }
}
