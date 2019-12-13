import 'package:subscriptions/data/database/database_provider.dart';
import 'package:subscriptions/data/database/daos/subscription_dao.dart';
import 'package:subscriptions/data/di/renewal_inject.dart';
import 'package:subscriptions/data/repositories/subscription_repository.dart';
import 'package:subscriptions/domain/services/renewals_service.dart';

class SubscriptionInject {
  static SubscriptionRepository buildSubscriptionRepository() {
    return SubscriptionRepository(
        subscriptionDao: buildSubscriptionDao(),
        renewalDao: RenewalInject.buildRenewalDao(),
        renewalsService: RenewalsService());
  }

  static SubscriptionDao buildSubscriptionDao() {
    return SubscriptionDao(database: DatabaseProvider.instance.database);
  }
}
