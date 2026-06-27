import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/app_models.dart';
import '../../services/api_client.dart';
import '../../services/auth_controller.dart';
import '../common/async_content.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({
    super.key,
    required this.authController,
    required this.apiClient,
  });

  final AuthController authController;
  final ApiClient apiClient;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profil')),
      body: SafeArea(
        child: ProfileContent(
          authController: authController,
          apiClient: apiClient,
        ),
      ),
    );
  }
}

class ProfileContent extends StatefulWidget {
  const ProfileContent({
    super.key,
    required this.authController,
    required this.apiClient,
  });

  final AuthController authController;
  final ApiClient apiClient;

  @override
  State<ProfileContent> createState() => _ProfileContentState();
}

class _ProfileContentState extends State<ProfileContent> {
  late Future<UserProfileDetail> _profileFuture;
  bool _saving = false;
  bool _resettingPassword = false;

  @override
  void initState() {
    super.initState();
    _profileFuture = widget.apiClient.getMyProfile();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.authController,
      builder: (context, _) {
        final user = widget.authController.profile;

        if (user == null) {
          return const EmptyState(
            title: 'Sesi belum aktif.',
            icon: Icons.account_circle_outlined,
          );
        }

        return FutureBuilder<UserProfileDetail>(
          future: _profileFuture,
          builder: (context, snapshot) {
            final profile = snapshot.data ?? _fallbackProfile(user);

            return RefreshIndicator(
              onRefresh: _refresh,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _ProfileHeader(profile: profile),
                  if (snapshot.hasError) ...[
                    const SizedBox(height: 12),
                    InlineNotice(
                      icon: Icons.cloud_off_outlined,
                      message:
                          'Profil detail belum bisa dimuat. Menampilkan data sesi. ${snapshot.error}',
                    ),
                  ],
                  if (_saving || _resettingPassword) ...[
                    const SizedBox(height: 12),
                    const LinearProgressIndicator(),
                  ],
                  const SizedBox(height: 12),
                  _ProfileActionCard(
                    onEdit: () => _editProfile(profile),
                    onResetPassword: _resetPassword,
                    onRefresh: _refresh,
                    onSignOut: widget.authController.signOut,
                    busy:
                        widget.authController.isBusy ||
                        _saving ||
                        _resettingPassword,
                  ),
                  const SizedBox(height: 12),
                  _ContactCard(profile: profile),
                  const SizedBox(height: 12),
                  _LoyaltyCard(account: profile.loyaltyAccount),
                  const SizedBox(height: 12),
                  _ProgressSection(apiClient: widget.apiClient),
                  const SizedBox(height: 12),
                  _PackageSection(apiClient: widget.apiClient),
                  const SizedBox(height: 12),
                  _OrderSection(apiClient: widget.apiClient),
                  if (widget.authController.errorMessage != null) ...[
                    const SizedBox(height: 12),
                    InlineNotice(
                      icon: Icons.info_outline,
                      message: widget.authController.errorMessage!,
                    ),
                  ],
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _refresh() async {
    setState(() {
      _profileFuture = widget.apiClient.getMyProfile();
    });
    await widget.authController.refreshProfile();
  }

  Future<void> _editProfile(UserProfileDetail profile) async {
    final result = await _showEditProfileDialog(context, profile);
    if (result == null) {
      return;
    }

    setState(() => _saving = true);
    try {
      final updated = await widget.apiClient.updateMyProfile(
        displayName: result.displayName,
        fullName: result.fullName,
        phoneNumber: result.phoneNumber,
        addressLine: result.addressLine,
        city: result.city,
        province: result.province,
        postalCode: result.postalCode,
        country: result.country,
      );
      await widget.authController.refreshProfile();
      if (!mounted) {
        return;
      }
      setState(() {
        _profileFuture = Future.value(updated);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profil berhasil diperbarui.')),
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
        setState(() => _saving = false);
      }
    }
  }

  Future<void> _resetPassword() async {
    setState(() => _resettingPassword = true);
    await widget.authController.sendPasswordResetEmail();
    if (!mounted) {
      return;
    }

    final error = widget.authController.errorMessage;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          error == null
              ? 'Email reset password sudah dikirim.'
              : 'Reset password gagal: $error',
        ),
      ),
    );
    setState(() => _resettingPassword = false);
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({required this.profile});

  final UserProfileDetail profile;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.primary,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            CircleAvatar(
              radius: 34,
              backgroundColor: colorScheme.onPrimary.withValues(alpha: 0.16),
              backgroundImage: profile.photoUrl == null
                  ? null
                  : NetworkImage(profile.photoUrl!),
              child: profile.photoUrl == null
                  ? Icon(
                      Icons.person_outline,
                      color: colorScheme.onPrimary,
                      size: 32,
                    )
                  : null,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    profile.primaryName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: colorScheme.onPrimary,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _HeaderPill(label: profile.role),
                      if (profile.email?.isNotEmpty == true)
                        _HeaderPill(label: profile.email!),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeaderPill extends StatelessWidget {
  const _HeaderPill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: colorScheme.onPrimary.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: colorScheme.onPrimary,
          fontWeight: FontWeight.w700,
          fontSize: 12,
        ),
      ),
    );
  }
}

class _ProfileActionCard extends StatelessWidget {
  const _ProfileActionCard({
    required this.onEdit,
    required this.onResetPassword,
    required this.onRefresh,
    required this.onSignOut,
    required this.busy,
  });

  final VoidCallback onEdit;
  final VoidCallback onResetPassword;
  final Future<void> Function() onRefresh;
  final Future<void> Function() onSignOut;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: busy ? null : onEdit,
                    icon: const Icon(Icons.edit_outlined),
                    label: const Text('Edit Profil'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: busy ? null : onResetPassword,
                    icon: const Icon(Icons.lock_reset_outlined),
                    label: const Text('Password'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: busy ? null : () => onRefresh(),
                    icon: const Icon(Icons.sync_outlined),
                    label: const Text('Refresh'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: busy ? null : () => onSignOut(),
                    icon: const Icon(Icons.logout_outlined),
                    label: const Text('Keluar'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ContactCard extends StatelessWidget {
  const _ContactCard({required this.profile});

  final UserProfileDetail profile;

  @override
  Widget build(BuildContext context) {
    final data = profile.profile;
    final phone = data?.phoneNumber ?? profile.phoneNumber;
    final address = data?.addressSummary ?? '';

    return _SectionCard(
      title: 'Data Kontak',
      icon: Icons.contact_mail_outlined,
      children: [
        _InfoRow(
          icon: Icons.phone_outlined,
          label: 'Nomor HP',
          value: phone?.isNotEmpty == true ? phone! : 'Belum diisi',
        ),
        _InfoRow(
          icon: Icons.home_outlined,
          label: 'Alamat Rumah',
          value: address.isNotEmpty ? address : 'Belum diisi',
        ),
      ],
    );
  }
}

class _LoyaltyCard extends StatelessWidget {
  const _LoyaltyCard({required this.account});

  final LoyaltyAccount? account;

  @override
  Widget build(BuildContext context) {
    final points = account?.pointsBalance ?? 0;
    final earned = account?.lifetimeEarned ?? 0;
    final spent = account?.lifetimeSpent ?? 0;

    return _SectionCard(
      title: 'Member Point',
      icon: Icons.stars_outlined,
      children: [
        Row(
          children: [
            Expanded(
              child: _MetricBox(
                value: NumberFormat.decimalPattern('id_ID').format(points),
                label: 'Point Aktif',
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _MetricBox(
                value: NumberFormat.decimalPattern('id_ID').format(earned),
                label: 'Didapat',
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _MetricBox(
                value: NumberFormat.decimalPattern('id_ID').format(spent),
                label: 'Dipakai',
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        const Text('Setiap pembelian Rp10 menghasilkan 1 point.'),
      ],
    );
  }
}

class _ProgressSection extends StatelessWidget {
  const _ProgressSection({required this.apiClient});

  final ApiClient apiClient;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<LearningProgress>>(
      future: apiClient.getMyProgress(),
      builder: (context, snapshot) {
        final rows = snapshot.data ?? const <LearningProgress>[];
        final average = rows.isEmpty
            ? 0
            : (rows
                      .map((item) => item.progressPercent)
                      .reduce((left, right) => left + right) /
                  rows.length)
                  .round();

        return _SectionCard(
          title: 'Progress Belajar',
          icon: Icons.timeline_outlined,
          trailing: snapshot.connectionState == ConnectionState.waiting
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : InfoPill(label: '$average%'),
          children: [
            LinearProgressIndicator(value: average / 100),
            const SizedBox(height: 10),
            if (snapshot.hasError)
              const InlineNotice(
                icon: Icons.cloud_off_outlined,
                message: 'Progress belum bisa dimuat.',
              )
            else if (rows.isEmpty)
              const Text('Belum ada progress belajar.')
            else
              for (final item in rows.take(5))
                _InfoRow(
                  icon: Icons.check_circle_outline,
                  label: item.contentType,
                  value: '${item.status} - ${item.progressPercent}%',
                ),
          ],
        );
      },
    );
  }
}

class _PackageSection extends StatelessWidget {
  const _PackageSection({required this.apiClient});

  final ApiClient apiClient;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<UserEntitlement>>(
      future: apiClient.getMyEntitlements(),
      builder: (context, snapshot) {
        final rows = snapshot.data ?? const <UserEntitlement>[];

        return _SectionCard(
          title: 'Paket Aktif',
          icon: Icons.workspace_premium_outlined,
          trailing: snapshot.connectionState == ConnectionState.waiting
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : InfoPill(label: '${rows.length} paket'),
          children: [
            if (snapshot.hasError)
              const InlineNotice(
                icon: Icons.cloud_off_outlined,
                message: 'Paket aktif belum bisa dimuat.',
              )
            else if (rows.isEmpty)
              const Text('Belum ada paket yang aktif.')
            else
              for (final item in rows.take(5))
                _InfoRow(
                  icon: Icons.lock_open_outlined,
                  label: item.package.title,
                  value: _packageSubtitle(item.package),
                ),
          ],
        );
      },
    );
  }
}

class _OrderSection extends StatefulWidget {
  const _OrderSection({required this.apiClient});

  final ApiClient apiClient;

  @override
  State<_OrderSection> createState() => _OrderSectionState();
}

class _OrderSectionState extends State<_OrderSection> {
  late Future<List<OrderSummary>> _future;

  @override
  void initState() {
    super.initState();
    _future = widget.apiClient.getMyOrders();
  }

  Future<void> _refresh() async {
    final next = widget.apiClient.getMyOrders();
    setState(() {
      _future = next;
    });

    try {
      await next;
    } catch (_) {
      // FutureBuilder will surface the error inside the card.
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<OrderSummary>>(
      future: _future,
      builder: (context, snapshot) {
        final rows = snapshot.data ?? const <OrderSummary>[];
        final waitingCount = rows
            .where((item) => item.status == 'PENDING')
            .length;
        final isLoading = snapshot.connectionState == ConnectionState.waiting;

        return _SectionCard(
          title: 'Riwayat Order',
          icon: Icons.receipt_long_outlined,
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isLoading)
                const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              else
                InfoPill(
                  label: waitingCount > 0
                      ? '$waitingCount menunggu'
                      : '${rows.length} order',
                ),
              const SizedBox(width: 2),
              IconButton(
                tooltip: 'Refresh order',
                onPressed: isLoading ? null : _refresh,
                icon: const Icon(Icons.sync_outlined),
              ),
            ],
          ),
          children: [
            if (snapshot.hasError)
              const InlineNotice(
                icon: Icons.cloud_off_outlined,
                message: 'Riwayat order belum bisa dimuat.',
              )
            else if (rows.isEmpty)
              const Text('Belum ada order.')
            else ...[
              for (final item in rows.take(3))
                _OrderTile(
                  apiClient: widget.apiClient,
                  order: item,
                  onChanged: _refresh,
                ),
              if (rows.length > 3)
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    onPressed: () async {
                      await Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => _OrderHistoryScreen(
                            apiClient: widget.apiClient,
                          ),
                        ),
                      );
                      if (context.mounted) {
                        await _refresh();
                      }
                    },
                    icon: const Icon(Icons.list_alt_outlined),
                    label: Text('Lihat semua ${rows.length} order'),
                  ),
                ),
            ],
          ],
        );
      },
    );
  }
}

class _OrderTile extends StatelessWidget {
  const _OrderTile({
    required this.apiClient,
    required this.order,
    this.onChanged,
  });

  final ApiClient apiClient;
  final OrderSummary order;
  final Future<void> Function()? onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: () async {
            await Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => _OrderDetailScreen(
                  apiClient: apiClient,
                  order: order,
                ),
              ),
            );
            await onChanged?.call();
          },
          child: DecoratedBox(
            decoration: BoxDecoration(
              border: Border.all(
                color: Theme.of(context).colorScheme.outlineVariant,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          order.orderNumber,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.w900),
                        ),
                      ),
                      InfoPill(
                        label: _orderStatusLabel(order.status),
                        icon: _orderStatusIcon(order.status),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _formatCurrency(order.total, order.currency),
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  if (order.items.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      order.items.map((item) => item.title).join(', '),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  if (order.pointsEarned > 0 || order.pointsUsed > 0) ...[
                    const SizedBox(height: 6),
                    Text(
                      'Point: +${order.pointsEarned}, pakai ${order.pointsUsed}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                  if (order.createdAt != null) ...[
                    const SizedBox(height: 6),
                    Text(
                      DateFormat(
                        'd MMM yyyy, HH:mm',
                        'id_ID',
                      ).format(order.createdAt!.toLocal()),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _OrderHistoryScreen extends StatefulWidget {
  const _OrderHistoryScreen({required this.apiClient});

  final ApiClient apiClient;

  @override
  State<_OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<_OrderHistoryScreen> {
  late Future<List<OrderSummary>> _future;

  @override
  void initState() {
    super.initState();
    _future = widget.apiClient.getMyOrders();
  }

  Future<void> _refresh() async {
    final next = widget.apiClient.getMyOrders();
    setState(() {
      _future = next;
    });

    try {
      await next;
    } catch (_) {
      // FutureBuilder will show the latest error state.
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Riwayat Order')),
      body: SafeArea(
        child: FutureBuilder<List<OrderSummary>>(
          future: _future,
          builder: (context, snapshot) {
            final rows = snapshot.data ?? const <OrderSummary>[];

            if (snapshot.connectionState == ConnectionState.waiting &&
                rows.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }

            return RefreshIndicator(
              onRefresh: _refresh,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                children: [
                  if (snapshot.hasError)
                    const InlineNotice(
                      icon: Icons.cloud_off_outlined,
                      message: 'Riwayat order belum bisa dimuat.',
                    )
                  else if (rows.isEmpty)
                    const EmptyState(
                      title: 'Belum ada order.',
                      icon: Icons.receipt_long_outlined,
                    )
                  else
                    for (final item in rows)
                      _OrderTile(
                        apiClient: widget.apiClient,
                        order: item,
                        onChanged: _refresh,
                      ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _OrderDetailScreen extends StatefulWidget {
  const _OrderDetailScreen({
    required this.apiClient,
    required this.order,
  });

  final ApiClient apiClient;
  final OrderSummary order;

  @override
  State<_OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<_OrderDetailScreen> {
  late Future<OrderSummary> _future;

  @override
  void initState() {
    super.initState();
    _future = widget.apiClient.getMyOrder(widget.order.id);
  }

  Future<void> _refresh() async {
    final next = widget.apiClient.getMyOrder(widget.order.id);
    setState(() {
      _future = next;
    });

    try {
      await next;
    } catch (_) {
      // FutureBuilder will show the latest error state.
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detail Order')),
      body: SafeArea(
        child: FutureBuilder<OrderSummary>(
          future: _future,
          builder: (context, snapshot) {
            final order = snapshot.data ?? widget.order;
            final isLoading = snapshot.connectionState == ConnectionState.waiting;

            return RefreshIndicator(
              onRefresh: _refresh,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                children: [
                  if (isLoading) const LinearProgressIndicator(),
                  if (isLoading) const SizedBox(height: 12),
                  if (snapshot.hasError) ...[
                    InlineNotice(
                      icon: Icons.cloud_off_outlined,
                      message:
                          'Detail order terbaru belum bisa dimuat. Menampilkan data terakhir. ${snapshot.error}',
                    ),
                    const SizedBox(height: 12),
                  ],
                  _OrderStatusCard(order: order),
                  const SizedBox(height: 12),
                  _OrderPaymentCard(order: order),
                  const SizedBox(height: 12),
                  _OrderItemsCard(order: order),
                  const SizedBox(height: 12),
                  _OrderAccessNote(order: order),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _OrderStatusCard extends StatelessWidget {
  const _OrderStatusCard({required this.order});

  final OrderSummary order;

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'Status Order',
      icon: _orderStatusIcon(order.status),
      trailing: InfoPill(
        label: _orderStatusLabel(order.status),
        icon: _orderStatusIcon(order.status),
      ),
      children: [
        _InfoRow(
          icon: Icons.confirmation_number_outlined,
          label: 'Nomor Order',
          value: order.orderNumber,
        ),
        if (order.createdAt != null)
          _InfoRow(
            icon: Icons.calendar_today_outlined,
            label: 'Tanggal Order',
            value: DateFormat(
              'd MMMM yyyy, HH:mm',
              'id_ID',
            ).format(order.createdAt!.toLocal()),
          ),
        InlineNotice(
          icon: _orderStatusIcon(order.status),
          message: _orderStatusMessage(order.status),
        ),
      ],
    );
  }
}

class _OrderPaymentCard extends StatelessWidget {
  const _OrderPaymentCard({required this.order});

  final OrderSummary order;

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'Ringkasan Pembayaran',
      icon: Icons.payments_outlined,
      children: [
        _PriceRow(
          label: 'Subtotal',
          value: _formatCurrency(order.subtotal, order.currency),
        ),
        if (order.promoDiscount > 0)
          _PriceRow(
            label: 'Promo',
            value: '-${_formatCurrency(order.promoDiscount, order.currency)}',
          ),
        if (order.voucherDiscount > 0)
          _PriceRow(
            label: 'Voucher',
            value: '-${_formatCurrency(order.voucherDiscount, order.currency)}',
          ),
        if (order.pointDiscount > 0)
          _PriceRow(
            label: 'Point',
            value: '-${_formatCurrency(order.pointDiscount, order.currency)}',
          ),
        const Divider(height: 20),
        _PriceRow(
          label: 'Total',
          value: _formatCurrency(order.total, order.currency),
          emphasized: true,
        ),
        if (order.pointsEarned > 0 || order.pointsUsed > 0) ...[
          const SizedBox(height: 8),
          Text(
            'Point loyalty: +${order.pointsEarned} didapat, ${order.pointsUsed} dipakai',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ],
    );
  }
}

class _OrderItemsCard extends StatelessWidget {
  const _OrderItemsCard({required this.order});

  final OrderSummary order;

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'Paket Dibeli',
      icon: Icons.inventory_2_outlined,
      children: [
        if (order.items.isEmpty)
          const Text('Item order belum tersedia.')
        else
          for (final item in order.items) _OrderItemRow(item: item),
      ],
    );
  }
}

class _OrderItemRow extends StatelessWidget {
  const _OrderItemRow({required this.item});

  final OrderItemSummary item;

  @override
  Widget build(BuildContext context) {
    final package = item.package;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest
              .withValues(alpha: 0.35),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.title,
                style: const TextStyle(fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 6),
              if (package != null)
                Text(_packageSubtitle(package))
              else
                const Text('Paket'),
              const SizedBox(height: 6),
              Text(
                '${item.quantity} x ${_formatCurrency(item.price, package?.currency ?? 'IDR')}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 2),
              Text(
                _formatCurrency(item.subtotal, package?.currency ?? 'IDR'),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OrderAccessNote extends StatelessWidget {
  const _OrderAccessNote({required this.order});

  final OrderSummary order;

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'Akses Paket',
      icon: Icons.lock_open_outlined,
      children: [
        Text(_orderAccessMessage(order.status)),
      ],
    );
  }
}

class _PriceRow extends StatelessWidget {
  const _PriceRow({
    required this.label,
    required this.value,
    this.emphasized = false,
  });

  final String label;
  final String value;
  final bool emphasized;

  @override
  Widget build(BuildContext context) {
    final style = emphasized
        ? Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w900,
          )
        : Theme.of(context).textTheme.bodyMedium;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(child: Text(label, style: style)),
          Text(value, style: style),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.icon,
    required this.children,
    this.trailing,
  });

  final String title;
  final IconData icon;
  final List<Widget> children;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                ?trailing,
              ],
            ),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 2),
                Text(value),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricBox extends StatelessWidget {
  const _MetricBox({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer.withValues(alpha: 0.32),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileEditResult {
  const _ProfileEditResult({
    required this.displayName,
    required this.fullName,
    required this.phoneNumber,
    required this.addressLine,
    required this.city,
    required this.province,
    required this.postalCode,
    required this.country,
  });

  final String displayName;
  final String fullName;
  final String phoneNumber;
  final String addressLine;
  final String city;
  final String province;
  final String postalCode;
  final String country;
}

Future<_ProfileEditResult?> _showEditProfileDialog(
  BuildContext context,
  UserProfileDetail profile,
) async {
  final displayNameController = TextEditingController(
    text: profile.displayName ?? '',
  );
  final fullNameController = TextEditingController(
    text: profile.profile?.fullName ?? '',
  );
  final phoneController = TextEditingController(
    text: profile.profile?.phoneNumber ?? profile.phoneNumber ?? '',
  );
  final addressController = TextEditingController(
    text: profile.profile?.addressLine ?? '',
  );
  final cityController = TextEditingController(
    text: profile.profile?.city ?? '',
  );
  final provinceController = TextEditingController(
    text: profile.profile?.province ?? '',
  );
  final postalCodeController = TextEditingController(
    text: profile.profile?.postalCode ?? '',
  );
  final countryController = TextEditingController(
    text: profile.profile?.country ?? 'Indonesia',
  );

  try {
    return await showDialog<_ProfileEditResult>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Profil'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _DialogTextField(
                  controller: displayNameController,
                  label: 'Nama Tampilan',
                ),
                _DialogTextField(
                  controller: fullNameController,
                  label: 'Nama Lengkap',
                ),
                _DialogTextField(
                  controller: phoneController,
                  label: 'Nomor HP',
                  keyboardType: TextInputType.phone,
                ),
                _DialogTextField(
                  controller: addressController,
                  label: 'Alamat Rumah',
                  maxLines: 3,
                ),
                _DialogTextField(controller: cityController, label: 'Kota'),
                _DialogTextField(
                  controller: provinceController,
                  label: 'Provinsi',
                ),
                _DialogTextField(
                  controller: postalCodeController,
                  label: 'Kode Pos',
                  keyboardType: TextInputType.number,
                ),
                _DialogTextField(
                  controller: countryController,
                  label: 'Negara',
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Batal'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(context).pop(
                  _ProfileEditResult(
                    displayName: displayNameController.text.trim(),
                    fullName: fullNameController.text.trim(),
                    phoneNumber: phoneController.text.trim(),
                    addressLine: addressController.text.trim(),
                    city: cityController.text.trim(),
                    province: provinceController.text.trim(),
                    postalCode: postalCodeController.text.trim(),
                    country: countryController.text.trim().isEmpty
                        ? 'Indonesia'
                        : countryController.text.trim(),
                  ),
                );
              },
              child: const Text('Simpan'),
            ),
          ],
        );
      },
    );
  } finally {
    displayNameController.dispose();
    fullNameController.dispose();
    phoneController.dispose();
    addressController.dispose();
    cityController.dispose();
    provinceController.dispose();
    postalCodeController.dispose();
    countryController.dispose();
  }
}

class _DialogTextField extends StatelessWidget {
  const _DialogTextField({
    required this.controller,
    required this.label,
    this.keyboardType,
    this.maxLines = 1,
  });

  final TextEditingController controller;
  final String label;
  final TextInputType? keyboardType;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        decoration: InputDecoration(labelText: label),
      ),
    );
  }
}

UserProfileDetail _fallbackProfile(AppUser user) {
  return UserProfileDetail(
    id: user.id,
    role: user.role,
    email: user.email,
    phoneNumber: user.phoneNumber,
    displayName: user.displayName,
    photoUrl: user.photoUrl,
  );
}

String _packageSubtitle(ProductPackage package) {
  return [
    package.kind.replaceAll('_', ' '),
    if (package.level?.isNotEmpty == true) package.level,
    if (package.category?.isNotEmpty == true) package.category,
  ].whereType<String>().join(' - ');
}

String _orderStatusLabel(String status) {
  return switch (status) {
    'PENDING' => 'Menunggu',
    'PAID' => 'Aktif',
    'CANCELLED' => 'Batal',
    _ => status,
  };
}

IconData _orderStatusIcon(String status) {
  return switch (status) {
    'PENDING' => Icons.hourglass_top_outlined,
    'PAID' => Icons.verified_outlined,
    'CANCELLED' => Icons.cancel_outlined,
    _ => Icons.receipt_long_outlined,
  };
}

String _orderStatusMessage(String status) {
  return switch (status) {
    'PENDING' =>
      'Order sudah dibuat dan menunggu verifikasi admin. Setelah pembayaran disetujui, paket akan otomatis aktif.',
    'PAID' =>
      'Order sudah aktif. Materi muncul di tab Belajar, sedangkan soal muncul di tab Ujian sesuai paket yang dibeli.',
    'CANCELLED' =>
      'Order ini dibatalkan, jadi paket dari order ini tidak membuka akses belajar atau ujian.',
    _ => 'Status order: $status',
  };
}

String _orderAccessMessage(String status) {
  return switch (status) {
    'PENDING' =>
      'Paket belum terbuka. Tunggu admin mengubah status order menjadi PAID setelah pembayaran diterima.',
    'PAID' =>
      'Paket sudah terbuka. Buka tab Belajar untuk materi, atau tab Ujian untuk latihan soal.',
    'CANCELLED' =>
      'Paket tidak aktif karena order dibatalkan. Buat order baru bila ingin membeli paket ini lagi.',
    _ => 'Cek status order ini secara berkala.',
  };
}

String _formatCurrency(int value, String currency) {
  return NumberFormat.currency(
    locale: 'id_ID',
    symbol: currency == 'IDR' ? 'Rp' : '$currency ',
    decimalDigits: 0,
  ).format(value);
}
