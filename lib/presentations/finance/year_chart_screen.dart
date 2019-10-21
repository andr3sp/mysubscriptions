import 'dart:collection';

import "package:collection/collection.dart";
import 'package:flutter/material.dart';
import 'package:sticky_headers/sticky_headers.dart';
import 'package:subscriptions/data/di/payment_inject.dart';
import 'package:subscriptions/data/entities/payment.dart';
import 'package:subscriptions/data/entities/subscription.dart';
import 'package:subscriptions/data/repositories/payment_repository.dart';
import 'package:subscriptions/helpers/dates_helper.dart';
import 'package:subscriptions/presentations/finance/chart_widgets/bar_chart_yearly.dart';
import 'package:subscriptions/presentations/styles/colors.dart' as AppColors;

class YearChartScreen extends StatefulWidget {
  @override
  _YearChartScreenState createState() => _YearChartScreenState();
}

class _YearChartScreenState extends State<YearChartScreen> {
  PaymentRepository _paymentRepository;

  @override
  void initState() {
    _paymentRepository = PaymentInject.buildPaymentRepository();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return _buildBody();
  }

  Widget _buildBody() {
    return Center(
      child: FutureBuilder(
        builder: (context, projectSnap) {
          if (projectSnap.connectionState == ConnectionState.none ||
              !projectSnap.hasData) {
            return Container();
          } else {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                _buildChart(projectSnap.data),
                _buildAmount(projectSnap.data),
                SizedBox(
                  height: 10,
                ),
                _buildSubscriptionList(projectSnap.data)
              ],
            );
          }
        },
        future: _fetchRenewalsUntilToday(),
      ),
    );
  }

  Widget _buildAmount(List<Payment> payments) {
    return Container(
      alignment: Alignment(1.0, 1.0),
      margin: EdgeInsets.only(left: 30, right: 10),
      child:
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: <Widget>[
        Text(
          "Expenses",
          style: TextStyle(color: AppColors.kTextCardDetail, fontSize: 15),
        ),
        Text(
          "€ ${_calculateThisMonthAmount(payments)}",
          style: TextStyle(color: AppColors.kTextCardDetail, fontSize: 25),
        ),
      ]),
    );
  }

  Widget _buildChart(List<Payment> data) {
    return Container(
      height: 200,
      child: BarChartYearly(
        paymentList: data,
      ),
    );
  }

  Widget _buildSubscriptionList(List<Payment> data) {
    return Expanded(
      child: FutureBuilder(
        builder: (context, projectSnap) {
          if (projectSnap.connectionState == ConnectionState.none ||
              !projectSnap.hasData) {
            return Container();
          } else {
            return ListView.builder(
              itemCount: projectSnap.data.length,
              itemBuilder: (context, index) {
                final headerData =
                    projectSnap.data as LinkedHashMap<String, List<Payment>>;
                final keys = headerData.keys.toList();

                return StickyHeader(
                  header: Container(
                    height: 50.0,
                    color: Colors.blue,
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    alignment: Alignment.centerLeft,
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          child: Text(
                            keys[index],
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                        Text(
                          "€ ${_calculateAmountByMonth(headerData[keys[index]])}",
                          style: const TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                  content: Column(
                    children: _buildMonthPayments(
                        keys[index], headerData[keys[index]]),
                  ),
                );
              },
            );
          }
        },
        future: _groupData(data),
      ),
    );
  }

  List<Widget> _buildMonthPayments(String key, List<Payment> data) {
    return data.map((payment) {
      return _buildRow(payment.subscription);
    }).toList();
  }

  String _calculateAmountByMonth(List<Payment> data) {
    return data.fold(0, (initialValue, payment) {
      return initialValue + payment.subscription.price;
    }).toString();
  }

  Widget _buildRow(Subscription subscription) {
    return Stack(
      children: <Widget>[
        _buildBackColorRow(subscription),
        Container(
          color: subscription.color.withOpacity(0.4),
          height: 45,
          margin: EdgeInsets.only(left: 0, right: 0),
          child: Padding(
            padding: EdgeInsets.only(left: 30, right: 10),
            child: Row(
              children: <Widget>[
                Expanded(
                    child: Text(
                  subscription.name,
                  style: TextStyle(color: Colors.white, fontSize: 16),
                )),
                Text("€${subscription.price}",
                    style: TextStyle(color: Colors.white, fontSize: 16))
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBackColorRow(Subscription subscription) {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        decoration: BoxDecoration(
          color: subscription.color.withOpacity(0.6),
          borderRadius: BorderRadius.only(
            bottomLeft: const Radius.circular(20),
            topLeft: const Radius.circular(20),
          ),
        ),
        width: 10 * subscription.price,
        height: 45,
      ),
    );
  }

  double _calculateThisMonthAmount(List<Payment> payments) {
    return payments.map((payment) {
      return payment.subscription.price;
    }).fold(0.00, (current, next) {
      return current + next;
    });
  }

  Future<List<Payment>> _fetchRenewalsUntilToday() async {
    final DateTime now = DateTime.now();
    final firstDateYear = DatesHelper.firstDayOfYear(DateTime.now());

    final result =
        await _paymentRepository.fetchAllRenewalsByMonth(firstDateYear, now);

    return result;
  }

  Future<Map<String, List<Payment>>> _groupData(List<Payment> result) async {
    return await groupBy(result, (Payment obj) {
      return DatesHelper.toStringWithMonthAndYear(obj.renewalAt);
    });
  }
}
