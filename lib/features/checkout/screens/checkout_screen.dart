import 'package:flutter/material.dart';
import 'package:thrift_corner/core/storage/local_storage.dart';
import 'package:thrift_corner/features/cart/screens/cart_items.dart';
import 'dart:math';

class CheckoutScreen extends StatefulWidget {
  final String? appliedCouponCode;
  final double couponDiscountAmount;

  const CheckoutScreen({
    super.key,
    this.appliedCouponCode,
    this.couponDiscountAmount = 0.0,
  });

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  String _selectedPaymentMethod = 'gpay';
  bool _isDropdownExpanded = false;

  final Map<String, Map<String, String>> _paymentOptions = {
    'gpay': {
      'title': 'Google Pay',
      'subtitle': 'Pay instantly using any UPI app',
      'logo':
          'https://upload.wikimedia.org/wikipedia/commons/thumb/c/c7/Google_Pay_Logo_%282020-present%29.svg/2560px-Google_Pay_Logo_%282020-present%29.svg.png',
    },
    'paytm': {
      'title': 'Paytm Wallet / UPI',
      'subtitle': 'Link wallet or pay via saved bank accounts',
      'logo':
          'https://upload.wikimedia.org/wikipedia/commons/thumb/2/24/Paytm_Logo_%28standalone%29.svg/2560px-Paytm_Logo_%28standalone%29.svg.png',
    },
    'card': {
      'title': 'Credit / Debit Card',
      'subtitle': 'Visa, Mastercard, Amex, or RuPay',
      'logo': 'https://cdn-icons-png.flaticon.com/512/349/349228.png',
    },
    'cod': {
      'title': 'Cash on Delivery (COD)',
      'subtitle': 'Pay via cash or UPI code on delivery',
      'logo': 'https://cdn-icons-png.flaticon.com/512/2855/2855613.png',
    },
  };

  double getSubtotalPrice() {
    double total = 0;
    for (var item in cartItems) {
      total += item['product']['price'] * item['quantity'];
    }
    return total;
  }

  double getGrandTotalPrice() {
    double subtotal = getSubtotalPrice();
    const double convenienceFee = 2.50;
    double calculatedTotal =
        (subtotal + convenienceFee) - widget.couponDiscountAmount;
    return calculatedTotal < 0 ? 0.0 : calculatedTotal;
  }

  void _showSuccessOverlayDialog() async {
    cartItems.clear();
    await LocalStorage.saveCart(cartItems);

    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black54,
      builder: (context) => const _OrderSuccessDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double subtotal = getSubtotalPrice();
    const double convenienceFee = 2.50;
    final double grandTotal = getGrandTotalPrice();

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        scrolledUnderElevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: const Color(0xFFEAEAEE), height: 1.0),
        ),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Color(0xFF282C3F),
            size: 18,
          ),
        ),
        title: const Text(
          'CHECKOUT',
          style: TextStyle(
            color: Color(0xFF282C3F),
            fontWeight: FontWeight.w700,
            fontSize: 13,
            letterSpacing: 1.0,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader('DELIVERY ESTIMATE & ITEMS'),
            _buildCardWrapper(
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: cartItems.length,
                separatorBuilder: (context, index) =>
                    const Divider(height: 24, color: Color(0xFFF0F0F2)),
                itemBuilder: (context, index) {
                  final item = cartItems[index];
                  final product = item['product'];
                  return Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(2),
                        child: Image.network(
                          product['thumbnail'],
                          width: 46,
                          height: 58,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              product['title'].toString().toUpperCase(),
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF282C3F),
                                letterSpacing: 0.3,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'QTY: ${item['quantity']}',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey[500],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '\$${(product['price'] * item['quantity']).toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                          color: Color(0xFF282C3F),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),

            _buildSectionHeader('PAYMENT METHOD'),
            _buildDropdownPaymentSelector(),

            _buildSectionHeader('PRICE DETAILS'),
            _buildCardWrapper(
              child: Column(
                children: [
                  _buildPriceRow(
                    'Bag Subtotal',
                    '\$${subtotal.toStringAsFixed(2)}',
                  ),
                  const SizedBox(height: 12),
                  _buildPriceRow(
                    'Convenience & Tax Fee',
                    '\$${convenienceFee.toStringAsFixed(2)}',
                  ),
                  const SizedBox(height: 12),
                  _buildPriceRow('Delivery Charges', 'FREE', isGreen: true),
                  if (widget.appliedCouponCode != null) ...[
                    const SizedBox(height: 12),
                    _buildPriceRow(
                      'Coupon Discount (${widget.appliedCouponCode})',
                      '-\$${widget.couponDiscountAmount.toStringAsFixed(2)}',
                      isGreen: true,
                    ),
                  ],
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 14),
                    child: Divider(height: 1, color: Color(0xFFEAEAEE)),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total Payable',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF282C3F),
                        ),
                      ),
                      Text(
                        '\$${grandTotal.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Color(0xFFEAEAEE), width: 1.0)),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(2),
                  ),
                  elevation: 0,
                ),
                onPressed: _showSuccessOverlayDialog,
                child: const Text(
                  'CONFIRM & PAY',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String text) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 10),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w800,
          color: Color(0xFF7E818C),
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildCardWrapper({required Widget child}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: const Color(0xFFEAEAEE), width: 0.8),
      ),
      child: child,
    );
  }

  Widget _buildDropdownPaymentSelector() {
    final currentMethod = _paymentOptions[_selectedPaymentMethod]!;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: const Color(0xFFEAEAEE), width: 0.8),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () {
              setState(() {
                _isDropdownExpanded = !_isDropdownExpanded;
              });
            },
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  _buildBrandLogo(currentMethod['logo']!),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          currentMethod['title']!,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF282C3F),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Selected Option',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[400],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    _isDropdownExpanded
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    color: const Color(0xFF282C3F),
                    size: 20,
                  ),
                ],
              ),
            ),
          ),

          if (_isDropdownExpanded) ...[
            Container(height: 1, color: const Color(0xFFF0F0F2)),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Column(
                children: _paymentOptions.entries.map((entry) {
                  final String key = entry.key;
                  final Map<String, String> details = entry.value;
                  final bool isSelected = _selectedPaymentMethod == key;

                  return InkWell(
                    onTap: () {
                      setState(() {
                        _selectedPaymentMethod = key;
                        _isDropdownExpanded = false;
                      });
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      child: Row(
                        children: [
                          _buildBrandLogo(details['logo']!),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  details['title']!,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: isSelected
                                        ? FontWeight.w700
                                        : FontWeight.w600,
                                    color: const Color(0xFF282C3F),
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  details['subtitle']!,
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey[500],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            height: 16,
                            width: 16,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isSelected
                                    ? Colors.black
                                    : const Color(0xFFD0D0D4),
                                width: isSelected ? 5.0 : 1.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBrandLogo(String url) {
    return Container(
      height: 38,
      width: 38,
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: const Color(0xFFFAFAFA),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: const Color(0xFFEAEAEE), width: 0.6),
      ),
      child: Image.network(
        url,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) =>
            const Icon(Icons.payment_rounded, size: 16, color: Colors.grey),
      ),
    );
  }

  Widget _buildPriceRow(String label, String value, {bool isGreen = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF7E818C),
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: isGreen ? const Color(0xFF2E7D32) : const Color(0xFF282C3F),
            fontWeight: isGreen ? FontWeight.w700 : FontWeight.w600,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}

class _OrderSuccessDialog extends StatefulWidget {
  const _OrderSuccessDialog();

  @override
  State<_OrderSuccessDialog> createState() => _OrderSuccessDialogState();
}

class _OrderSuccessDialogState extends State<_OrderSuccessDialog>
    with TickerProviderStateMixin {
  late AnimationController _tickController;
  late AnimationController _balloonController;
  late Animation<double> _circleProgress;
  late Animation<double> _tickScale;
  final List<_Balloon> _balloons = [];
  bool _showBalloons = true;

  @override
  void initState() {
    super.initState();

    final random = Random();
    for (int i = 0; i < 12; i++) {
      _balloons.add(
        _Balloon(
          x: random.nextDouble(),
          color: [
            Colors.red.shade300,
            Colors.pink.shade300,
            Colors.orange.shade300,
            Colors.yellow.shade400,
            Colors.green.shade300,
            Colors.blue.shade300,
            Colors.purple.shade300,
          ][random.nextInt(7)],
          size: random.nextDouble() * 20 + 24,
          speed: random.nextDouble() * 0.3 + 0.2,
          wobble: random.nextDouble() * 0.06 - 0.03,
          delay: random.nextDouble() * 0.4,
        ),
      );
    }
    _balloonController =
        AnimationController(
            vsync: this,
            duration: const Duration(milliseconds: 2000),
          )
          ..forward().then((_) {
            if (mounted) setState(() => _showBalloons = false);
          });

    _tickController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _circleProgress = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _tickController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _tickScale = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _tickController,
        curve: const Interval(0.5, 1.0, curve: Curves.elasticOut),
      ),
    );

    _tickController.forward();
  }

  @override
  void dispose() {
    _tickController.dispose();
    _balloonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        if (_showBalloons)
          AnimatedBuilder(
            animation: _balloonController,
            builder: (context, _) {
              return CustomPaint(
                painter: _BalloonPainter(
                  balloons: _balloons,
                  progress: _balloonController.value,
                ),
                size: MediaQuery.of(context).size,
              );
            },
          ),

        Center(
          child: Material(
            color: Colors.transparent,
            child: Dialog(
              backgroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 40,
                  horizontal: 24,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AnimatedBuilder(
                      animation: _tickController,
                      builder: (context, _) {
                        return SizedBox(
                          height: 72,
                          width: 72,
                          child: CustomPaint(
                            painter: _TickPainter(
                              circleProgress: _circleProgress.value,
                              tickScale: _tickScale.value,
                            ),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 24),
                    const Text(
                      'ORDER CONFIRMED',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.5,
                        color: Color(0xFF282C3F),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Your sustainable style is locked in. Thank you for shopping thoughtfully.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[600],
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      height: 46,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        onPressed: () {
                          Navigator.of(
                            context,
                          ).popUntil((route) => route.isFirst);
                        },
                        child: const Text(
                          'CONTINUE SHOPPING',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                            letterSpacing: 1.0,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _Balloon {
  final double x;
  final Color color;
  final double size;
  final double speed;
  final double wobble;
  final double delay;

  _Balloon({
    required this.x,
    required this.color,
    required this.size,
    required this.speed,
    required this.wobble,
    required this.delay,
  });
}

class _BalloonPainter extends CustomPainter {
  final List<_Balloon> balloons;
  final double progress;

  _BalloonPainter({required this.balloons, required this.progress});

  @override
  @override
  void paint(Canvas canvas, Size size) {
    for (final b in balloons) {
      final adjustedProgress = ((progress - b.delay).clamp(0.0, 1.0));
      if (adjustedProgress == 0.0) continue;

      final opacity = (1 - adjustedProgress).clamp(0.0, 0.85);

      final paint = Paint()..color = b.color.withOpacity(opacity);
      final x = (b.x + b.wobble * sin(adjustedProgress * 6)) * size.width;
      final y = size.height - (adjustedProgress * size.height * 1.4);

      if (y < -b.size * 2) continue;

      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(x, y),
          width: b.size,
          height: b.size * 1.25,
        ),
        paint,
      );

      final stringPaint = Paint()
        ..color = Colors.grey.shade400.withOpacity(opacity)
        ..strokeWidth = 1.0
        ..style = PaintingStyle.stroke;

      canvas.drawLine(
        Offset(x, y + b.size * 0.6),
        Offset(x + sin(adjustedProgress * 4) * 4, y + b.size * 0.6 + 16),
        stringPaint,
      );
    }
  }

  @override
  bool shouldRepaint(_BalloonPainter old) => old.progress != progress;
}

class _TickPainter extends CustomPainter {
  final double circleProgress;
  final double tickScale;

  _TickPainter({required this.circleProgress, required this.tickScale});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 4;

    final circlePaint = Paint()
      ..color = Colors.green
      ..strokeWidth = 3.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2,
      2 * pi * circleProgress,
      false,
      circlePaint,
    );

    if (circleProgress >= 1.0) {
      final fillPaint = Paint()..color = Colors.green;
      canvas.drawCircle(center, radius, fillPaint);
    }

    if (tickScale > 0) {
      final tickPaint = Paint()
        ..color = Colors.white
        ..strokeWidth = 3.5
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke;

      final tickPath = Path();
      final cx = center.dx;
      final cy = center.dy;

      tickPath.moveTo(cx - radius * 0.35 * tickScale, cy);
      tickPath.lineTo(
        cx - radius * 0.05 * tickScale,
        cy + radius * 0.3 * tickScale,
      );
      tickPath.lineTo(
        cx + radius * 0.4 * tickScale,
        cy - radius * 0.25 * tickScale,
      );

      canvas.drawPath(tickPath, tickPaint);
    }
  }

  @override
  bool shouldRepaint(_TickPainter old) =>
      old.circleProgress != circleProgress || old.tickScale != tickScale;
}
