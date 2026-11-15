const _months = [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec',
];

/// Formats a date like "15 Nov 2026".
String formatDate(DateTime d) => '${d.day} ${_months[d.month - 1]} ${d.year}';
