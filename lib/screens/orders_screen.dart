import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:th4/providers/order_provider.dart';
import 'package:th4/utils/currency.dart';

class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Đơn mua'),
          bottom: const TabBar(
            isScrollable: true,
            tabs: [
              Tab(text: 'Chờ xác nhận'),
              Tab(text: 'Đang giao'),
              Tab(text: 'Đã giao'),
              Tab(text: 'Đã hủy'),
            ],
          ),
        ),
        body: Consumer<OrderProvider>(
          builder: (context, orderProvider, _) {
            final orders = orderProvider.orders;
            if (orders.isEmpty) {
              return const Center(child: Text('Chưa có đơn hàng'));
            }

            return TabBarView(
              children: List.generate(4, (_) {
                return ListView.builder(
                  itemCount: orders.length,
                  itemBuilder: (context, index) {
                    final order = orders[index];
                    return ListTile(
                      leading: const Icon(Icons.shopping_bag_outlined),
                      title: Text('Đơn #${order.id}'),
                      subtitle: Text(
                        '${order.items.length} sản phẩm - ${DateFormat('dd/MM/yyyy HH:mm').format(order.createdAt)}',
                      ),
                      trailing: Text(
                        formatVnd(order.total),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    );
                  },
                );
              }),
            );
          },
        ),
      ),
    );
  }
}
