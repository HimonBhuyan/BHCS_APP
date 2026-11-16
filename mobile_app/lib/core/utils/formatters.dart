import 'package:intl/intl.dart';

class BhFormatters {
  BhFormatters._();

  static final NumberFormat _inrFull = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 0,
  );

  /// Formats an amount in Indian Rupee format (e.g., ₹4,85,000)
  static String inr(num amount) => _inrFull.format(amount);

  /// Compact Indian currency format (e.g., ₹18.4L, ₹1.25Cr, ₹45K)
  static String inrCompact(num amount) {
    final absVal = amount.abs();
    final sign = amount < 0 ? '-' : '';
    if (absVal >= 10000000) {
      final cr = absVal / 10000000;
      return '$sign₹${cr.toStringAsFixed(cr >= 10 ? 1 : 2)}Cr';
    }
    if (absVal >= 100000) {
      final lakh = absVal / 100000;
      return '$sign₹${lakh.toStringAsFixed(lakh >= 10 ? 1 : 2)}L';
    }
    if (absVal >= 1000) {
      final k = absVal / 1000;
      return '$sign₹${k.toStringAsFixed(k >= 10 ? 0 : 1)}K';
    }
    return '$sign₹${absVal.toStringAsFixed(0)}';
  }

  static String shortDate(DateTime date) => DateFormat('dd MMM yyyy').format(date);

  static String dayMonth(DateTime date) => DateFormat('dd MMM').format(date);

  static String time12h(DateTime date) => DateFormat('hh:mm a').format(date);

  static String dateTimeShort(DateTime date) =>
      DateFormat('dd MMM • hh:mm a').format(date);

  static String relativeTime(DateTime dateTime) {
    final now = DateTime.now();
    final diff = now.difference(dateTime);
    if (diff.isNegative) {
      final futureDiff = dateTime.difference(now);
      if (futureDiff.inMinutes < 60) {
        return 'in ${futureDiff.inMinutes}m';
      }
      if (futureDiff.inHours < 24) {
        return 'in ${futureDiff.inHours}h';
      }
      return 'in ${futureDiff.inDays}d';
    }
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays == 1) return 'Yesterday';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return DateFormat('dd MMM').format(dateTime);
  }
}

