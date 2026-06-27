import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/app_models.dart';
import '../../services/api_client.dart';

class DevPaymentScreen extends StatefulWidget {
  const DevPaymentScreen({
    super.key,
    required this.apiClient,
    required this.order,
  });

  final ApiClient apiClient;
  final OrderSummary order;

  @override
  State<DevPaymentScreen> createState() => _DevPaymentScreenState();
}

class _DevPaymentScreenState extends State<DevPaymentScreen> {
  late OrderSummary _order;
  bool _paying = false;
  bool _refreshing = false;

  @override
  void initState() {
    super.initState();
    _order = widget.order;
  }

  @override
  Widget build(BuildContext context) {
    final isPaid = _order.isPaid;

    return Scaffold(
      appBar: AppBar(title: const Text('Pembayaran')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _PaymentHero(order: _order),
            const SizedBox(height: 12),
            _PaymentStatusNotice(isPaid: isPaid),
            const SizedBox(height: 12),
            _PaymentMethodCard(order: _order),
            const SizedBox(height: 12),
            _PaymentSummaryCard(order: _order),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: _paying
                  ? null
                  : isPaid
                      ? () => Navigator.of(context).pop(_order)
                      : _settlePayment,
              icon: Icon(
                isPaid ? Icons.lock_open_outlined : Icons.payments_outlined,
              ),
              label: Text(
                _paying
                    ? 'Memproses...'
                    : isPaid
                        ? 'Kembali ke Paket'
                        : 'Simulasi Bayar Sekarang',
              ),
            ),
            const SizedBox(height: 10),
            OutlinedButton.icon(
              onPressed: _refreshing ? null : _refreshOrder,
              icon: Icon(
                _refreshing ? Icons.hourglass_empty : Icons.refresh_outlined,
              ),
              label: const Text('Cek Status Pembayaran'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _settlePayment() async {
    setState(() => _paying = true);
    try {
      final paidOrder = await widget.apiClient.settleDevPayment(_order.id);
      if (!mounted) {
        return;
      }
      setState(() => _order = paidOrder);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pembayaran sandbox berhasil.')),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.toString())),
      );
    } finally {
      if (mounted) {
        setState(() => _paying = false);
      }
    }
  }

  Future<void> _refreshOrder() async {
    setState(() => _refreshing = true);
    try {
      final order = await widget.apiClient.getMyOrder(_order.id);
      if (!mounted) {
        return;
      }
      setState(() => _order = order);
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.toString())),
      );
    } finally {
      if (mounted) {
        setState(() => _refreshing = false);
      }
    }
  }
}

class _PaymentHero extends StatelessWidget {
  const _PaymentHero({required this.order});

  final OrderSummary order;

  @override
  Widget build(BuildContext context) {
    final statusColor = order.isPaid
        ? const Color(0xFF659287)
        : const Color(0xFFD79A2B);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF263238),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.account_balance_wallet_outlined,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${order.paymentProvider ?? 'XENDIT'} Sandbox',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                          ),
                    ),
                    Text(
                      'Mode development',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.white70,
                          ),
                    ),
                  ],
                ),
              ),
              _StatusChip(
                label: order.isPaid ? 'PAID' : 'PENDING',
                color: statusColor,
              ),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            _formatCurrency(order.total, order.currency),
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            order.orderNumber,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white70,
                ),
          ),
        ],
      ),
    );
  }
}

class _PaymentStatusNotice extends StatelessWidget {
  const _PaymentStatusNotice({required this.isPaid});

  final bool isPaid;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isPaid ? const Color(0xFFE6F0DD) : const Color(0xFFFFF7E6),
        border: Border.all(
          color: isPaid ? const Color(0xFF9CBCB0) : const Color(0xFFE0B15A),
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            isPaid ? Icons.verified_outlined : Icons.info_outline,
            color: isPaid ? const Color(0xFF659287) : const Color(0xFFD79A2B),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              isPaid
                  ? 'Pembayaran sudah diterima. Paket sudah terbuka untuk akun ini.'
                  : 'Ini adalah simulasi payment gateway. Saat Xendit sudah aktif, layar ini tinggal diarahkan ke invoice asli.',
            ),
          ),
        ],
      ),
    );
  }
}

class _PaymentMethodCard extends StatelessWidget {
  const _PaymentMethodCard({required this.order});

  final OrderSummary order;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Metode Pembayaran',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
            ),
            const SizedBox(height: 12),
            const _PaymentMethodRow(
              icon: Icons.account_balance_outlined,
              title: 'Virtual Account',
              subtitle: 'VA development otomatis untuk test pembayaran',
              selected: true,
            ),
            const Divider(height: 20),
            const _PaymentMethodRow(
              icon: Icons.qr_code_2_outlined,
              title: 'QRIS',
              subtitle: 'Preview channel pembayaran berikutnya',
            ),
            const Divider(height: 20),
            const _PaymentMethodRow(
              icon: Icons.phone_android_outlined,
              title: 'E-Wallet',
              subtitle: 'Preview OVO, DANA, LinkAja, dan lainnya',
            ),
            const SizedBox(height: 12),
            _InfoLine(
              label: 'External ID',
              value: order.paymentExternalId ?? order.orderNumber,
            ),
            _InfoLine(
              label: 'Invoice URL',
              value: order.paymentCheckoutUrl ?? '-',
            ),
          ],
        ),
      ),
    );
  }
}

class _PaymentMethodRow extends StatelessWidget {
  const _PaymentMethodRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.selected = false,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF659287)),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 2),
              Text(subtitle),
            ],
          ),
        ),
        if (selected)
          const Icon(Icons.check_circle, color: Color(0xFF659287)),
      ],
    );
  }
}

class _PaymentSummaryCard extends StatelessWidget {
  const _PaymentSummaryCard({required this.order});

  final OrderSummary order;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Ringkasan',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
            ),
            const SizedBox(height: 12),
            for (final item in order.items)
              _InfoLine(
                label: item.title,
                value: _formatCurrency(item.subtotal, order.currency),
              ),
            const Divider(height: 24),
            _InfoLine(
              label: 'Subtotal',
              value: _formatCurrency(order.subtotal, order.currency),
            ),
            if (order.promoDiscount > 0)
              _InfoLine(
                label: 'Promo',
                value: '-${_formatCurrency(order.promoDiscount, order.currency)}',
              ),
            if (order.voucherDiscount > 0)
              _InfoLine(
                label: 'Voucher',
                value:
                    '-${_formatCurrency(order.voucherDiscount, order.currency)}',
              ),
            if (order.pointDiscount > 0)
              _InfoLine(
                label: 'Point',
                value: '-${_formatCurrency(order.pointDiscount, order.currency)}',
              ),
            const SizedBox(height: 4),
            _InfoLine(
              label: 'Total Bayar',
              value: _formatCurrency(order.total, order.currency),
              strong: true,
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoLine extends StatelessWidget {
  const _InfoLine({
    required this.label,
    required this.value,
    this.strong = false,
  });

  final String label;
  final String value;
  final bool strong;

  @override
  Widget build(BuildContext context) {
    final style = strong
        ? Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w900,
            )
        : Theme.of(context).textTheme.bodyMedium;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: Text(label, style: style)),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: style,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

String _formatCurrency(int value, String currency) {
  return NumberFormat.currency(
    locale: 'id_ID',
    symbol: currency == 'IDR' ? 'Rp' : '$currency ',
    decimalDigits: 0,
  ).format(value);
}
