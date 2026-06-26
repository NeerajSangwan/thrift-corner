import 'package:flutter/material.dart';
import 'package:thrift_corner/core/storage/local_storage.dart';
import 'package:thrift_corner/features/cart/screens/cart_items.dart';
import 'package:thrift_corner/features/checkout/screens/checkout_screen.dart';
import 'package:thrift_corner/features/home/screens/wishlist_screen.dart';
import 'dart:math';

import 'package:thrift_corner/core/utils/snackbar_helper.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  void _showCouponCelebration(String code, double discount) {
    final overlay = Overlay.of(context);
    late OverlayEntry entry;

    entry = OverlayEntry(
      builder: (context) => _CelebrationOverlay(
        message: 'Coupon Applied! \$$discount off',
        onDone: () => entry.remove(),
      ),
    );

    overlay.insert(entry);
  }

  String? _appliedCouponCode;
  double _couponDiscountAmount = 0.0;

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
        (subtotal + convenienceFee) - _couponDiscountAmount;
    return calculatedTotal < 0 ? 0.0 : calculatedTotal;
  }

  void _applyCoupon(String code, double discount) {
    setState(() {
      _appliedCouponCode = code;
      _couponDiscountAmount = discount;
    });
  }

  void _removeCoupon() {
    setState(() {
      _appliedCouponCode = null;
      _couponDiscountAmount = 0.0;
    });
  }

  void _showCouponsBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            top: 20,
            left: 20,
            right: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'APPLY COUPON',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF282C3F),
                      letterSpacing: 0.5,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, size: 20),
                    constraints: const BoxConstraints(),
                    padding: EdgeInsets.zero,
                  ),
                ],
              ),
              const Divider(height: 24),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Enter coupon code',
                        hintStyle: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 14,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(4),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(4),
                          borderSide: const BorderSide(color: Colors.black),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    style: TextButton.styleFrom(foregroundColor: Colors.black),
                    child: const Text(
                      'CHECK',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const Text(
                'AVAILABLE COUPONS',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF7E818C),
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade200),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        border: Border.all(
                          color: Colors.black,
                          style: BorderStyle.values[1],
                        ),
                      ),
                      child: const Text(
                        'THRIFT10',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Save \$10.00 on this order',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Valid on all items in your cart',
                            style: TextStyle(
                              fontSize: 11,
                              color: Color(0xFF7E818C),
                            ),
                          ),
                        ],
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        _applyCoupon('THRIFT10', 10.00);
                        Navigator.pop(context);
                        _showCouponCelebration('THRIFT10', 10.00);
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.black,
                      ),
                      child: const Text(
                        'APPLY',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showPriceDetailsBottomSheet(BuildContext context) {
    final double subtotal = getSubtotalPrice();
    const double convenienceFee = 2.50;
    final double grandTotal = getGrandTotalPrice();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'PRICE DETAILS',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF282C3F),
                        letterSpacing: 0.5,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close, size: 20),
                      constraints: const BoxConstraints(),
                      padding: EdgeInsets.zero,
                    ),
                  ],
                ),
                const Divider(height: 24),
                _buildPriceRow(
                  'Bag Total (Subtotal)',
                  '\$${subtotal.toStringAsFixed(2)}',
                ),
                const SizedBox(height: 12),
                _buildPriceRow(
                  'Convenience & Tax Fee',
                  '\$${convenienceFee.toStringAsFixed(2)}',
                ),
                const SizedBox(height: 12),
                _buildPriceRow('Delivery Charges', 'FREE', isGreen: true),
                if (_appliedCouponCode != null) ...[
                  const SizedBox(height: 12),
                  _buildPriceRow(
                    'Coupon Discount ($_appliedCouponCode)',
                    '-\$${_couponDiscountAmount.toStringAsFixed(2)}',
                    isGreen: true,
                  ),
                ],
                const Divider(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Total Amount',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF282C3F),
                      ),
                    ),
                    Text(
                      '\$${grandTotal.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPriceRow(String label, String value, {bool isGreen = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(color: Color(0xFF7E818C), fontSize: 13),
        ),
        Text(
          value,
          style: TextStyle(
            color: isGreen ? Colors.green[700] : const Color(0xFF282C3F),
            fontWeight: isGreen ? FontWeight.bold : FontWeight.w500,
            fontSize: 13,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final int itemsCount = cartItems.length;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F6),
      appBar: AppBar(
        elevation: 0.5,
        backgroundColor: Colors.white,
        scrolledUnderElevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back, color: Color(0xFF282C3F)),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'SHOPPING BAG',
              style: TextStyle(
                color: Color(0xFF282C3F),
                fontWeight: FontWeight.bold,
                fontSize: 14,
                letterSpacing: 0.5,
              ),
            ),
            if (itemsCount > 0) ...[
              const SizedBox(height: 2),
              Text(
                '$itemsCount ${itemsCount == 1 ? "ITEM" : "ITEMS"}',
                style: const TextStyle(
                  color: Color(0xFF7E818C),
                  fontWeight: FontWeight.w500,
                  fontSize: 11,
                ),
              ),
            ],
          ],
        ),
        actions: [
          IconButton(
            onPressed: () async {
              await Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const WishlistScreen()),
              );
              setState(() {});
            },
            icon: const Icon(Icons.favorite_border, color: Color(0xFF282C3F)),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.help_outline, color: Color(0xFF282C3F)),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: cartItems.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.shopping_bag_outlined,
                    color: Colors.grey[400],
                    size: 70,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Hey, it feels so light!',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF282C3F),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'There is nothing in your bag. Let\'s add some items.',
                    style: TextStyle(fontSize: 13, color: Color(0xFF7E818C)),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ListView.builder(
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          itemCount: cartItems.length,
                          itemBuilder: (context, index) {
                            final item = cartItems[index];
                            final product = item['product'];

                            return Container(
                              margin: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(
                                  color: const Color(0xFFEAEAEE),
                                ),
                              ),
                              child: Stack(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(12),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            2,
                                          ),
                                          child: Image.network(
                                            product['thumbnail'],
                                            width: 80,
                                            height: 100,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                        const SizedBox(width: 14),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                product['title'],
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 14,
                                                  color: Color(0xFF282C3F),
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                product['category'] ??
                                                    'Apparel',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.grey[500],
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                              const SizedBox(height: 12),
                                              Text(
                                                '\$${product['price']}',
                                                style: const TextStyle(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.bold,
                                                  color: Color(0xFF282C3F),
                                                ),
                                              ),
                                              const SizedBox(height: 12),
                                              Container(
                                                decoration: BoxDecoration(
                                                  color: const Color(
                                                    0xFFF5F5F6,
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(4),
                                                ),
                                                child: Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    _buildQtyTab(
                                                      icon: Icons.remove,
                                                      onPressed: () async {
                                                        if (item['quantity'] >
                                                            1) {
                                                          setState(() {
                                                            item['quantity']--;
                                                          });
                                                        } else {
                                                          setState(() {
                                                            cartItems.removeAt(
                                                              index,
                                                            );
                                                          });
                                                        }

                                                        await LocalStorage.saveCart(
                                                          cartItems,
                                                        );
                                                      },
                                                    ),
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.symmetric(
                                                            horizontal: 14,
                                                          ),
                                                      child: Text(
                                                        item['quantity']
                                                            .toString(),
                                                        style: const TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 13,
                                                          color: Color(
                                                            0xFF282C3F,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    _buildQtyTab(
                                                      icon: Icons.add,
                                                      onPressed: () async {
                                                        setState(() {
                                                          item['quantity']++;
                                                        });

                                                        await LocalStorage.saveCart(
                                                          cartItems,
                                                        );
                                                      },
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Positioned(
                                    top: 4,
                                    right: 4,
                                    child: IconButton(
                                      constraints: const BoxConstraints(),
                                      padding: const EdgeInsets.all(8),
                                      onPressed: () async {
                                        setState(() {
                                          cartItems.removeAt(index);
                                        });
                                        await LocalStorage.saveCart(cartItems);
                                        if (mounted) {
                                          SnackbarHelper.showError(
                                            context,
                                            'Removed from cart',
                                          );
                                        }
                                      },
                                      icon: const Icon(
                                        Icons.close,
                                        size: 18,
                                        color: Color(0xFF282C3F),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),

                        const Padding(
                          padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
                          child: Text(
                            'COUPONS',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF7E818C),
                              letterSpacing: 0.8,
                            ),
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 2,
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(
                              color: _appliedCouponCode != null
                                  ? Colors.green.shade200
                                  : const Color(0xFFEAEAEE),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                _appliedCouponCode != null
                                    ? Icons.check_circle
                                    : Icons.local_offer_outlined,
                                color: _appliedCouponCode != null
                                    ? Colors.green[700]
                                    : Colors.black87,
                                size: 20,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _appliedCouponCode != null
                                    ? Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Coupon Applied: $_appliedCouponCode',
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.green[700],
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            'You saved \$${_couponDiscountAmount.toStringAsFixed(2)} with this offer',
                                            style: const TextStyle(
                                              fontSize: 11,
                                              color: Color(0xFF282C3F),
                                            ),
                                          ),
                                        ],
                                      )
                                    : const Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Apply Coupons',
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFF282C3F),
                                            ),
                                          ),
                                          SizedBox(height: 2),
                                          Text(
                                            'Select a coupon to get extra discounts',
                                            style: TextStyle(
                                              fontSize: 11,
                                              color: Color(0xFF7E818C),
                                            ),
                                          ),
                                        ],
                                      ),
                              ),
                              _appliedCouponCode != null
                                  ? TextButton(
                                      onPressed: _removeCoupon,
                                      style: TextButton.styleFrom(
                                        foregroundColor: Colors.red[700],
                                      ),
                                      child: const Text(
                                        'REMOVE',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    )
                                  : OutlinedButton(
                                      onPressed: () =>
                                          _showCouponsBottomSheet(context),
                                      style: OutlinedButton.styleFrom(
                                        side: const BorderSide(
                                          color: Colors.black,
                                        ),
                                        foregroundColor: Colors.black,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 16,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            4,
                                          ),
                                        ),
                                      ),
                                      child: const Text(
                                        'APPLY',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),

                Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 4,
                        offset: Offset(0, -2),
                      ),
                    ],
                  ),
                  child: SafeArea(
                    top: false,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              GestureDetector(
                                onTap: () =>
                                    _showPriceDetailsBottomSheet(context),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      '\$${getGrandTotalPrice().toStringAsFixed(2)}',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF282C3F),
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    const Row(
                                      children: [
                                        Text(
                                          'View Details',
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: Colors.black,
                                            fontWeight: FontWeight.bold,
                                            decoration:
                                                TextDecoration.underline,
                                          ),
                                        ),
                                        SizedBox(width: 2),
                                        Icon(
                                          Icons.keyboard_arrow_up,
                                          size: 12,
                                          color: Colors.black,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(
                                width: MediaQuery.of(context).size.width * 0.55,
                                height: 46,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.black,
                                    foregroundColor: Theme.of(
                                      context,
                                    ).colorScheme.surface,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    elevation: 0,
                                  ),
                                  onPressed: () async {
                                    await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => CheckoutScreen(
                                          appliedCouponCode: _appliedCouponCode,
                                          couponDiscountAmount:
                                              _couponDiscountAmount,
                                        ),
                                      ),
                                    );
                                    setState(() {});
                                  },
                                  child: const Text(
                                    'PLACE ORDER',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildQtyTab({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(4),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Icon(icon, size: 14, color: const Color(0xFF282C3F)),
      ),
    );
  }
}

class _CelebrationOverlay extends StatefulWidget {
  final String message;
  final VoidCallback onDone;

  const _CelebrationOverlay({required this.message, required this.onDone});

  @override
  State<_CelebrationOverlay> createState() => _CelebrationOverlayState();
}

class _CelebrationOverlayState extends State<_CelebrationOverlay>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _particleController;
  final List<_Particle> _particles = [];

  @override
  void initState() {
    super.initState();

    final random = Random();
    for (int i = 0; i < 30; i++) {
      _particles.add(
        _Particle(
          x: random.nextDouble(),
          color: [
            Colors.red,
            Colors.orange,
            Colors.yellow,
            Colors.green,
            Colors.blue,
            Colors.purple,
            Colors.pink,
          ][random.nextInt(7)],
          size: random.nextDouble() * 8 + 4,
          speed: random.nextDouble() * 0.4 + 0.2,
          wobble: random.nextDouble() * 0.1 - 0.05,
        ),
      );
    }

    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..forward();

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    )..forward();

    Future.delayed(const Duration(milliseconds: 1200), () {
      if (mounted) {
        _fadeController.reverse().then((_) => widget.onDone());
      }
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _particleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeController,
      child: Stack(
        children: [
          AnimatedBuilder(
            animation: _particleController,
            builder: (context, _) {
              return CustomPaint(
                painter: _ParticlePainter(
                  particles: _particles,
                  progress: _particleController.value,
                ),
                size: MediaQuery.of(context).size,
              );
            },
          ),

          Center(
            child: Material(
              color: Colors.transparent,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 28,
                  vertical: 18,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 20,
                      offset: Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('🎉', style: TextStyle(fontSize: 36)),
                    const SizedBox(height: 8),
                    Text(
                      widget.message,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Particle {
  final double x;
  final Color color;
  final double size;
  final double speed;
  final double wobble;
  _Particle({
    required this.x,
    required this.color,
    required this.size,
    required this.speed,
    required this.wobble,
  });
}

class _ParticlePainter extends CustomPainter {
  final List<_Particle> particles;
  final double progress;

  _ParticlePainter({required this.particles, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in particles) {
      final paint = Paint()..color = p.color.withOpacity(1 - progress * 0.5);
      final x = (p.x + p.wobble * progress) * size.width;
      final y =
          size.height * (1 - p.speed) - (progress * size.height * p.speed);
      canvas.drawCircle(Offset(x, y), p.size * (1 - progress * 0.3), paint);
    }
  }

  @override
  bool shouldRepaint(_ParticlePainter old) => old.progress != progress;
}
